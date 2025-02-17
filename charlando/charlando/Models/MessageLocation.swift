//
//  LocationMessage.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 23/02/2024.
//

import Foundation

struct MessageLocation: Encodable, Decodable, JSONEncodable {
    var lat: Double = 0.0
    var lng: Double = 0.0
}
