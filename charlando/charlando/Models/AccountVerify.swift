//
//  AccountVerify.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/02/2024.
//

import Foundation

struct AccountVerify: Encodable, JSONEncodable {
    var user: String
    var verifyCode: String
    var tenantCode: String
}
