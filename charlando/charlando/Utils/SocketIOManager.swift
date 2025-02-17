//
//  SocketIOManager.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 24/03/2024.
//

import Foundation
import SocketIO

class SocketIOManager {
    static let shared = SocketIOManager()
    
    private var manager: SocketManager
    var socket: SocketIOClient
    
    init() {
        manager = SocketManager(socketURL: URL(string: SOCKETIO_URL)!)
        socket = manager.defaultSocket
    }
    
    func setup(completion: () -> Void = {}) {
        let token = APIManager.shared.getToken()
        
        var config = SocketIOClientConfiguration()
        config.insert(.extraHeaders(["Authorization": token]))
        config.insert(.reconnects(true))
        config.insert(.reconnectAttempts(-1))
        config.insert(.log(false))
        config.insert(.compress)
        config.insert(.version(.two))
        
        manager = SocketManager(
            socketURL: URL(string: SOCKETIO_URL)!,
            config: config
        )
        
        socket = manager.defaultSocket
        
        connect()
        
        completion()
    }
    
    func connect() {
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print("socket disconnect")
        }
        
        socket.on(clientEvent: .error) { data, ack in
            print("socket error: \(data.description)")
        }
        
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
}
