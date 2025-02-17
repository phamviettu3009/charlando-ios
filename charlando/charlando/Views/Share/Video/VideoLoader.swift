//
//  VideoLoader.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 04/03/2024.
//

import Foundation
import AVKit

class VideoLoader: ObservableObject {
    @Published var player: AVPlayer?
    private var url: String
    
    init(url: String) {
        self.url = url
        
        let queue = DispatchQueue(label: "queue_io_video_loader")
        queue.async {
            self.loadVideo()
        }
    }
    
    private func loadVideo() {
        if let cachedVideo = VideoCache.shared.get(forKey: url) {
            DispatchQueue.main.async {
                self.player = cachedVideo
            }
            return
        }
        
        guard let url = URL(string: url) else { return }
        
        let token = APIManager.shared.getToken()
        let headers: [String: String] = [
            "Authorization": "Bearer \(token)"
        ]
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        let playerItem = AVPlayerItem(asset: asset)
        
        DispatchQueue.main.async {
            self.player = AVPlayer(playerItem: playerItem)
        }
        
        self.downloadVideo(url: self.url)
    }
    
    private func downloadVideo(url: String) {
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        let token = APIManager.shared.getToken()
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        var task: URLSessionDataTask?
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            VideoCache.shared.set(data, forKey: self.url)
        }
        task?.resume()
    }
}

extension VideoLoader {
    static func getResource(_ value: String) -> String {
        return BASE_URL + GET_RESOURCE_ENDPOINT + value.lowercased()
    }
}

