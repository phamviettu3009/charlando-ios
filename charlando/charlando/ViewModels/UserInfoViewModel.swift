//
//  UserInfoViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 16/03/2024.
//

import Foundation
import SwiftUI
import CoreData

class UserInfoViewModel: ViewModel {
    private let coreDataProvider = CoreDataProvider.shared
    private var context: NSManagedObjectContext
    
    let userRepository: UserRepository = UserRepositoryImpl.shared
    
    enum LoadType: LoadCase {
        case Update
    }
    
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var userInfo: UserInfo?
    @Published var isUpdate: Bool = false
    
    var userID: UUID
    
    init(userID: UUID) {
        self.context = coreDataProvider.newContext
        self.userID = userID
        fetchUserInfo()
    }
    
    // MARK: - FETCH USERINFO
    
    private func fetchUserInfo() {
        fetchUserInfoFromCoreData()
        
        Task { await fetchUserInfoFromAPIs() }
    }
    
    private func fetchUserInfoFromCoreData() {
        let userRequest = UserEntity.findByID(userID: userID)
        if let userEntity: UserEntity = try? context.fetch(userRequest).first {
            DispatchQueue.main.async {
                self.userInfo = userEntity.asUserInfo()
            }
            
            let userDetailRequest = UserDetailEntity.findByID(userID: userID)
            if let userDetailEntity: UserDetailEntity = try? context.fetch(userDetailRequest).first {
                DispatchQueue.main.async {
                    self.userInfo?.relationshipStatus = userDetailEntity.relationshipStatus
                    self.userInfo?.friend = userDetailEntity.friend
                    self.userInfo?.channelID = userDetailEntity.channelID
                    self.userInfo?.gender = userDetailEntity.gender
                    self.userInfo?.dob = userDetailEntity.dob?.asStringDate()
                    self.userInfo?.phone = userDetailEntity.phone
                    self.userInfo?.email = userDetailEntity.email
                    self.userInfo?.countryCode = userDetailEntity.countryCode
                    self.userInfo?.languageCode = userDetailEntity.languageCode
                }
            }
        }
    }
    
    private func fetchUserInfoFromAPIs() async {
        do {
            let userInfo = try await userRepository.getUserInfo(userID: userID)
            let _ = userInfo.asUserDetailEntity(context: context)
            try? context.performAndWait {
                try coreDataProvider.persist(in: context)
            }
            
            fetchUserInfoFromCoreData()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        self.loader(false, LoadType.Update)
    }
    
    // MARK: - POST ACTION
    
    func onSendAction() async {
        guard let userInfo = userInfo else { return }
        let friendID = userInfo.id.uuidString
        switch userInfo.relationshipStatus {
        case FriendStatus.UNFRIEND:
            await onSendRequestAddFriend(friendID: friendID)
        case FriendStatus.FRIEND:
            await onUnfriend(friendID: friendID)
        case FriendStatus.FRIEND_REQUEST_SENT:
            await onCancelRequestAddFriend(friendID: friendID)
        default: break
        }
    }
    
    private func onSendRequestAddFriend(friendID: String) async {
        self.loader(true, LoadType.Update)
        do {
            _ = try await userRepository.sendRequestAddFriend(friendID: friendID)
            await fetchUserInfoFromAPIs()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func onConfirmAddFriend() async {
        guard let userInfo = userInfo else { return }
        let friendID = userInfo.id.uuidString
        
        self.loader(true, LoadType.Update)
        do {
            _ = try await userRepository.confirmAddFriend(friendID: friendID)
            await fetchUserInfoFromAPIs()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    private func onCancelRequestAddFriend(friendID: String) async {
        self.loader(true, LoadType.Update)
        do {
            _ = try await userRepository.cancelRequestAddFriend(friendID: friendID)
            await fetchUserInfoFromAPIs()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    private func onUnfriend(friendID: String) async {
        self.loader(true, LoadType.Update)
        do {
            _ = try await userRepository.unfriend(friendID: friendID)
            await fetchUserInfoFromAPIs()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func onRejectAddFriend() async {
        guard let userInfo = userInfo else { return }
        let friendID = userInfo.id.uuidString
        
        self.loader(true, LoadType.Update)
        do {
            _ = try await userRepository.rejectFriendRequest(friendID: friendID)
            await fetchUserInfoFromAPIs()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
}

extension UserInfoViewModel {
    private func putMessage(_ message: String?, _ messageColor: Color = .red) {
        DispatchQueue.main.async {
            self.message = message
            self.messageColor = messageColor
        }
    }
    
    private func loader(_ value: Bool, _ caseLoader: LoadCase? = nil) {
        DispatchQueue.main.async {
            switch caseLoader! {
            case LoadType.Update:
                self.isUpdate = value
                break
            default:
                break
            }
        }
    }
    
    private func resetData() {
        DispatchQueue.main.async {
            self.isUpdate = false
        }
    }
}

