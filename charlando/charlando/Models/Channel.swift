//
//  Channel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 28/11/2023.
//

import Foundation
import CoreData

struct Channel: Codable, Hashable {
    var id: UUID
    var name: String
    var type: Int
    var avatars: [String]
    var recordStatus: String?
    var read: Bool
    var online: Bool
    var message: ShortenMessage?
    var readers: [Reader]
    var unreadCounter: Int
    var sort: String
    var keywords: String
}

extension [Channel] {
    func asListChannelEntity(context: NSManagedObjectContext) -> [ChannelEntity] {   
        return self.map { it in
            let channelEntity = ChannelEntity(context: context)
            channelEntity.id = it.id
            channelEntity.name = it.name
            channelEntity.type = Int32(it.type)
            channelEntity.avatars = it.avatars
            channelEntity.recordStatus = it.recordStatus
            channelEntity.read = it.read
            channelEntity.message = it.message
            channelEntity.readers = it.readers
            channelEntity.unreadCounter = it.unreadCounter 
            channelEntity.sort = it.sort.asDate()
            channelEntity.keywords = it.keywords
            
            return channelEntity
        }
    }
}

extension Channel {
    func asChannelEntity(context: NSManagedObjectContext) -> ChannelEntity {
        return [self].asListChannelEntity(context: context).first!
    }
}
