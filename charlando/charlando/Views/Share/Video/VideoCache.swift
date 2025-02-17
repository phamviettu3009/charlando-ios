//
//  CacheVideo.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 04/03/2024.
//

import Foundation
import AVKit

class VideoCache {
    static let shared = VideoCache()
    
    private let cache = NSCache<NSString, AVPlayer>()
    private let fileManager = FileManager.default
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func set(_ data: Data, forKey key: String, completion: @escaping (URL) -> Void = {_ in }) {
        let sanitizedKey = sanitizeFileName(key)
        let fileURL = documentsDirectory.appendingPathComponent(sanitizedKey + ".mp4")
        do {
            try data.write(to: fileURL)
            completion(fileURL)
        } catch {
            print("Error saving AVPlayer to disk: \(error.localizedDescription)")
        }
    }
    
    func get(forKey key: String) -> AVPlayer? {
        // Kiểm tra cache trước
        if let cachedVideo = cache.object(forKey: key as NSString) {
            return cachedVideo
        }
        
        // Nếu không có trong cache, kiểm tra đĩa
        let sanitizedKey = sanitizeFileName(key + ".mp4")
        let fileURL = documentsDirectory.appendingPathComponent(sanitizedKey)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let player = AVPlayer(url: fileURL)
            // Lưu vào cache để sử dụng cho lần sau
            cache.setObject(player, forKey: key as NSString)
            return player
        }

        return nil
    }
    
    private func sanitizeFileName(_ fileName: String) -> String {
        let invalidFileNameCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>")
        return fileName.components(separatedBy: invalidFileNameCharacters).joined(separator: "_")
    }
    
    func generateThumbnail(for url: URL, at seconds: Int, forKey key: String) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        let time = CMTime(seconds: Double(seconds), preferredTimescale: 1)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            ImageCache.shared.set(uiImage, forKey: key)
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
        }
    }
}
