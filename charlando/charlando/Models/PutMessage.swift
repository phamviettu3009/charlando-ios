//
//  PutMessage.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 28/02/2024.
//

import Foundation

struct PutMessage: Codable {
    var message: String?
    var messageLocation: LocationSendMessage?
    var deviceLocalTime: String?
}
