//
//  UserEntity.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 22/02/2024.
//

import Foundation
import CoreData

@objc(User)
final class UserEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var fullName: String
    @NSManaged public var avatar: String?
    @NSManaged public var online: Bool
    @NSManaged public var coverPhoto: String?
    @NSManaged public var isFriend: Bool
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)!
        self.init(entity: entity, insertInto: context)
    }
}

extension UserEntity {
    private static var userFetchRequest: NSFetchRequest<UserEntity> {
        NSFetchRequest(entityName: "User")
    }
    
    static func findAll(page: Int = 1, search: String? = nil) -> NSFetchRequest<UserEntity> {
        let request: NSFetchRequest<UserEntity> = userFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \UserEntity.fullName,
                ascending: false
            )
        ]
        
        let pageSize: Int = SIZE_PER_PAGE
        let offset = (page - 1) * pageSize
        request.fetchOffset = max(0, offset)
        request.fetchLimit = pageSize
    
        if let search = search, !search.isEmpty {
            // Tìm kiếm theo trường "fullName"
            let namePredicate = NSPredicate(format: "fullName CONTAINS[c] %@", search)
            request.predicate = namePredicate
        }
        return request
    }
    
    static func findAll(quantity: Int, search: String? = nil) -> NSFetchRequest<UserEntity> {
        let request: NSFetchRequest<UserEntity> = userFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \UserEntity.fullName,
                ascending: false
            )
        ]
        
        request.fetchLimit = max(0, quantity)
    
        if let search = search, !search.isEmpty {
            // Tìm kiếm theo trường "fullName"
            let namePredicate = NSPredicate(format: "fullName CONTAINS[c] %@", search)
            request.predicate = namePredicate
        }
        return request
    }
    
    static func findByID(userID: UUID) -> NSFetchRequest<UserEntity> {
        let request: NSFetchRequest<UserEntity> = userFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \UserEntity.fullName,
                ascending: false
            )
        ]
        
        let userIDPredicate = NSPredicate(format: "id == %@", userID as CVarArg)
        request.predicate = userIDPredicate
        
        return request
    }
    
    static func findAllByIsFriend(quantity: Int, search: String? = nil) -> NSFetchRequest<UserEntity> {
        let request: NSFetchRequest<UserEntity> = userFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \UserEntity.fullName,
                ascending: false
            )
        ]
        
        request.fetchLimit = max(0, quantity)
        
        var predicates: [NSPredicate] = []
        // Tìm kiếm theo trường "isFriend"
        let isFriendPredicate = NSPredicate(format: "isFriend == %@", NSNumber(value: true))
        predicates.append(isFriendPredicate)
        
        if let search = search, !search.isEmpty {
            // Tìm kiếm theo trường "fullName"
            let fullNamePredicate = NSPredicate(format: "fullName CONTAINS[c] %@", search)
            predicates.append(fullNamePredicate)
        }
        
        let finalPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        request.predicate = finalPredicate
        
        return request
    }
}

extension [UserEntity] {
    func asListUser() -> [User] {
        return self.map { it in
            User(
                id: it.id,
                fullName: it.fullName,
                avatar: it.avatar,
                online: it.online,
                coverPhoto: it.coverPhoto
            )
        }
    }
}

extension UserEntity {
    func asUser() -> User {
        return User(id: id, fullName: fullName, avatar: avatar, online: online)
    }
    
    func asUserInfo() -> UserInfo {
        return UserInfo(
            id: id,
            fullName: fullName,
            avatar: avatar,
            online: online,
            relationshipStatus: nil,
            friend: 0,
            channelID: nil,
            coverPhoto: coverPhoto,
            gender: nil,
            dob: nil,
            phone: nil,
            email: nil,
            countryCode: nil,
            languageCode: nil
        )
    }
}
