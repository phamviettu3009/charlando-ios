//
//  UserUpdateRequest.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 19/03/2024.
//

import Foundation

struct UserUpdateRequest: Codable, JSONEncodable {
    var fullName: String? = nil
    var avatar: String? = nil
    var coverPhoto: String? = nil
    var gender: String? = nil
    var dob: String? = nil
    var phone: String? = nil
    var email: String? = nil
    var countryCode: String? = nil
    var languageCode: String? = nil
}
