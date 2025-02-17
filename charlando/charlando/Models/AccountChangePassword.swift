//
//  AccountChangePassword.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/04/2024.
//

import Foundation

struct AccountChangePassword: Codable, JSONEncodable {
    var tenantCode: String
    var oldPassword: String
    var newPassword: String
}
