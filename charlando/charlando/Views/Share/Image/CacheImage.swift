//
//  CacheImage.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 16/11/2023.
//

import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    private init() {}

    func set(_ image: UIImage, forKey key: String) {
        // Lưu vào cache
        cache.setObject(image, forKey: key as NSString)
        
        // Lưu vào đĩa
        let sanitizedKey = sanitizeFileName(key)
        let fileURL = documentsDirectory.appendingPathComponent(sanitizedKey)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: fileURL)
                print("Image saved to disk at path: \(fileURL.path)")
            } catch {
                print("Error saving image to disk: \(error.localizedDescription)")
            }
        }
    }

    func get(forKey key: String) -> UIImage? {
        // Kiểm tra cache trước
        if let cachedImage = cache.object(forKey: key as NSString) {
            return cachedImage
        }
        
        // Nếu không có trong cache, kiểm tra đĩa
        let sanitizedKey = sanitizeFileName(key)
        let fileURL = documentsDirectory.appendingPathComponent(sanitizedKey)
        if let imageData = try? Data(contentsOf: fileURL),
           let diskImage = UIImage(data: imageData) {
            // Lưu vào cache để sử dụng cho lần sau
            cache.setObject(diskImage, forKey: key as NSString)
            return diskImage
        }
        
        return nil
    }
    
    func clearCache() {
        // Xóa cache trong bộ nhớ
        cache.removeAllObjects()
        
        // Xóa cache trên đĩa
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
                print("Deleted cached file: \(fileURL.path)")
            }
        } catch {
            print("Error clearing disk cache: \(error.localizedDescription)")
        }
    }
    
    private func sanitizeFileName(_ fileName: String) -> String {
        let invalidFileNameCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>")
        return fileName.components(separatedBy: invalidFileNameCharacters).joined(separator: "_")
    }
}
