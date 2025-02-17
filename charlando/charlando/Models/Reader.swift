//
//  Reader.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/02/2024.
//

import Foundation
import CoreData

struct Reader: Codable, Hashable {
    var userID: UUID
    var source: UUID
}
