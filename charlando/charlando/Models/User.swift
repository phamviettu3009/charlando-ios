//
//  User.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 15/11/2023.
//

import Foundation
import CoreData

struct User: Codable, Hashable, Identifiable {
    var id: UUID
    var fullName: String
    var avatar: String?
    var online: Bool
    var coverPhoto: String?
    var gender: String?
    var dob: String?
    var phone: String?
    var email: String?
    var countryCode: String?
    var languageCode: String?
    var setting: Setting?
}

extension [User] {
    func asListUserEntity(context: NSManagedObjectContext) -> [UserEntity] {
        return self.map { it in
            let userEntity = UserEntity(context: context)
            userEntity.id = it.id
            userEntity.fullName = it.fullName
            userEntity.avatar = it.avatar
            userEntity.coverPhoto = it.coverPhoto
            
            return userEntity
        }
    }
    
    func asListFriendEntity(context: NSManagedObjectContext) -> [UserEntity] {
        return self.map { it in
            let userEntity = UserEntity(context: context)
            userEntity.id = it.id
            userEntity.fullName = it.fullName
            userEntity.avatar = it.avatar
            userEntity.coverPhoto = it.coverPhoto
            userEntity.isFriend = true
            
            return userEntity
        }
    }
}

extension User {
    func asUserInfo() -> UserInfo {
        return UserInfo(
            id: self.id, 
            fullName: self.fullName,
            avatar: self.avatar,
            online: self.online,
            relationshipStatus: nil,
            friend: 0,
            channelID: nil
        )
    }
    
    func asOwner(context: NSManagedObjectContext) -> OwnerEntity {
        let ownerEntity = OwnerEntity(context: context)
        ownerEntity.id = self.id
        ownerEntity.fullName = self.fullName
        ownerEntity.avatar = self.avatar
        ownerEntity.online = self.online
        ownerEntity.coverPhotoUrl = self.coverPhoto
        ownerEntity.gender = self.gender
        ownerEntity.dob = self.dob?.asDate()
        ownerEntity.phone = self.phone
        ownerEntity.email = self.email
        ownerEntity.countryCode = self.countryCode
        ownerEntity.languageCode = self.languageCode
        ownerEntity.setting = self.setting
        return ownerEntity
    }
}
