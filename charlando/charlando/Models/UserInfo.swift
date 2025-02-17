//
//  UserInfo.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 16/03/2024.
//

import Foundation
import CoreData

struct UserInfo: Codable {
    var id: UUID
    var fullName: String
    var avatar: String?
    var online: Bool
    var relationshipStatus: String?
    var friend: Int
    var channelID: UUID?
    var coverPhoto: String?
    var gender: String?
    var dob: String?
    var phone: String?
    var email: String?
    var countryCode: String?
    var languageCode: String?
}

extension UserInfo {
    func asUserEntity(context: NSManagedObjectContext) -> UserEntity {
        let userEntity = UserEntity(context: context)
        userEntity.id = id
        userEntity.fullName = fullName
        userEntity.avatar = avatar
        userEntity.coverPhoto = coverPhoto
        userEntity.isFriend = true
        
        return userEntity
    }
    
    func asUserDetailEntity(context: NSManagedObjectContext) -> UserDetailEntity {
        let userDetailEntity = UserDetailEntity(context: context)
        userDetailEntity.id = id
        userDetailEntity.relationshipStatus = relationshipStatus
        userDetailEntity.friend = friend
        userDetailEntity.channelID = channelID
        userDetailEntity.gender = gender
        userDetailEntity.dob = dob?.asDate()
        userDetailEntity.phone = phone
        userDetailEntity.email = email
        userDetailEntity.countryCode = countryCode
        userDetailEntity.languageCode = languageCode
        
        return userDetailEntity
    }
}
