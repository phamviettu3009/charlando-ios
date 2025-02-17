//
//  ListFriendViewModel.swift
//  2lab
//
//  Created by Phạm Việt Tú on 10/06/2024.
//

import Foundation
import SwiftUI
import Combine
import CoreData

class ListFriendViewModel: ViewModel {
    private let coreDataProvider = CoreDataProvider.shared
    private var context: NSManagedObjectContext
    private var subscriptions = Set<AnyCancellable>()
    
    private let userRepository: UserRepository = UserRepositoryImpl.shared
    
    enum LoadType: LoadCase {
        case LoadingListFriend
    }
    
    private var _page: Int = 0
    
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var search: String = ""
    @Published var isLoadingListFriend: Bool = false
    @Published var friends: [User] = []
    
    init() {
        context = coreDataProvider.newContext
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
        fetchListFriend()
    }
    
    // MARK: - FETCH FRIENDS
    
    private func fetchListFriend() {
        _page += 1
        fetchListFriendFromCoreData(page: _page)
        
        Task(priority: .background) {
            await fetchListFriendFromAPIs(page: _page)
        }
    }
    
    private func fetchListFriendFromCoreData(page: Int) {
        let userRequest = UserEntity.findAllByIsFriend(quantity: SIZE_PER_PAGE * page, search: search)
        if let data: [UserEntity] = try? context.fetch(userRequest) {
            let listFriend = data.asListUser()
            updateListFriendValueAfterFetch(data: listFriend, loadType: LoadType.LoadingListFriend)
        }
    }
    
    private func fetchListFriendFromAPIs(page: Int) async {
        do {
            let friends = try await userRepository.getListFriend(page: page, keyword: search)
            saveListFriend(friends: friends)
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func loadMoreListFriend() {
        if (friends.isEmpty) { return }
        fetchListFriend()
    }
    
    func onRefresh() {
        resetPage()
        DispatchQueue.main.async {
            self.friends.removeAll()
            self.search = ""
        }
        fetchListFriend()
    }
}

extension ListFriendViewModel {
    private func updateListFriendValueAfterFetch(data: [User], loadType: LoadType) {
        DispatchQueue.main.async {
            switch loadType {
            case LoadType.LoadingListFriend:
                self.friends = data
                break
            }
        }
    }
    
    private func saveListFriend(friends: [User]) {
        let _ = friends.asListFriendEntity(context: context)
        try? context.performAndWait {
            try coreDataProvider.persist(in: context)
            fetchListFriendFromCoreData(page: _page)
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
            default:
                break
            }
        }
    }
    
    private func resetPage() {
        _page = 0
    }
}
