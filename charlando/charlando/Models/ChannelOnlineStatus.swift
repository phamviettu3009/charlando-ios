//
//  ChannelOnlineStatus.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 05/04/2024.
//

import Foundation

struct ChannelOnlineStatus: Codable {
    let channelID: UUID
    let online: Bool
}
