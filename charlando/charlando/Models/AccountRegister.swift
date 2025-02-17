//
//  AccountRegister.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/02/2024.
//

import Foundation

struct AccountRegister: Encodable, JSONEncodable {
    var user: String
    var password: String
    var tenantCode: String
    
    init(user: String, password: String, tenantCode: String) {
        self.user = user
        self.password = password
        self.tenantCode = tenantCode
    }
}
