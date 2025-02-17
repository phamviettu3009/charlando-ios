//
//  TypingResponse.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 12/04/2024.
//

import Foundation

struct TypingResponse: Codable {
    var channelID: UUID
    var typing: Bool
    var user: User
}
