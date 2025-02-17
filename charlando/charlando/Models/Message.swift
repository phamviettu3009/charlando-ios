//
//  Message.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 28/11/2023.
//

import Foundation
import CoreData

struct Message: Codable, Hashable {
    var id: UUID
    var type: Int
    var message: String?
    var subMessage: String?
    var iconMessage: String?
    var messageOnRightSide: Bool
    var consecutiveMessages: Bool
    var timeOfMessageSentDisplay: String
    var edited: Bool
    var makerDate: String
    var recordStatus: String?
    var channelID: UUID
    var reply: Reply?
    var attachments: [Attachment]?
    var messageReactions: [MessageReaction]?
    var user: User?
    var sync: Bool
    var syncID: UUID?
    var unsent: Bool
    var urlsPreview: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case message
        case subMessage
        case iconMessage
        case messageOnRightSide
        case consecutiveMessages
        case timeOfMessageSentDisplay
        case edited
        case makerDate
        case recordStatus
        case channelID
        case reply
        case attachments
        case messageReactions
        case user
        case sync
        case syncID
        case unsent
        case urlsPreview
    }
    
    init(
        id: UUID,
        type: Int,
        message: String?,
        subMessage: String?,
        iconMessage: String?,
        messageOnRightSide: Bool,
        consecutiveMessages: Bool,
        timeOfMessageSentDisplay: String,
        edited: Bool,
        makerDate: String,
        recordStatus: String?,
        channelID: UUID,
        reply: Reply?,
        attachments: [Attachment]?,
        messageReactions: [MessageReaction]?,
        user: User?,
        sync: Bool,
        syncID: UUID?,
        unsent: Bool,
        urlsPreview: [String]?
    ) {
        self.id = id
        self.type = type
        self.message = message
        self.subMessage = subMessage
        self.iconMessage = iconMessage
        self.messageOnRightSide = messageOnRightSide
        self.consecutiveMessages = consecutiveMessages
        self.timeOfMessageSentDisplay = timeOfMessageSentDisplay
        self.edited = edited
        self.makerDate = makerDate
        self.recordStatus = recordStatus
        self.channelID = channelID
        self.reply = reply
        self.attachments = attachments
        self.messageReactions = messageReactions
        self.user = user
        self.sync = sync
        self.syncID = syncID
        self.unsent = unsent
        self.urlsPreview = urlsPreview
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(Int.self, forKey: .type)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.subMessage = try container.decodeIfPresent(String.self, forKey: .subMessage)
        self.iconMessage = try container.decodeIfPresent(String.self, forKey: .iconMessage)
        self.messageOnRightSide = try container.decode(Bool.self, forKey: .messageOnRightSide)
        self.consecutiveMessages = try container.decode(Bool.self, forKey: .consecutiveMessages)
        self.timeOfMessageSentDisplay = try container.decode(String.self, forKey: .timeOfMessageSentDisplay)
        self.edited = try container.decode(Bool.self, forKey: .edited)
        self.makerDate = try container.decode(String.self, forKey: .makerDate)
        self.recordStatus = try container.decodeIfPresent(String.self, forKey: .recordStatus)
        self.channelID = try container.decode(UUID.self, forKey: .channelID)
        self.reply = try container.decodeIfPresent(Reply.self, forKey: .reply)
        self.attachments = try container.decodeIfPresent([Attachment].self, forKey: .attachments)
        self.messageReactions = try container.decodeIfPresent([MessageReaction].self, forKey: .messageReactions)
        self.user = try container.decodeIfPresent(User.self, forKey: .user)
        self.sync = try container.decode(Bool.self, forKey: .sync)
        self.syncID = try container.decodeIfPresent(UUID.self, forKey: .syncID)
        self.unsent = false
        self.urlsPreview = try container.decodeIfPresent([String].self, forKey: .urlsPreview)
    }
}

extension [Message] {
    func asListMessageEntity(context: NSManagedObjectContext) -> [MessageEntity] {        
        return self.map { it in
            let messageEntity = MessageEntity(context: context)
            messageEntity.id = it.id
            messageEntity.type = Int32(it.type)
            messageEntity.message = it.message
            messageEntity.subMessage = it.subMessage
            messageEntity.iconMessage = it.iconMessage
            messageEntity.messageOnRightSide = it.messageOnRightSide
            messageEntity.consecutiveMessages = it.consecutiveMessages
            messageEntity.timeOfMessageSentDisplay = it.timeOfMessageSentDisplay
            messageEntity.edited = it.edited
            messageEntity.makerDate = it.makerDate.asDate()
            messageEntity.recordStatus = it.recordStatus
            messageEntity.channelID = it.channelID
            messageEntity.reply = it.reply
            messageEntity.attachments = it.attachments
            messageEntity.messageReactions = it.messageReactions
            messageEntity.user = it.user
            messageEntity.sync = true
            messageEntity.unsent = it.unsent
            messageEntity.urlPreview = it.urlsPreview
            
            return messageEntity
        }
    }
}

extension Message {
    func asMessageEntity(context: NSManagedObjectContext) -> MessageEntity {
        return [self].asListMessageEntity(context: context).first!
    }
    
    func asReply() -> Reply {
        return Reply(
            id: self.id,
            type: self.type,
            message: self.message,
            attachments: self.attachments
        )
    }
}
