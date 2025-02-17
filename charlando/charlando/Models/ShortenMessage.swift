//
//  ShortenMessage.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/02/2024.
//

import Foundation
import CoreData

struct ShortenMessage: Codable, Hashable {
    var id: UUID
    var type: Int
    var recordStatus: String?
    var message: String?
    var subMessage: String?
    var iconMessage: String?
    var timeOfMessageSentDisplay: String
    var channelID: UUID
}
