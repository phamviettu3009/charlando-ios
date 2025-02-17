//
//  Device.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 15/04/2024.
//

import Foundation

struct Device: Codable {
    var deviceID: String
    var deviceName: String
    var deviceSystemName: String
    var os: String
    var userID: UUID
    var login: Bool
    var mostRecentLoginTime: Date?
    var mostRecentLogoutTime: Date?
    var mostRecentLoginTimeDisplay: String?
    var mostRecentLogoutTimeDisplay: String?
    
    enum CodingKeys: String, CodingKey {
        case deviceID
        case deviceName
        case deviceSystemName
        case os
        case userID
        case login
        case mostRecentLoginTime
        case mostRecentLogoutTime
        case mostRecentLoginTimeDisplay
        case mostRecentLogoutTimeDisplay
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.deviceID = try container.decode(String.self, forKey: .deviceID)
        self.deviceName = try container.decode(String.self, forKey: .deviceName)
        self.deviceSystemName = try container.decode(String.self, forKey: .deviceSystemName)
        self.os = try container.decode(String.self, forKey: .os)
        self.userID = try container.decode(UUID.self, forKey: .userID)
        self.login = try container.decode(Bool.self, forKey: .login)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "dd/MM/yyyy : HH:mm"
        
        if let loginTimeString = try container.decodeIfPresent(String.self, forKey: .mostRecentLoginTime) {
            let date = dateFormatter.date(from: loginTimeString)
            self.mostRecentLoginTime = date
            if let date = date {
                self.mostRecentLoginTimeDisplay = dateStringFormatter.string(from: date)
            }
        } else {
            self.mostRecentLoginTime = nil
            self.mostRecentLoginTimeDisplay = nil
        }
        
        if let logoutTimeString = try container.decodeIfPresent(String.self, forKey: .mostRecentLogoutTime) {
            let date = dateFormatter.date(from: logoutTimeString)
            self.mostRecentLogoutTime = date
            if let date = date {
                self.mostRecentLogoutTimeDisplay = dateStringFormatter.string(from: date)
            }
        } else {
            self.mostRecentLogoutTime = nil
            self.mostRecentLogoutTimeDisplay = nil
        }
    }
}
