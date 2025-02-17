//
//  Account.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/02/2024.
//

import Foundation

struct Account: Encodable, JSONEncodable {
    var user: String
    var tenantCode: String
}
