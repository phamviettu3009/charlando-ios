//
//  Movie.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 01/03/2024.
//

//import Foundation
//import SwiftUI
//import PhotosUI
//import AVKit
//
//struct Movie: Transferable {
//    let url: URL
//    let data: Data
//    
//    static var transferRepresentation: some TransferRepresentation {
//        FileRepresentation(contentType: .movie) { movie in
//            SentTransferredFile(movie.url)
//        } importing: { receivedData in
//            let fileName = receivedData.file.lastPathComponent
//            let copy: URL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
//            
//            if FileManager.default.fileExists(atPath: copy.path) {
//                try FileManager.default.removeItem(at: copy)
//            }
//            
//            try FileManager.default.copyItem(at: receivedData.file, to: copy)
//            
//            let data = try Data(contentsOf: copy)
//            
//            return .init(url: copy, data: data)
//        }
//    }
//}
