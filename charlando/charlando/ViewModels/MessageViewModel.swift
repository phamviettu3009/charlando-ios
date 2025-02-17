//
//  MessageViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 01/12/2023.
//

import Foundation
import SwiftUI
import Combine
import CoreData
import PhotosUI
import SocketIO

class MessageViewModel: ViewModel {
    private let coreDataProvider = CoreDataProvider.shared
    private let syncManager = SyncManager.shared
    private var context: NSManagedObjectContext
    private let socket: SocketIOClient = SocketIOManager.shared.socket
    private var cancellables = Set<AnyCancellable>()
    
    private let channelRepository: ChannelRepository = ChannelRepositoryImpl.shared
    private let messageRepository: MessageRepository = MessageRepositoryImpl.shared
    
    enum LoadType: LoadCase {
        case LoadingListMessage
    }
    
    private var _page: Int = 0
    private var ownerID: UUID?
    
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var isOpenAlertDeleteMessage: Bool = false
    @Published var deleteID: UUID? = nil
    @Published var sendMode: SendMode = .New
    @Published var isOpenMessageReactionContainer: Bool = false
    @Published var isOpenInputExpandContainer: Bool = false
    @Published var messageSelected: Message? = nil
    @Published var isOpenFullScreenAttachment: Bool = false
    @Published var attachments: [Attachment] = []
    @Published var attachmentTab: Attachment? = nil
    @Published var channelID: UUID
    @Published var search: String = ""
    @Published var isLoadingListMessage: Bool = false
    @Published var messages: [Message] = []
    @Published var inputMessage: String = ""
    @Published var photoItems: [PhotoItem] = []
    @Published var channel: Channel? = nil
    @Published var userReaders: [UserAvatar] = []
    @Published var onScreen: Bool = false
    @Published var typing: Bool = false
    @Published var usersTyping: [User] = []
    
    init(channelID: UUID) {
        context = coreDataProvider.newContext
        self.channelID = channelID
        typingListener()
        getUser()
        fetchListMessage()
        messageListener()
        Task(priority: .background) {
            try await syncManager.findAllEventAndSync(context)
        }
    }
    
    // MARK: - [PUT, POST, DELETE] MESSAGE
    
    private func syncData(_ context: NSManagedObjectContext, _ eventEntity: EventEntity) {
        Task(priority: .background) {
            try await syncManager.syncController(context: context, eventEntity: eventEntity)
            syncDone()
        }
    }
    
    func sendMessageController() {
        switch sendMode {
        case .Update(let messageID):
            updateMessage(messageID: messageID)
        case .New:
            sendMessage()
        case .Attachment:
            sendMessageWithAttachments()
        case .Reply(let reply):
            sendMessage(reply: reply)
        }
    }
    
    func sendMessage(icon: String? = nil, reply: Reply? = nil) {
        let inputMessageTemp = inputMessage
        if (inputMessageTemp.isEmpty && icon == nil) { return }
        
        let messageEntity = MessageEntity(
            context: context,
            channelID: channelID,
            message: inputMessageTemp,
            iconMessage: icon
        )
        
        if let reply = reply {
            messageEntity.reply = reply
        }
        
        let eventEntity = EventEntity(
            context: context,
            requestID: channelID,
            syncTarget: EventEntity.SYNC_TARGET_NEW_MESSAGE,
            payload: messageEntity.asPostMessage()
        )
        
        eventEntity.id = messageEntity.id
        
        messages.insert(messageEntity.asMessage(), at: 0)
        try? context.performAndWait {
            try coreDataProvider.persist(in: context)
            syncData(context, eventEntity)
        }
        
        onCloseInputExpandContainer()
        userReaders.removeAll()
    }
    
