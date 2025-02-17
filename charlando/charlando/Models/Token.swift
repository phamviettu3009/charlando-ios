//
//  Token.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 10/11/2023.
//

import Foundation

struct Token: Codable {
    var refreshToken: String
    var accessToken: String
}

extension Token {
    func asData() -> Data? {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(self)
        return data
    }
}
