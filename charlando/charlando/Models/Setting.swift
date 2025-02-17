//
//  Setting.swift
//  2lab
//
//  Created by Phạm Việt Tú on 19/06/2024.
//

import Foundation

struct Setting: Codable, Hashable, JSONEncodable {
    var publicEmail: Bool
    var publicGender: Bool
    var publicPhone: Bool
    var publicDob: Bool
}
