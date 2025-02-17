//
//  AccountForgotPassword.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 19/04/2024.
//

import Foundation

struct AccountForgotPassword: Codable, JSONEncodable {
    var user: String
    var tenantCode: String
    var newPassword: String
    var verifyCode: String
}
