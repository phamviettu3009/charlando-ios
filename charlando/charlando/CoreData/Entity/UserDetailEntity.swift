//
//  UserDetailEntity.swift
//  charlando
//
//  Created by Phạm Việt Tú on 26/07/2024.
//

import Foundation
import CoreData

@objc(UserDetail)
final class UserDetailEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var friend: Int
    @NSManaged public var relationshipStatus: String?
    @NSManaged public var channelID: UUID?
    @NSManaged public var gender: String?
    @NSManaged public var dob: Date?
    @NSManaged public var phone: String?
    @NSManaged public var email: String?
    @NSManaged public var countryCode: String?
    @NSManaged public var languageCode: String?
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "UserDetail", in: context)!
        self.init(entity: entity, insertInto: context)
    }
}

extension UserDetailEntity {
    private static var userDetailFetchRequest: NSFetchRequest<UserDetailEntity> {
        NSFetchRequest(entityName: "UserDetail")
    }
    
    static func findByID(userID: UUID) -> NSFetchRequest<UserDetailEntity> {
        let request: NSFetchRequest<UserDetailEntity> = userDetailFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \UserDetailEntity.id,
                ascending: false
            )
        ]
        
        let userDetailIDPredicate = NSPredicate(format: "id == %@", userID as CVarArg)
        request.predicate = userDetailIDPredicate
        
        return request
    }
}
