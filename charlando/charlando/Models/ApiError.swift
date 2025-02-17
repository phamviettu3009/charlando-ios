//
//  ErrorApi.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 11/11/2023.
//

import Foundation

struct ApiError: Decodable {
    var timestamp: String
    var status: Int
    var error: String
    var message: String
    var path: String
    
    init(timestamp: String, status: Int, error: String, message: String, path: String) {
        self.timestamp = timestamp
        self.status = status
        self.error = error
        self.message = message
        self.path = path
    }
}
