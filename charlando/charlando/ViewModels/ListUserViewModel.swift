//
//  ListUserViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 23/11/2023.
//

import Foundation
import SwiftUI
import UIKit
import Combine
import CoreData
import SocketIO

class ListUserViewModel: ViewModel {
    private let coreDataProvider = CoreDataProvider.shared
    private var context: NSManagedObjectContext
    private var subscriptions = Set<AnyCancellable>()
    private let socket: SocketIOClient = SocketIOManager.shared.socket
    
    private let userRepository: UserRepository = UserRepositoryImpl.shared
    
    enum LoadType: LoadCase {
        case LoadingListUser
    }
    
    private var _page: Int = 0
    
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var search: String = ""
    @Published var isLoadingListUser: Bool = false
    @Published var users: [User] = []
    @Published var numberRequestAddFriend: Int = 0
    
    init() {
        context = coreDataProvider.newContext
        addSubscribers()
        countRequestAddFriendListener()
        Task { await getNumberRequestAddFriend() }
    }
    
    private func addSubscribers() {
        $search
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] value in self?.onChangeSearchText(value)}
            .store(in: &subscriptions)
    }
    
    private func onChangeSearchText(_ value: String) {
        resetPage()
        fetchListUser()
    }
    
    // MARK: - FETCH USERS
    
    private func fetchListUser() {
        _page += 1
        fetchListUserFromCoreData(page: _page)
        
        Task(priority: .background) {
            await fetchListUserFromAPIs(page: _page)
        }
    }
    
    private func fetchListUserFromCoreData(page: Int) {
        let userRequest = UserEntity.findAll(quantity: SIZE_PER_PAGE * page, search: search)
        if let data: [UserEntity] = try? context.fetch(userRequest) {
            let listUser = data.asListUser()
            updateListUserValueAfterFetch(data: listUser, loadType: LoadType.LoadingListUser)
        }
    }
    
    private func fetchListUserFromAPIs(page: Int) async {
        do {
            let users = try await userRepository.getListUser(page: page, keyword: search)
            saveListUser(users: users)
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func loadMoreListUser() {
        if (users.isEmpty) { return }
        fetchListUser()
    }
    
    func onRefresh() {
        resetPage()
        DispatchQueue.main.async {
            self.users.removeAll()
            self.search = ""
        }
        fetchListUser()
    }
    
    // MARK: - FETCH NUMBER REQUEST ADD FRIEND
    
    private func getNumberRequestAddFriend() async {
        try? await userRepository.getNumberRequestAddFriend()
    }
    
    // MARK: - SOCKET.IO
    
    private func countRequestAddFriendListener() {
        socket.on("count-request-add-friend") { data, ack in
            if let countRequestAddFriend: String = data.first as? String {
                DispatchQueue.main.async {
                    self.numberRequestAddFriend = Int(countRequestAddFriend) ?? 0
                }
            }
        }
    }
}

extension ListUserViewModel {
    private func updateListUserValueAfterFetch(data: [User], loadType: LoadType) {
        DispatchQueue.main.async {
            switch loadType {
            case LoadType.LoadingListUser:
                self.users = data
                break
            }
        }
    }
    
    private func saveListUser(users: [User]) {
        let _ = users.asListUserEntity(context: context)
        try? context.performAndWait {
            try coreDataProvider.persist(in: context)
            fetchListUserFromCoreData(page: _page)
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
            case LoadType.LoadingListUser:
                self.isLoadingListUser = value
                break
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
            self.isLoadingListUser = false
            self.users.removeAll()
            self.search = ""
        }
    }
}
