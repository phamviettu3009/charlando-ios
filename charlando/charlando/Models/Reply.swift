//
//  ReplyFromMessage.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 28/11/2023.
//

import Foundation

struct Reply: Codable, Hashable {
    var id: UUID
    var type: Int
    var message: String?
    var attachments: [Attachment]?
}
