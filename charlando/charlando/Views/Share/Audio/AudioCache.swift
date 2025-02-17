//
//  AudioCache.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 09/03/2024.
//

import Foundation
import AVFoundation

class AudioCache {
    static let shared = AudioCache()
    
    private let cache = NSCache<NSString, AVAudioPlayer>()
    private let fileManager = FileManager.default
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func set(_ data: Data, forKey key: String, completion: @escaping (URL) -> Void = {_ in }) {
        let sanitizedKey = sanitizeFileName(key + ".m4a")
        let fileURL = documentsDirectory.appendingPathComponent(sanitizedKey)
        do {
            try data.write(to: fileURL)
            completion(fileURL)
        } catch {
            print("Error saving AVAudioPlayer to disk: \(error.localizedDescription)")
        }
    }
    
    func get(forKey key: String) -> AVAudioPlayer? {
        // Kiểm tra cache trước
        if let cachedVideo = cache.object(forKey: key as NSString) {
            return cachedVideo
        }
        
        // Nếu không có trong cache, kiểm tra đĩa
        let sanitizedKey = sanitizeFileName(key + ".m4a")
        let fileURL = documentsDirectory.appendingPathComponent(sanitizedKey)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            guard let player = try? AVAudioPlayer(contentsOf: fileURL) else { return nil }
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
}
