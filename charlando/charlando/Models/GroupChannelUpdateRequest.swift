//
//  GroupChannelUpdateRequest.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 12/03/2024.
//

import Foundation

struct GroupChannelUpdateRequest: Codable, JSONEncodable {
    var name: String? = nil
    var avatar: String? = nil
}
