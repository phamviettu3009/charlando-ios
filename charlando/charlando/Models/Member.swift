//
//  Member.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 28/11/2023.
//

import Foundation

struct Member: Codable, Hashable {
    var id: UUID
    var fullName: String
    var avatar: String
    var online: Bool
    var role: String
}

extension Member {
    func asUser() -> User {
        return User(id: self.id, fullName: self.fullName, avatar: self.avatar, online: self.online)
    }
}
