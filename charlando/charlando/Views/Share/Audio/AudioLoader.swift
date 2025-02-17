//
//  AudioLoader.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 09/03/2024.
//

import Foundation
import AVFoundation

class AudioLoader: ObservableObject {
    @Published var player: AVAudioPlayer?
    private var url: String
    
    init(url: String) {
        self.url = url
        
        let queue = DispatchQueue(label: "queue_io_audio_loader")
        queue.async {
            self.loadAudio()
        }
    }
    
    private func loadAudio() {
        if let cachedAudio = AudioCache.shared.get(forKey: url) {
            DispatchQueue.main.async {
                self.player = cachedAudio
            }
            return
        }
        
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        let token = APIManager.shared.getToken()
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        var task: URLSessionDataTask?
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            guard let audio = try? AVAudioPlayer(data: data) else { return }
            DispatchQueue.main.async {
                self.player = audio
            }
            AudioCache.shared.set(data, forKey: self.url)
        }
        task?.resume()
    }
}

extension AudioLoader {
    static func getResource(_ value: String) -> String {
        return BASE_URL + GET_RESOURCE_ENDPOINT + value.lowercased()
    }
}
