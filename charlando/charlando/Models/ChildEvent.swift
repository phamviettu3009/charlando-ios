//
//  ChildEvent.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 05/03/2024.
//

import Foundation

struct ChildEvent: Codable {
    var id: UUID
    var requestID: UUID
    var payloadData: Data?
    var syncTarget: String
    var makerDate: Date
    var childEvent: Data?
}

extension ChildEvent {
    func asPostMessage() -> PostMessage? {
        if let payloadData = self.payloadData {
            return try? JSONDecoder().decode(PostMessage.self, from: payloadData)
        } else {
            return nil
        }
    }
}
