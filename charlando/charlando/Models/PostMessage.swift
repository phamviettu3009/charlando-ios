//
//  PostMessage.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 23/02/2024.
//

import Foundation

struct PostMessage: Encodable, Decodable, JSONEncodable {
    var message: String?
    var messageLocation: MessageLocation?
    var deviceLocalTime: String?
    var iconMessage: String?
    var replyID: String?
    var attachmentIDs: [String]?
    var messageReaction: String?
    var syncID: UUID
}
