//
//  GroupChannelViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 12/03/2024.
//

import Foundation
import SwiftUI
import Combine
import CoreData
import FormValidator

class GroupChannelViewModel: ViewModel {
    private let coreDataProvider = CoreDataProvider.shared
    private var context: NSManagedObjectContext
    var subscriptions = Set<AnyCancellable>()
    
    private let channelRepository: ChannelRepository = ChannelRepositoryImpl.shared
    private let resourceRepository: ResourceRepository = ResourceRepositoryImpl.shared
    private let userRepositoty: UserRepository = UserRepositoryImpl.shared
    
    enum LoadType: LoadCase {
        case UpdatingChannel
        case LoadingListFriend
        case LoadMoreListFriend
        case AddingMembers
        case RemovingMembers
    }
    
    private var _page: Int = 1
    
    @Published var validatorManager = FormManager(validationType: .immediate)
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var isOpenSheetChangeChanelName: Bool = false
    @Published var isOpenSheetListMember: Bool = false
    @Published var isOpenSheetAddMembers: Bool = false
    @Published var searchFriend: String = ""
    @Published var channelID: UUID
    @Published var channel: Channel? = nil
    @Published var channelName: String = ""
    @Published var avatarPhoto: PhotoItem? = nil
    @Published var isUpdatingChannel: Bool = false
    @Published var isLoadingListFriend: Bool = false
    @Published var isLoadMoreListFriend: Bool = false
    @Published var isAddingMembers: Bool = false
    @Published var isRemovingMembers: Bool = false
    @Published var shouldSave: Bool = false
    @Published var members: [Member] = []
    @Published var myRole: MyRole? = nil
    @Published var friends: [User] = []
    @Published var selectedFriends: [String] = []
    
    // MARK: - VALIDATION FIELD

    @FormField(validator: CompositeValidator(validators: [
        NonEmptyValidator(message: LocalizedStringKey("group_name_is_not_empty").stringValue()),
        CountValidator(count: 25, type: .lessThan, message: LocalizedStringKey("group_name_is_to_long").stringValue())
    ], type: .all, strategy: .all))
    
    var groupName: String = ""
    lazy var groupNameValidationContainer = _groupName.validation(manager: validatorManager)
    
    init(channelID: UUID) {
        context = coreDataProvider.newContext
        self.channelID = channelID
        fetchChannelFromCoreData()
        addSubscribers()
        Task { await fetchMyRole() }
    }
    
