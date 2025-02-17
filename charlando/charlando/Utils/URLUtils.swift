//
//  URLUtils.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 01/03/2024.
//

//import Foundation
//import _PhotosUI_SwiftUI
//
//class URLUtils {
//    // MARK: - getURL
//    static func getURL(item: PhotosPickerItem, completionHandler: @escaping (_ result: Result<URL, Error>) -> Void) {
//        item.loadTransferable(type: Data.self) { result in
//            switch result {
//            case .success(let data):
//                if let contentType = item.supportedContentTypes.first {
//                    let fileName = "\(UUID().uuidString).\(contentType.preferredFilenameExtension ?? "")"
//                    let url = getDocumentsDirectory().appendingPathComponent(fileName)
//                    if let data = data {
//                        do {
//                            try data.write(to: url)
//                            completionHandler(.success(url))
//                        } catch {
//                            completionHandler(.failure(error))
//                        }
//                    }
//                }
//            case .failure(let failure):
//                completionHandler(.failure(failure))
//            }
//        }
//    }
//    
//    static func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return paths[0]
//    }
//}
