//
//  MessageListener.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 10/04/2024.
//

import Foundation

enum MessagePayload: Equatable {
    case removeChannel(channelID: UUID)
}

class MessageListener: ObservableObject {
    @Published var message: MessagePayload? = nil
}
