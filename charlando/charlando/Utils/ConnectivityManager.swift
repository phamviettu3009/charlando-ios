//
//  OnlineStatusManager.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 08/04/2024.
//

import Foundation

class ConnectivityManager {
    static let shared = ConnectivityManager()
    
    private var channelStatusHashMap: [UUID : Bool] = [:]
    
    func addChannelConnectivityStatus(channels: [Channel]) async {
        for channel in channels {
            channelStatusHashMap[channel.id] = channel.online
        }
    }
    
    func getChannelConnectivityStatus(channelID: UUID) -> Bool {
        return channelStatusHashMap[channelID] ?? false
    }
    
    func updateChannelConnectivityStatus(channelID: UUID, status: Bool) {
        channelStatusHashMap[channelID] = status
    }
    
    func assignChannelConnectivityStatus(channels: [Channel]) -> [Channel] {
        let channels: [Channel] = channels.map { channel in
            var newChannel = channel
            newChannel.online = ConnectivityManager.shared.getChannelConnectivityStatus(channelID: channel.id)
            return newChannel
        }
        
        return channels
    }
}