    func sendMessageReaction(messageID: UUID, messageReactionIcon: String) {
        let messageRequest = MessageEntity.findMessageByID(messageID: messageID)
        if var messageEntity: MessageEntity = try? context.fetch(messageRequest).first {
            messageEntity.sync = false
            messageEntity = updateMessageReaction(
                messageEntity: messageEntity,
                messageReactionIcon: messageReactionIcon
            )
            
            context.performAndWait {
                try? coreDataProvider.persist(in: context)
                reloadMessages()
            }
            
            let eventRequest = EventEntity.findByRequestIDAndSyncTarget(
                requestID: messageEntity.id,
                syncTarget: EventEntity.SYNC_TARGET_MESSAGE_REACTION
            )
            
            if let sameEventEntity = try? context.fetch(eventRequest).first {
                try? coreDataProvider.delete(sameEventEntity, in: context)
            } else {
                let eventEntity = EventEntity(
                    context: context,
                    requestID: messageEntity.id,
                    syncTarget: EventEntity.SYNC_TARGET_MESSAGE_REACTION,
                    payload: PostMessageReaction(icon: messageReactionIcon)
                )
                
                context.performAndWait {
                    try? coreDataProvider.persist(in: context)
                    syncData(context, eventEntity)
                }
            }
        }
    }
    
    func updateMessage(messageID: UUID) {
        let inputMessageTemp = inputMessage
        let messageRequest = MessageEntity.findMessageByID(messageID: messageID)
        if let messageEntity: MessageEntity = try? context.fetch(messageRequest).first {
            messageEntity.message = inputMessageTemp
            messageEntity.sync = false
            
            context.performAndWait {
                try? coreDataProvider.persist(in: context)
                reloadMessages()
            }
            
            let eventRequest = EventEntity.findByRequestIDAndSyncTarget(
                requestID: messageEntity.id,
                syncTarget: EventEntity.SYNC_TARGET_UPDATE_MESSAGE
            )
            
            if let sameEventEntity = try? context.fetch(eventRequest).first {
                try? coreDataProvider.delete(sameEventEntity, in: context)
            }
            
            let eventEntity = EventEntity(
                context: context,
                requestID: messageEntity.id,
                syncTarget: EventEntity.SYNC_TARGET_UPDATE_MESSAGE,
                payload: PutMessage(
                    message: inputMessage,
                    messageLocation: LocationSendMessage(lat: 0.0, lng: 0.0),
                    deviceLocalTime: Date().asStringDate()
                )
            )
            
            context.performAndWait {
                try? coreDataProvider.persist(in: context)
                syncData(context, eventEntity)
            }
        }
        onCloseInputExpandContainer()
    }
    
    func deleteMessage(messageID: UUID?, syncTarget: String) {
        if (messageID == nil) { return }
        let messageRequest = MessageEntity.findMessageByID(messageID: messageID!)
        if let messageEntity: MessageEntity = try? context.fetch(messageRequest).first {
            let subMessage = switch syncTarget {
            case EventEntity.SYNC_TARGET_DELETE_MESSAGE_FOR_ALL:
                "delete_for_all"
            case EventEntity.SYNC_TARGET_DELETE_MESSAGE_FOR_OWNER:
                "delete_for_owner"
            default:
                ""
            }
            
            messageEntity.recordStatus = MessageRecordStatus.DELETE
            messageEntity.subMessage = subMessage
            messageEntity.messageReactions = nil
            messageEntity.reply = nil
            messageEntity.attachments = nil
            messageEntity.sync = false
            
            context.performAndWait {
                try? coreDataProvider.persist(in: context)
                reloadMessages()
            }
            
            let eventEntity = EventEntity(
                context: context,
                requestID: messageEntity.id,
                syncTarget: syncTarget
            )
            
            context.performAndWait {
                try? coreDataProvider.persist(in: context)
                syncData(context, eventEntity)
            }
            
            deleteID = nil
        }
    }
    
