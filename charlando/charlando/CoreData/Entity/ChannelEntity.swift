//
//  ChannelEntity.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 20/02/2024.
//

import Foundation
import CoreData

@objc(Channel)
final class ChannelEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var type: Int32
    @NSManaged public var avatarsData: Data?
    @NSManaged public var recordStatus: String?
    @NSManaged public var read: Bool
    @NSManaged private var messageData: Data?
    @NSManaged private var readersData: Data?
    @NSManaged public var unreadCounter: Int
    @NSManaged public var sort: Date
    @NSManaged public var keywords: String
    
    var avatars: [String] {
        get {
            do {
                guard let data = avatarsData else { return [] }
                return try JSONDecoder().decode([String].self, from: data)
            } catch {
                return []
            }
        }
        set {
            let data = newValue.description.data(using: String.Encoding.utf16)
            avatarsData = data
        }
    }
    
    var message: ShortenMessage? {
        get {
            guard let data = messageData else { return nil }
            return try? JSONDecoder().decode(ShortenMessage.self, from: data)
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                messageData = data
            } else {
                messageData = nil
            }
        }
    }
    
    var readers: [Reader]? {
        get {
            guard let data = readersData else { return nil }
            return try? JSONDecoder().decode([Reader].self, from: data)
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                readersData = data
            } else {
                readersData = nil
            }
        }
    }
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Channel", in: context)!
        self.init(entity: entity, insertInto: context)
    }
}

extension ChannelEntity {
    private static var channelFetchRequest: NSFetchRequest<ChannelEntity> {
        NSFetchRequest(entityName: "Channel")
    }
    
    static func findAll(page: Int = 1, search: String? = nil) -> NSFetchRequest<ChannelEntity> {
        let request: NSFetchRequest<ChannelEntity> = channelFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \ChannelEntity.sort,
                ascending: false
            )
        ]
        
        let pageSize: Int = SIZE_PER_PAGE
        let offset = (page - 1) * pageSize
        request.fetchOffset = max(0, offset)
        request.fetchLimit = pageSize
    
        if let search = search, !search.isEmpty {
            var predicates: [NSPredicate] = []
            // Tìm kiếm theo trường "name"
            let namePredicate = NSPredicate(format: "name CONTAINS[c] %@", search)
            predicates.append(namePredicate)
            
            // Tìm kiếm theo trường "keywords"
            let keywordsPredicate = NSPredicate(format: "keywords CONTAINS[c] %@", search)
            predicates.append(keywordsPredicate)
            
            let finalPredicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
            request.predicate = finalPredicate
        }
        return request
    }
    
    static func findAll(quantity: Int, search: String? = nil) -> NSFetchRequest<ChannelEntity> {
        let request: NSFetchRequest<ChannelEntity> = channelFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \ChannelEntity.sort,
                ascending: false
            )
        ]
        
        request.fetchLimit = max(0, quantity)
    
        if let search = search, !search.isEmpty {
            var predicates: [NSPredicate] = []
            // Tìm kiếm theo trường "name"
            let namePredicate = NSPredicate(format: "name CONTAINS[c] %@", search)
            predicates.append(namePredicate)
            
            // Tìm kiếm theo trường "keywords"
            let keywordsPredicate = NSPredicate(format: "keywords CONTAINS[c] %@", search)
            predicates.append(keywordsPredicate)
            
            let finalPredicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
            request.predicate = finalPredicate
        }
        return request
    }
    
    static func findByID(channelID: UUID) -> NSFetchRequest<ChannelEntity> {
        let request: NSFetchRequest<ChannelEntity> = channelFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \ChannelEntity.sort,
                ascending: false
            )
        ]
        
        let channelIDPredicate = NSPredicate(format: "id == %@", channelID as CVarArg)
        request.predicate = channelIDPredicate
        
        return request
    }
}

extension [ChannelEntity] {
    func asListChannel() -> [Channel] {
        return self.map { it in
            Channel(
                id: it.id,
                name: it.name,
                type: Int(it.type),
                avatars: it.avatars,
                recordStatus: it.recordStatus,
                read: it.read,
                online: false,
                message: it.message,
                readers: it.readers ?? [],
                unreadCounter: it.unreadCounter,
                sort: it.sort.description,
                keywords: it.keywords
            )
        }
    }
}

extension ChannelEntity {
    func asChannel() -> Channel? {
        return [self].asListChannel().first
    }
}
