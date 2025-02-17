//
//  Attachment.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 28/11/2023.
//

import Foundation

struct Attachment: Codable, Hashable {
    var id: UUID
    var type: Int
}

extension [Attachment] {
    func asListStringID() -> [String] {
        return self.map { it in
            it.id.uuidString
        }
    }
}
