//
//  ChannelGroupRequest.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 30/11/2023.
//

import Foundation

struct ChannelGroupRequest: Codable, JSONEncodable {
    let groupName: String
    let memberIDs: [String]
}
