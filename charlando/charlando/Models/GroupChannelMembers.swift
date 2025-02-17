//
//  GroupChannelMembers.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 13/03/2024.
//

import Foundation

struct GroupChannelMembers: Codable, JSONEncodable {
    var memberIDs: [UUID]
}