    func sendMessageWithAttachments() {
        let inputMessageTemp = inputMessage
        Task {
            var multipart = MultipartRequest()
            
            let messageEntity = MessageEntity(
                context: context,
                channelID: channelID,
                message: inputMessageTemp
            )
            messageEntity.type = Int32(MessageType.ATTACHMENTS)
            messageEntity.sync = false
            
            var tempAttachments: [Attachment] = []
            
            for item in photoItems {
                let resourceID = UUID()
                let type = item.type
                let fileName = UUID().uuidString
                let extensionFile = item.extensionFile
                let fileMimeType = item.mimeType
                
                if(type == AttachmentType.IMAGE) {
                    let image = item.value as! UIImage
                    ImageCache.shared.set(image, forKey: ImageLoader.getResource(resourceID.uuidString))
                    tempAttachments.append(Attachment(id: resourceID, type: AttachmentType.IMAGE))
                }
                
                if(type == AttachmentType.VIDEO) {
                    let videoData = item.data
                    VideoCache.shared.set(videoData, forKey: ImageLoader.getResource(resourceID.uuidString)) { url in
                        VideoCache.shared.generateThumbnail(for: url, at: 1, forKey: ImageLoader.getThumbnail(resourceID.uuidString))
                    }
                    tempAttachments.append(Attachment(id: resourceID, type: AttachmentType.VIDEO))
                }
                
                multipart.add(
                    key: "files",
                    fileName: "\(fileName).\(extensionFile)",
                    fileMimeType: fileMimeType,
                    fileData: item.data
                )
            }
            
            messageEntity.attachments = tempAttachments
            context.performAndWait {
                try? coreDataProvider.persist(in: context)
                reloadMessages()
            }
            
            let eventEntity = EventEntity(
                context: context,
                requestID: UUID(),
                syncTarget: EventEntity.SYNC_TARGET_ATTACHMENT,
                payload: multipart
            )
            
            eventEntity.setChildEvent(childEvent: ChildEvent(
                id: UUID(),
                requestID: channelID,
                payloadData: messageEntity.asPostMessage().asJson(),
                syncTarget: EventEntity.SYNC_TARGET_NEW_MESSAGE,
                makerDate: Date()
            ))
            
            context.performAndWait {
                try? coreDataProvider.persist(in: context)
                syncData(context, eventEntity)
            }
        }
        onCloseInputExpandContainer()
    }
    
    func sendRecording(url: URL, fileName: String) {
        var multipart = MultipartRequest()
        
        let messageEntity = MessageEntity(
            context: context,
            channelID: channelID,
            message: ""
        )
        messageEntity.type = Int32(MessageType.ATTACHMENTS)
        messageEntity.sync = false
        
        let fileName = UUID().uuidString
        guard let data = try? Data(contentsOf: url) else { return }
        multipart.add(
            key: "files",
            fileName: "\(fileName).m4a",
            fileMimeType: "audio/m4a",
            fileData: data
        )
        
        guard let attachmentID = UUID(uuidString: fileName) else { return }
        messageEntity.attachments = [Attachment(id: attachmentID, type: AttachmentType.AUDIO)]
        context.performAndWait {
            try? coreDataProvider.persist(in: context)
            reloadMessages()
        }
        
        let eventEntity = EventEntity(
            context: context,
            requestID: UUID(),
            syncTarget: EventEntity.SYNC_TARGET_ATTACHMENT,
            payload: multipart
        )
        
        eventEntity.setChildEvent(childEvent: ChildEvent(
            id: UUID(),
            requestID: channelID,
            payloadData: messageEntity.asPostMessage().asJson(),
            syncTarget: EventEntity.SYNC_TARGET_NEW_MESSAGE,
            makerDate: Date()
        ))
        
        context.performAndWait {
            try? coreDataProvider.persist(in: context)
            syncData(context, eventEntity)
        }
    }
    
    private func readMessage() async {
        guard let firstMessage = messages.first else { return }
        let messageID = firstMessage.id
        if let userReaders = try? await messageRepository.readMessage(messageID: messageID) {
            DispatchQueue.main.async {
                self.userReaders = userReaders.filter { reader in reader.userID != self.ownerID }
            }
        }
    }
    
    // MARK: - FETCH MESSAGE
    
    private func fetchListMessage() {
        _page += 1
        fetchListMessageFromCoreData(page: _page)
        
        Task(priority: .background) {
            await fetchListMessageFromAPIs(page: _page)
        }
    }
    
    private func fetchListMessageFromCoreData(page: Int) {
        do {
            let messageRequest = MessageEntity.findAllByChannelID(channelID: channelID, quantity: SIZE_PER_PAGE_MESSAGE * page)
            let data: [MessageEntity] = try context.fetch(messageRequest)
            let listMessage = data.asListMessage()
            updateListMessageValueAfterFetch(data: listMessage, loadType: LoadType.LoadingListMessage)
        } catch {
            
        }
    }
    
