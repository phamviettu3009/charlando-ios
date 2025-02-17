//
//  MessageEntity.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 22/02/2024.
//

import Foundation
import CoreData

@objc(Message)
final class MessageEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var type: Int32
    @NSManaged public var message: String?
    @NSManaged public var subMessage: String?
    @NSManaged public var iconMessage: String?
    @NSManaged public var messageOnRightSide: Bool
    @NSManaged public var consecutiveMessages: Bool
    @NSManaged public var timeOfMessageSentDisplay: String
    @NSManaged public var edited: Bool
    @NSManaged public var makerDate: Date
    @NSManaged public var recordStatus: String?
    @NSManaged public var channelID: UUID
    @NSManaged public var replyData: Data?
    @NSManaged public var attachmentsData: Data?
    @NSManaged public var messageReactionsData: Data?
    @NSManaged public var userData: Data?
    @NSManaged public var sync: Bool
    @NSManaged public var syncID: UUID?
    @NSManaged public var unsent: Bool
    @NSManaged public var urlsPreviewData: Data?
    
    convenience init(context: NSManagedObjectContext, channelID: UUID, message: String, iconMessage: String? = nil) {
        let entity = NSEntityDescription.entity(forEntityName: "Message", in: context)!
        self.init(entity: entity, insertInto: context)
        
        let type = (iconMessage != nil) ?  3 :  1
        self.id = UUID()
        self.type = Int32(type)
        self.message = message
        self.makerDate = Date()
        self.channelID = channelID
        self.iconMessage = iconMessage
        self.consecutiveMessages = true
        self.timeOfMessageSentDisplay = ""
        self.edited = false
        self.messageOnRightSide = true
        self.sync = false
        self.syncID = UUID()
        self.unsent = true
    }
    
    var reply: Reply? {
        get {
            guard let data = replyData else { return nil }
            return try? JSONDecoder().decode(Reply.self, from: data)
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                replyData = data
            } else {
                replyData = nil
            }
        }
    }
    
    var attachments: [Attachment]? {
        get {
            do {
                guard let data = attachmentsData else { return nil }
                return try JSONDecoder().decode([Attachment].self, from: data)
            } catch {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                attachmentsData = data
            } else {
                attachmentsData = nil
            }
        }
    }
    
    var messageReactions: [MessageReaction]? {
        get {
            do {
                guard let data = messageReactionsData else { return nil }
                return try JSONDecoder().decode([MessageReaction].self, from: data)
            } catch {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                messageReactionsData = data
            } else {
                messageReactionsData = nil
            }
        }
    }
    
    var user: User? {
        get {
            guard let data = userData else { return nil }
            return try? JSONDecoder().decode(User.self, from: data)
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                userData = data
            } else {
                userData = nil
            }
        }
    }
    
    var urlPreview: [String]? {
        get {
            guard let data = urlsPreviewData else { return nil }
            return try? JSONDecoder().decode([String].self, from: data)
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                urlsPreviewData = data
            } else {
                urlsPreviewData = nil
            }
        }
    }
}

extension MessageEntity {
    private static var messageFetchRequest: NSFetchRequest<MessageEntity> {
        NSFetchRequest(entityName: "Message")
    }
    
