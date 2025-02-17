//
//  ListChannelViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 28/11/2023.
//

import Foundation
import SwiftUI
import Combine
import CoreData
import SocketIO

class ListChannelViewModel: ViewModel {
    private let coreDataProvider = CoreDataProvider.shared
    private let connectivityManager = ConnectivityManager.shared
    private var context: NSManagedObjectContext
    private var subscriptions = Set<AnyCancellable>()
    private var socket: SocketIOClient?
    
    private let userRepository: UserRepository = UserRepositoryImpl.shared
    private let channelRepositorry: ChannelRepository = ChannelRepositoryImpl.shared
    
    enum LoadType: LoadCase {
        case LoadingListChannel
    }
    
    private var _page: Int = 0
    
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var search: String = ""
    @Published var isLoadingListChannel: Bool = false
    @Published var channels: [Channel] = []
    
    init() {
        context = coreDataProvider.newContext
        addSubscribers()
        NotificationCenter.default.addObserver(self, selector: #selector(initSocket), name: Notification.Name("initSocketListChannel"), object: nil)
    }
    
    @objc private func initSocket() {
        DispatchQueue.main.async {
            self.socket = SocketIOManager.shared.socket
            Task { await self.getUser() }
        }
    }
    
    private func addSubscribers() {
        $search
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] value in self?.onChangeSearchText(value)}
            .store(in: &subscriptions)
    }
    
    private func onChangeSearchText(_ value: String) {
        resetPage()
        fetchListChannel()
    }
    
    // MARK: - FETCH CHANNELS
    
    private func fetchListChannel() {
        _page += 1
        fetchListChannelFromCoreData(page: _page)
        
        Task(priority: .background) {
            await fetchListChannelFromAPIs(page: _page)
        }
    }
    
    private func fetchListChannelFromCoreData(page: Int) {
        do {
            let channelRequest = ChannelEntity.findAll(quantity: SIZE_PER_PAGE * page, search: search)
            let data: [ChannelEntity] = try context.fetch(channelRequest)
            let listChannel = data.asListChannel()
            updateListChannelValueAfterFetch(data: listChannel, loadType: LoadType.LoadingListChannel)
        } catch {
            
        }
    }
    
    private func fetchListChannelFromAPIs(page: Int) async {
        do {
            let channels = try await channelRepositorry.getListChannel(
                page: page,
                keyword: search
            )
            await connectivityManager.addChannelConnectivityStatus(channels: channels)
            saveListChannel(channels: channels)
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func onRefresh() {
        DispatchQueue.main.async {
            self._page = 0
            self.channels.removeAll()
            self.search = ""
        }
        
        fetchListChannel()
    }
    
    func loadMoreListChannel() {
        if(channels.isEmpty) { return }
        fetchListChannel()
    }
    
    // MARK: - FETCH USER INFO
    
    private func getUser() async {
        let ownerRequest = OwnerEntity.findOwner()
        if let ownerEntity: OwnerEntity = try? context.fetch(ownerRequest).first {
            let user = ownerEntity.asUser()
            channelListener(userID: user.id)
            channelOnlineStatusListener(userID: user.id)
            removeChannelListener(userID: user.id)
            return
        }
        
        if let user = try? await userRepository.getUser() {
            let _ = user.asOwner(context: context)
            try? context.performAndWait {
                try coreDataProvider.persist(in: context)
            }
            channelListener(userID: user.id)
            channelOnlineStatusListener(userID: user.id)
            removeChannelListener(userID: user.id)
        }
    }
    
    // MARK: - SOCKET.IO
    
    private func channelListener(userID: UUID) {
        guard let socket = socket else { return }
        let userID = userID.uuidString.lowercased()
        socket.on("channel/user/\(userID)") { data, ack in
            if let channelJson: String = data.first as? String {
                guard let channelData = channelJson.data(using: .utf8) else { return }
                do {
                    let channel = try JSONDecoder().decode(Channel.self, from: channelData)
                    self.saveListChannel(channels: [channel])
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func channelOnlineStatusListener(userID: UUID) {
        guard let socket = socket else { return }
        let userID = userID.uuidString.lowercased()
        socket.on("channel-online-status/user/\(userID)") { data, ack in
            if let channelOnlineStatusJson: String = data.first as? String {
                guard let channelOnlineStatusData = channelOnlineStatusJson.data(using: .utf8) else { return }
                do {
                    let channelOnlineStatus = try JSONDecoder().decode(ChannelOnlineStatus.self, from: channelOnlineStatusData)
                    let channelID = channelOnlineStatus.channelID
                    let channelConnectivityStatus = channelOnlineStatus.online
                    if let channelIndex: Int = self.channels.firstIndex(where: { $0.id == channelID }) {
                        self.channels[channelIndex].online = channelConnectivityStatus
                        self.connectivityManager.updateChannelConnectivityStatus(
                            channelID: channelID,
                            status: channelConnectivityStatus
                        )
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func removeChannelListener(userID: UUID) {
        guard let socket = socket else { return }
        let userID = userID.uuidString.lowercased()
        socket.on("delete-channel/user/\(userID)") { data, ack in
            if let channelIDString = data.first {
                if (channelIDString is String) {
                    guard let channelID = UUID(uuidString: channelIDString as! String) else { return }
                    self.removeChannel(channelID: channelID)
                }
            }
        }
    }
}

extension ListChannelViewModel {
    func removeChannel(channelID: UUID) {
        let channelRequest = ChannelEntity.findByID(channelID: channelID)
        if let channelEntity: ChannelEntity = try? context.fetch(channelRequest).first {
            try? coreDataProvider.delete(channelEntity, in: context)
        }
        
        if let index = channels.firstIndex(where: { $0.id == channelID }) {
            channels.remove(at: index)
        }
    }
    
    private func updateListChannelValueAfterFetch(data: [Channel], loadType: LoadType) {
        let data: [Channel] = connectivityManager.assignChannelConnectivityStatus(channels: data)
        
        DispatchQueue.main.async {
            switch loadType {
            case LoadType.LoadingListChannel:
                self.channels = data
                break
            }
        }
    }
    
    private func saveListChannel(channels: [Channel]) {
        let _ = channels.asListChannelEntity(context: context)
        try? context.performAndWait {
            try coreDataProvider.persist(in: context)
            fetchListChannelFromCoreData(page: _page)
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
            case LoadType.LoadingListChannel:
                self.isLoadingListChannel = value
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
            self.isLoadingListChannel = false
            self.channels.removeAll()
            self.search = ""
        }
    }
}
