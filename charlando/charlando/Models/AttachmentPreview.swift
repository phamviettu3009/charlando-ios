//
//  AttachmentPreview.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 29/02/2024.
//

import Foundation
import PhotosUI
import _PhotosUI_SwiftUI

struct AttachmentPreview: Identifiable {
    let id: UUID = UUID()
    var data: Any
    var type: String
}