    static func findAllByChannelID(channelID: UUID, page: Int = 1) -> NSFetchRequest<MessageEntity> {
        let request: NSFetchRequest<MessageEntity> = messageFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \MessageEntity.makerDate,
                ascending: false
            )
        ]
        
        let pageSize: Int = SIZE_PER_PAGE_MESSAGE
        let offset = (page - 1) * pageSize
        request.fetchOffset = max(0, offset)
        request.fetchLimit = pageSize
    
        // Tìm kiếm theo trường "channelID"
        let channelIDPredicate = NSPredicate(format: "channelID == %@", channelID.uuidString)
        request.predicate = channelIDPredicate
        
        return request
    }
    
    static func findAllByChannelID(channelID: UUID, quantity: Int) -> NSFetchRequest<MessageEntity> {
        let request: NSFetchRequest<MessageEntity> = messageFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \MessageEntity.makerDate,
                ascending: false
            )
        ]
        
        // Set the fetch limit to the desired number of items
        request.fetchLimit = max(0, quantity)
        
        // Tìm kiếm theo trường "channelID"
        let channelIDPredicate = NSPredicate(format: "channelID == %@", channelID.uuidString)
        request.predicate = channelIDPredicate
        
        return request
    }
    
    static func findAllMessageAsyncByChannelID(channelID: UUID) -> NSFetchRequest<MessageEntity> {
        let request: NSFetchRequest<MessageEntity> = messageFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \MessageEntity.makerDate,
                ascending: false
            )
        ]
        
        var predicates: [NSPredicate] = []
        // Tìm kiếm theo trường "channelID"
        let channelIDPredicate = NSPredicate(format: "channelID == %@", channelID as CVarArg)
        request.predicate = channelIDPredicate
        
        // Tìm kiếm theo trường "sync"
        let syncPredicate = NSPredicate(format: "sync == %@", NSNumber(value: false))
        predicates.append(syncPredicate)
        
        let finalPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        request.predicate = finalPredicate
        
        return request
    }
    
    static func findMessageByID(messageID: UUID) -> NSFetchRequest<MessageEntity> {
        let request: NSFetchRequest<MessageEntity> = messageFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \MessageEntity.makerDate,
                ascending: false
            )
        ]
        
        let messageIDPredicate = NSPredicate(format: "id == %@", messageID as CVarArg)
        request.predicate = messageIDPredicate
        
        return request
    }
    
    static func findMessageBySyncID(syncID: UUID) -> NSFetchRequest<MessageEntity> {
        let request: NSFetchRequest<MessageEntity> = messageFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \MessageEntity.makerDate,
                ascending: false
            )
        ]
        
        let messageIDPredicate = NSPredicate(format: "syncID == %@", syncID as CVarArg)
        request.predicate = messageIDPredicate
        
        return request
    }

}

extension [MessageEntity] {
    func asListMessage() -> [Message] {
        return self.map { it in
            return Message(
                id: it.id,
                type: Int(it.type),
                message: it.message,
                subMessage: it.subMessage,
                iconMessage: it.iconMessage,
                messageOnRightSide: it.messageOnRightSide,
                consecutiveMessages: it.consecutiveMessages,
                timeOfMessageSentDisplay: it.timeOfMessageSentDisplay,
                edited: it.edited,
                makerDate: it.makerDate.description,
                recordStatus: it.recordStatus,
                channelID: it.channelID,
                reply: it.reply,
                attachments: it.attachments,
                messageReactions: it.messageReactions,
                user: it.user,
                sync: it.sync,
                syncID: it.syncID,
                unsent: it.unsent,
                urlsPreview: it.urlPreview
            )
        }
    }
}

extension MessageEntity {
    func asMessage() -> Message {
        return Message(
            id: self.id,
            type: Int(self.type),
            message: self.message,
            subMessage: self.subMessage,
            iconMessage: self.iconMessage,
            messageOnRightSide: self.messageOnRightSide,
            consecutiveMessages: self.consecutiveMessages,
            timeOfMessageSentDisplay: self.timeOfMessageSentDisplay,
            edited: self.edited,
            makerDate: self.makerDate.description,
            recordStatus: self.recordStatus,
            channelID: self.channelID,
            reply: self.reply,
            attachments: self.attachments,
            messageReactions: self.messageReactions,
            user: self.user,
            sync: self.sync,
            syncID: self.syncID,
            unsent: self.unsent,
            urlsPreview: self.urlPreview
        )
    }
    
    func asPostMessage() -> PostMessage {
        return PostMessage(
            message: self.message,
            messageLocation: MessageLocation(),
            deviceLocalTime: Date().asStringDate(),
            iconMessage: self.iconMessage,
            replyID: self.reply?.id.uuidString,
            messageReaction: nil,
            syncID: self.syncID!
        )
    }
}
