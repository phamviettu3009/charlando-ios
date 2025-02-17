//
//  GroupChannelViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 30/11/2023.
//

import Foundation
import SwiftUI
import UIKit
import Combine
import FormValidator

class CreateGroupChannelViewModel: ViewModel {
    private var subscriptions = Set<AnyCancellable>()

    private let userRepository: UserRepository = UserRepositoryImpl.shared
    private let channelRepository: ChannelRepository = ChannelRepositoryImpl.shared
    
    enum LoadType: LoadCase {
        case LoadingListFriend
        case LoadMoreListFriend
        case CreatingGroupChat
    }
    
    private var _page: Int = 0
    
    @Published var validatorManager = FormManager(validationType: .immediate)
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var search: String = ""
    @Published var isLoadingListFriend: Bool = false
    @Published var isLoadMoreListFriend: Bool = false
    @Published var isCreatingGroupChat: Bool = false
    @Published var friends: [User] = []
    @Published var selectedFriends: [String] = []
    
    // MARK: - VALIDATION FIELD
    
    @FormField(validator: CompositeValidator(validators: [
        NonEmptyValidator(message: LocalizedStringKey("group_name_is_not_empty").stringValue()),
        CountValidator(count: 25, type: .lessThan, message: LocalizedStringKey("group_name_is_to_long").stringValue())
    ], type: .all, strategy: .all))
    var groupName: String = ""
    lazy var groupNameValidationContainer = _groupName.validation(manager: validatorManager)
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        $search
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] value in self?.onChangeSearchText(value)}
            .store(in: &subscriptions)
    }
    
    private func onChangeSearchText(_ value: String) {
        resetPage()
        Task {
            await getListFriend(loadType: LoadType.LoadingListFriend)
        }
    }
    
    // MARK: - FETCH FRIENDS
    
    private func getListFriend(loadType: LoadType) async {
        _page += 1
        loader(true, loadType)
        do {
            let friends = try await userRepository.getListFriend(page: _page, keyword: search)
            updateListFriendValueAfterFetch(data: friends, loadType: loadType)
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, loadType)
    }
    
    func loadMoreListFriend() {
        if friends.isEmpty { return }
        Task {
            await getListFriend(loadType: LoadType.LoadMoreListFriend)
        }
    }
    
    func onRefresh() {
        resetPage()
        DispatchQueue.main.async {
            self.friends.removeAll()
            self.search = ""
        }
        Task {
            await getListFriend(loadType: LoadType.LoadingListFriend)
        }
    }
    
    // MARK: - POST GROUP
    
    func createGroup(onSuccess: @escaping () -> Void ) async {
        if (isCreatingGroupChat) { return }
        loader(true, LoadType.CreatingGroupChat)
        do {
            let payload = ChannelGroupRequest(groupName: self.groupName, memberIDs: self.selectedFriends)
            let _ = try await channelRepository.createChannelGroup(channelGroupRequest: payload)
            onSuccess()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, LoadType.CreatingGroupChat)
    }
}

extension CreateGroupChannelViewModel {
    func onSelectedFriends(_ id: UUID, _ isSelected: Bool) {
       if (isSelected) {
           selectedFriends.append(id.uuidString)
       } else {
           if let index = selectedFriends.firstIndex(of: id.uuidString) {
               selectedFriends.remove(at: index)
           }
       }
   }
    
    private func updateListFriendValueAfterFetch(data: [User], loadType: LoadType) {
        DispatchQueue.main.async {
            switch loadType {
            case LoadType.LoadingListFriend:
                self.friends = data
                break
            case LoadType.LoadMoreListFriend:
                self.friends += data
                break
            default:
                break
            }
        }
    }
    
    private func putMessage(_ message: String?, _ messageColor: Color = .red) {
        DispatchQueue.main.async {
            self.message = message
            self.messageColor = messageColor
        }
    }
    
    private func loader(_ value: Bool, _ caseLoader: LoadCase? = nil) {
        DispatchQueue.main.async {
            switch caseLoader! {
            case LoadType.LoadingListFriend:
                self.isLoadingListFriend = value
                break
            case LoadType.LoadMoreListFriend:
                self.isLoadMoreListFriend = value
                break
            case LoadType.CreatingGroupChat:
                self.isCreatingGroupChat = value
            default:
                break
            }
        }
    }
    
    private func resetPage() {
        _page = 0
    }
    
    private func resetData() {
        DispatchQueue.main.async {
            self._page = 0
            self.message = nil
            self.messageColor = .red
            self.isLoadingListFriend = false
            self.isLoadMoreListFriend = false
            self.isCreatingGroupChat = false
            self.friends.removeAll()
            self.search = ""
            self.selectedFriends.removeAll()
            self.groupName = ""
        }
    }
}