    private func addSubscribers() {
        $searchFriend
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] value in self?.onChangeSearchText(value)}
            .store(in: &subscriptions)
    }
    
    private func onChangeSearchText(_ value: String) {
        guard (isOpenSheetAddMembers) else { return }
        resetPage()
        Task {
            await fetchListFriendOutsideChannel(loadType: LoadType.LoadingListFriend)
        }
    }
    
    // MARK: - FETCH
    
    private func fetchChannelFromCoreData() {
        let channelRequest = ChannelEntity.findByID(channelID: channelID)
        if let data: ChannelEntity = try? self.context.fetch(channelRequest).first {
            DispatchQueue.main.async {
                guard let channel = data.asChannel() else { return }
                self.channel = channel
                self.channelName = channel.name
                self.groupName = channel.name
            }
        }
    }
    
    func fetchListMember() async {
        do {
            let members = try await userRepositoty.getListMemberInChannel(channelID: channelID, page: 1)
            DispatchQueue.main.async {
                self.members = members
            }
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    private func fetchMyRole() async {
        do {
            let myRole = try await channelRepository.getRole(channelID: channelID)
            DispatchQueue.main.async {
                self.myRole = myRole
            }
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    private func fetchListFriendOutsideChannel(loadType: LoadType) async {
        _page += 1
        loader(true, loadType)
        do {
            let friends = try await channelRepository.getFriendOutsideChannel(page: _page, keyword: searchFriend, channelID: channelID)
            updateListFriendValueAfterFetch(data: friends, loadType: loadType)
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, loadType)
    }
    
    func loadMoreListFriendOutsideChannel() {
        if (friends.isEmpty) { return }
        Task {
            await fetchListFriendOutsideChannel(loadType: LoadType.LoadMoreListFriend)
        }
    }
    
    func onRefresh() {
        resetPage()
        DispatchQueue.main.async {
            self.friends.removeAll()
            self.searchFriend = ""
        }
        Task {
            await fetchListFriendOutsideChannel(loadType: LoadType.LoadingListFriend)
        }
    }
    
    // MARK: - [POST PUT DELETE]
    
    func addMembers() async {
        loader(true, LoadType.AddingMembers)
        do {
            let members = GroupChannelMembers(memberIDs: selectedFriends.map { UUID(uuidString: $0)! })
            let _ = try await channelRepository.addMembers(channelID: channelID, members: members)
            DispatchQueue.main.async {
                self.isOpenSheetAddMembers = false
            }
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, LoadType.AddingMembers)
    }
    
    func removeMembers(memberID: UUID) async {
        DispatchQueue.main.async {
            self.members.removeAll { $0.id == memberID }
        }
        
        loader(true, LoadType.RemovingMembers)
        do {
            let members = GroupChannelMembers(memberIDs: [memberID])
            let _ = try await channelRepository.removeMembers(channelID: channelID, members: members)
        } catch {
            print("error: \(error)")
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, LoadType.RemovingMembers)
    }
    
    func leaveGroup(onSuccess: @escaping () -> Void) async {
        do {
            let _ = try await channelRepository.leaveGroup(channelID: channelID)
            let channelRequest = ChannelEntity.findByID(channelID: channelID)
            if let channelEntity = try? context.fetch(channelRequest).first {
                try? coreDataProvider.delete(channelEntity, in: context)
            }
            onSuccess()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func addAdminRole(memberID: UUID) async {
        do {
            let members = GroupChannelMembers(memberIDs: [memberID])
            let _ = try await channelRepository.addAdminRole(channelID: channelID, members: members)
            await fetchListMember()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func revokeAdminRole(memberID: UUID) async {
        do {
            let members = GroupChannelMembers(memberIDs: [memberID])
            let _ = try await channelRepository.revokeAdminRole(channelID: channelID, members: members)
            await fetchListMember()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func setOwnerRole(memberID: UUID) async {
        do {
            let member = GroupChannelMember(memberID: memberID)
            let _ = try await channelRepository.setOwnerRole(channelID: channelID, member: member)
            await fetchMyRole()
            await fetchListMember()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func saveGroupChannel() async {
        DispatchQueue.main.async {
            self.shouldSave = false
        }
        if avatarPhoto != nil {
            await uploadAvatar()
        } else {
            await updateGroupChannel()
        }
    }
    
    private func updateGroupChannel(_ groupChannelUpdateRequest: GroupChannelUpdateRequest? = nil) async {
        if (avatarPhoto == nil) { loader(true, LoadType.UpdatingChannel) }
        do {
            let payload = groupChannelUpdateRequest ?? GroupChannelUpdateRequest(name: groupName)
            let channel = try await channelRepository.updateChannel(channelID: channelID, groupChannelUpdateRequest: payload)
            DispatchQueue.main.async {
                self.channel = channel
                self.channelName = channel.name
                self.groupName = channel.name
                self.isOpenSheetChangeChanelName = false
            }
            saveChannel(channel: channel)
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        if (avatarPhoto == nil) { loader(false, LoadType.UpdatingChannel) }
    }
    
    private func uploadAvatar() async {
        loader(true, LoadType.UpdatingChannel)
        do {
            var multipart = MultipartRequest()
            let fileName = UUID().uuidString
            guard let extensionFile = avatarPhoto?.extensionFile else { return }
            guard let fileMimeType = avatarPhoto?.mimeType else { return }
            guard let data = avatarPhoto?.data else { return }
            
            multipart.add(
                key: "files",
                fileName: "\(fileName).\(extensionFile)",
                fileMimeType: fileMimeType,
                fileData: data
            )
            
            let resources = try await resourceRepository.uploadAvatar(multipart: multipart)
            guard let resourceID = resources.first?.id.uuidString.lowercased() else { return }
            await updateGroupChannel(GroupChannelUpdateRequest(name: groupName, avatar: resourceID))
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, LoadType.UpdatingChannel)
    }
}

extension GroupChannelViewModel {
    func onSelectedFriends(_ id: UUID, _ isSelected: Bool) {
        if (isSelected) {
            selectedFriends.append(id.uuidString)
        } else {
            if let index = selectedFriends.firstIndex(of: id.uuidString) {
                selectedFriends.remove(at: index)
            }
        }
    }
    
    private func saveChannel(channel: Channel) {
        let _ = channel.asChannelEntity(context: context)
        try? context.performAndWait {
            try coreDataProvider.persist(in: context)
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
            self.avatarPhoto = nil
            self.isUpdatingChannel = false
        }
    }
    
    private func loader(_ value: Bool, _ caseLoader: LoadCase? = nil) {
        DispatchQueue.main.async {
            switch caseLoader! {
            case LoadType.UpdatingChannel:
                self.isUpdatingChannel = value
                break
            case LoadType.LoadingListFriend:
                self.isLoadingListFriend = value
            case LoadType.LoadMoreListFriend:
                self.isLoadMoreListFriend = value
            case LoadType.AddingMembers:
                self.isAddingMembers = value
            case LoadType.RemovingMembers:
                self.isRemovingMembers = value
            default:
                break
            }
        }
    }
    
    private func resetPage() {
        self._page = 0
    }
    
    private func resetData() {
        DispatchQueue.main.async {
            self.channel = nil
            self.channelName = ""
            self.avatarPhoto = nil
            self.isUpdatingChannel = false
            self.shouldSave = false
            self.members.removeAll()
            self.myRole = nil
            self.friends.removeAll()
            self.selectedFriends.removeAll()
        }
    }
}