    private func fetchListMessageFromAPIs(page: Int) async {
        do {
            let messages = try await messageRepository.getListMessage(
                channelID: self.channelID,
                page: page,
                keyword: self.search
            )
            saveListMessage(messages: messages)
            if page == 1 { await readMessage() }
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func loadMoreListMessage() {
        fetchListMessage()
    }
    
    private func reloadMessages() {
        fetchListMessageFromCoreData(page: _page)
    }
    
    // MARK: - FETCH CHANNEL
    
    func fetchChanelFromCoreData() {
        let channelRequest = ChannelEntity.findByID(channelID: channelID)
        if let data: ChannelEntity = try? context.fetch(channelRequest).first {
            DispatchQueue.main.async {
                self.channel = data.asChannel()
                self.channel?.online = ConnectivityManager.shared.getChannelConnectivityStatus(
                    channelID: self.channelID
                )
            }
        }
    }
    
    func fetchChannelFromAPIs(onError: (_ channelID: UUID) -> Void) async {
        do {
            let channel = try await channelRepository.getChannel(channelID: channelID)
            DispatchQueue.main.async {
                self.channel = channel
            }
        } catch {
            if case let ResultError.apiError(apiError) = error {
                if (apiError?.message == "Permission denied!") {
                    onError(channelID)
                }
                putMessage(apiError?.message)
            }
        }
    }
    
    // MARK: - FETCH USER INFO
    
    private func getUser() {
        let ownerRequest = OwnerEntity.findOwner()
        if let ownerEntity: OwnerEntity = try? context.fetch(ownerRequest).first {
            ownerID = ownerEntity.id
        }
    }
    
    // MARK: - SOCKET.IO
    
    private func messageListener() {
        let channelID = channelID.uuidString.lowercased()
        socket.on("new-message/channel/\(channelID)") { data, ack in
            if let messageJson: String = data.first as? String {
                self.updateMessage(messageJson: messageJson)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if (self.onScreen) {
                    Task { await self.readMessage() }
                }
            }
        }
        
        socket.on("message-reaction/channel/\(channelID)") { data, ack in
            if let messageJson: String = data.first as? String {
                self.updateMessage(messageJson: messageJson)
            }
        }
        
        socket.on("update-message/channel/\(channelID)") { data, ack in
            if let messageJson: String = data.first as? String {
                self.updateMessage(messageJson: messageJson)
            }
        }
        
        socket.on("delete-message/channel/\(channelID)") { data, ack in
            if let messageJson: String = data.first as? String {
                self.updateMessage(messageJson: messageJson)
            }
        }
        
        socket.on("reader-message/channel/\(channelID)") { data, ack in
            if let readerJson: String = data.first as? String {
                guard let messageData = readerJson.data(using: .utf8) else { return }
                do {
                    let readers = try JSONDecoder().decode([UserAvatar].self, from: messageData)
                    DispatchQueue.main.async {
                        self.userReaders = readers.filter { reader in reader.userID != self.ownerID }
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        }
        
        socket.on("typing/channel/\(channelID)") { data, ack in
            if let typingJson: String = data.first as? String {
                do {
                    guard let typingData = typingJson.data(using: .utf8) else { return }
                    let typing = try JSONDecoder().decode(TypingResponse.self, from: typingData)
                    DispatchQueue.main.async {
                        if (typing.typing) {
                            self.usersTyping.append(typing.user)
                        } else {
                            self.usersTyping.removeAll { user in
                                user.id == typing.user.id
                            }
                        }
                    }
                } catch {
                    print("error: \(error)")
                }
            }
        }
    }
    
    func onTyping(isTyping: Bool) {
        if (isTyping != typing) {
            do {
                let channelIDString = channelID.uuidString.lowercased()
                let dict: [String: Any] = ["channelID": channelIDString, "typing": isTyping]
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    socket.emit("typing", jsonString)
                }
            } catch {
                print("Error:", error)
            }
        }
    }
}

extension MessageViewModel {
    private func typingListener() {
        $inputMessage
            .sink { [weak self] message in
                if (!message.isEmpty) {
                    self?.onTyping(isTyping: true)
                    self?.typing = true
                } else {
                    self?.onTyping(isTyping: false)
                    self?.typing = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateMessage(messageJson: String) {
        guard let messageData = messageJson.data(using: .utf8) else { return }
        do {
            let message = try JSONDecoder().decode(Message.self, from: messageData)
            self.saveListMessage(messages: [message])
        } catch {
            print("error: \(error)")
        }
    }
    
    func onCloseInputExpandContainer() {
        DispatchQueue.main.async {
            self.isOpenInputExpandContainer = false
            self.sendMode = .New
            self.inputMessage = ""
        }
    }
    
    func onPressMessageAction(action: String, message: Message) {
        let messageID = message.id
        switch action {
        case "Edit":
            isOpenInputExpandContainer = true
            inputMessage = message.message ?? ""
            sendMode = .Update(messageID: messageID)
            break
        case "Delete":
            isOpenAlertDeleteMessage = true
            deleteID = messageID
            break
        case "Reply":
            isOpenInputExpandContainer = true
            sendMode = .Reply(reply: message.asReply())
            break
        case "Copy":
            UIPasteboard.general.string = message.message
            break
        default:
            break
        }
    }
    
    private func syncDone() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.reloadMessages()
        }
    }
    
    private func saveListMessage(messages: [Message]) {
        let _ = messages.asListMessageEntity(context: context)
        try? context.performAndWait {
            try coreDataProvider.persist(in: context)
            fetchListMessageFromCoreData(page: _page)
        }
    }
    
    private func updateListMessageValueAfterFetch(data: [Message], loadType: LoadType) {
        DispatchQueue.main.async {
            switch loadType {
            case LoadType.LoadingListMessage:
                self.messages = data
                self.updateListAttachmentAfterFetch(data: data)
                break
            }
        }
    }
    
    private func updateListAttachmentAfterFetch(data: [Message]) {
        var result: [Attachment] = []
        for message in data {
            if let attachments: [Attachment] = message.attachments {
                result.insert(contentsOf: attachments, at: 0)
            }
        }
        DispatchQueue.main.async {
            self.attachments.insert(contentsOf: result, at: 0)
        }
    }
    
    private func updateMessageReaction(messageEntity: MessageEntity, messageReactionIcon: String) -> MessageEntity {
        let messageReactionIndex = messageEntity.messageReactions?.firstIndex { $0.icon == messageReactionIcon }
        
        if (messageReactionIndex == nil) {
            let messageReaction = MessageReaction(icon: messageReactionIcon, quantity: 1, toOwn: true)
            if (messageEntity.messageReactions == nil) {
                messageEntity.messageReactions = [messageReaction]
            } else {
                messageEntity.messageReactions?.append(messageReaction)
            }
        } else {
            let index = messageReactionIndex!
            let toOwn = messageEntity.messageReactions![index].toOwn
            
            if(toOwn) {
                messageEntity.messageReactions![index].quantity -= 1
            } else {
                messageEntity.messageReactions![index].quantity += 1
            }
            
            messageEntity.messageReactions![index].toOwn = !toOwn
            messageEntity.messageReactions![index].icon = messageReactionIcon

            if(messageEntity.messageReactions![index].quantity <= 0) {
                messageEntity.messageReactions?.remove(at: messageReactionIndex!)
            }
            
            if(messageEntity.messageReactions!.isEmpty) {
                messageEntity.messageReactions = nil
            }
        }
        
        return messageEntity
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
            case LoadType.LoadingListMessage:
                self.isLoadingListMessage = value
                break
            default:
                break
            }
        }
    }
    
    private func resetInputMessage() {
        DispatchQueue.main.async {
            self.inputMessage = ""
        }
    }
    
    private func resetPage() {
        _page = 0
    }
    
    private func resetData() {
        DispatchQueue.main.async {
            self.isOpenAlertDeleteMessage = false
            self.deleteID = nil
            self.sendMode = .New
            self.isOpenMessageReactionContainer = false
            self.isOpenInputExpandContainer = false
            self.messageSelected = nil
            self._page = 0
            self.message = nil
            self.messageColor = .red
            self.isLoadingListMessage = false
            self.messages.removeAll()
            self.search = ""
            self.isOpenFullScreenAttachment = false
            self.attachments.removeAll()
            self.attachmentTab = nil
            self.inputMessage = ""
            self.photoItems.removeAll()
            self.channel = nil
            self.userReaders.removeAll()
        }
    }
}

enum SendMode {
    case Update(messageID: UUID)
    case New
    case Attachment
    case Reply(reply: Reply)
}
