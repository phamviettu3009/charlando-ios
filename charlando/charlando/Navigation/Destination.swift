//
//  Destination.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 13/11/2023.
//

import Foundation

enum Destination: Hashable {
    case messageScreen(channelID: UUID)
    case register
    case createGroupChannel
    case groupChannel(channelID: UUID)
    case userInfo(userID: UUID)
    case requestAddFriend
    case deviceManager
    case changePassword
    case forgotPassword
}
