//
//  FirebaseDeviceToken.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 25/04/2024.
//

import Foundation

struct FirebaseDeviceToken: Codable, JSONEncodable {
    var deviceID: String
    var firebaseToken: String
}
