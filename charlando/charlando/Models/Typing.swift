//
//  Typing.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 11/04/2024.
//

import Foundation
import SocketIO

struct Typing: SocketData {
    var channelID: UUID
    var typing: Bool
    
    func socketRepresentation() -> SocketData {
        return ["channelID": channelID, "typing": typing]
    }
}
