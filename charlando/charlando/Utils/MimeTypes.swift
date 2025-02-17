//
//  MimeTypes.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 03/05/2024.
//

import Foundation
import UniformTypeIdentifiers

func getMimeType(fileExtension: String) -> String? {
    let mimeType = UTType(filenameExtension: fileExtension)?.preferredMIMEType
    return mimeType
}
