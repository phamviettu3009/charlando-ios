//
//  MessageReaction.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/02/2024.
//

import Foundation

struct MessageReaction: Codable, Hashable {
    var icon: String
    var quantity: Int
    var toOwn: Bool
}
