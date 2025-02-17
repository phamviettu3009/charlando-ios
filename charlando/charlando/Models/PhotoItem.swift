//
//  PhotoItem.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 08/03/2024.
//

import Foundation

struct PhotoItem: Equatable, Identifiable {
    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        return lhs.type == rhs.type &&
        lhs.data == rhs.data &&
        lhs.mimeType == rhs.mimeType &&
        lhs.extensionFile == rhs.extensionFile
    }
    
    var id: UUID = UUID()
    var type: Int
    var data: Data
    var value: Any
    var mimeType: String
    var extensionFile: String
}
