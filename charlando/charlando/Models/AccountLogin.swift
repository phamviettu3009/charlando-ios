//
//  Account.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 11/11/2023.
//

import Foundation

struct AccountLogin: Encodable, JSONEncodable {
    var user: String
    var password: String
    var tenantCode: String
    var deviceID: String
    var deviceName: String
    var deviceSystemName: String
    var os: String
    var description: String
    
    init(user: String, password: String, tenantCode: String, deviceID: String, deviceName: String, deviceSystemName: String, os: String, description: String) {
        self.user = user
        self.password = password
        self.tenantCode = tenantCode
        self.deviceID = deviceID
        self.deviceName = deviceName
        self.deviceSystemName = deviceSystemName
        self.os = os
        self.description = description
    }
}



