//
//  OwnerEntity.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 26/03/2024.
//

import Foundation
import CoreData

@objc(Owner)
final class OwnerEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var fullName: String
    @NSManaged public var avatar: String?
    @NSManaged public var online: Bool
    @NSManaged public var coverPhotoUrl: String?
    @NSManaged public var gender: String?
    @NSManaged public var dob: Date?
    @NSManaged public var phone: String?
    @NSManaged public var email: String?
    @NSManaged public var countryCode: String?
    @NSManaged public var languageCode: String?
    @NSManaged public var settingData: Data?
    
    var setting: Setting? {
        get {
            guard let data = settingData else { return nil }
            return try? JSONDecoder().decode(Setting.self, from: data)
        }
        set {
            if let newValue = newValue {
                let data = try? JSONEncoder().encode(newValue)
                settingData = data
            } else {
                settingData = nil
            }
        }
    }
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Owner", in: context)!
        self.init(entity: entity, insertInto: context)
    }
}

extension OwnerEntity {
    private static var ownerFetchRequest: NSFetchRequest<OwnerEntity> {
        NSFetchRequest(entityName: "Owner")
    }
    
    static func findOwner() -> NSFetchRequest<OwnerEntity> {
        let request: NSFetchRequest<OwnerEntity> = ownerFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \OwnerEntity.fullName,
                ascending: false
            )
        ]
        
        return request
    }
}

extension OwnerEntity {
    func asUser() -> User {
        return User(
            id: self.id,
            fullName: self.fullName,
            avatar: self.avatar,
            online: self.online,
            coverPhoto: self.coverPhotoUrl,
            gender: self.gender,
            dob: self.dob?.asStringDate(),
            phone: self.phone,
            email: self.email,
            countryCode: self.countryCode,
            languageCode: self.languageCode,
            setting: self.setting
        )
    }
}
