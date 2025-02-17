//
//  ListRequestAddFriendViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 20/03/2024.
//

import Foundation
import SwiftUI
import UIKit
import Combine
import SocketIO

class ListRequestAddFriendViewModel: ViewModel {
    private var subscriptions = Set<AnyCancellable>()
    private let userRepository: UserRepository = UserRepositoryImpl.shared
    private let socket: SocketIOClient = SocketIOManager.shared.socket
    
    enum LoadType: LoadCase {
        case LoadingListUser
        case LoadMoreListUser
    }
    
    private var _page: Int = 0
    
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var search: String = ""
    @Published var isLoadingListUser: Bool = false
    @Published var isLoadMoreListUser: Bool = false
    @Published var users: [User] = []
    
    init() {
        addSubscribers()
        requestAddFriendListener()
        cancelRequestAddFriendListener()
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
            await fetchListUserFromAPIs(loadType: LoadType.LoadingListUser)
        }
    }
    
    // MARK: - FETCH LIST REQUEST ADD FRIEND
    
    private func fetchListUserFromAPIs(loadType: LoadType) async {
        _page += 1
        do {
            let users = try await userRepository.getListRequestAddFriend(page: _page, keyword: search)
            self.updateListUserValueAfterFetch(data: users, loadType: loadType)
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func loadMoreListUser() {
        if (users.isEmpty) { return }
        Task {
            await fetchListUserFromAPIs(loadType: LoadType.LoadMoreListUser)
        }
    }
    
    func onRefresh() {
        resetPage()
        DispatchQueue.main.async {
            self.users.removeAll()
            self.search = ""
        }
        Task {
            await fetchListUserFromAPIs(loadType: LoadType.LoadingListUser)
        }
    }
    
    // MARK: - SOCKET.IO
    
    private func requestAddFriendListener() {
        socket.on("request-add-friend") { data, ack in
            if let requestAddFriendJson: String = data.first as? String {
                guard let requestAddFriendData = requestAddFriendJson.data(using: .utf8) else { return }
                do {
                    let requestAddFriend = try JSONDecoder().decode(User.self, from: requestAddFriendData)
                    DispatchQueue.main.async {
                        self.users.append(requestAddFriend)
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func cancelRequestAddFriendListener() {
        socket.on("cancel-request-add-friend") { data, ack in
            if let cancelRequestAddFriendJson: String = data.first as? String {
                guard let cancelRequestAddFriendData = cancelRequestAddFriendJson.data(using: .utf8) else { return }
                do {
                    let cancelRequestAddFriend = try JSONDecoder().decode(User.self, from: cancelRequestAddFriendData)
                    DispatchQueue.main.async {
                        self.users.removeAll { $0.id == cancelRequestAddFriend.id }
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
}

extension ListRequestAddFriendViewModel {
    private func updateListUserValueAfterFetch(data: [User], loadType: LoadType) {
        DispatchQueue.main.async {
            switch loadType {
            case LoadType.LoadingListUser:
                self.users = data
                break
            case LoadType.LoadMoreListUser:
                self.users += data
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
            case LoadType.LoadingListUser:
                self.isLoadingListUser = value
                break
            case LoadType.LoadMoreListUser:
                self.isLoadMoreListUser = value
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
            self.isLoadMoreListUser = false
            self.users.removeAll()
            self.search = ""
        }
    }
}
