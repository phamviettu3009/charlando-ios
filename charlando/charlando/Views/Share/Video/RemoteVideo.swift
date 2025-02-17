//
//  RemoteVideo.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 03/03/2024.
//

import Foundation
import SwiftUI
import AVKit

struct RemoteVideo: View {
    @ObservedObject var videoLoader: VideoLoader
    var url: String
    
    init(url: String) {
        self.videoLoader = VideoLoader(url: url)
        self.url = url
    }
    
    var body: some View {
        if let player = videoLoader.player {
            VideoPlayer(player: player)
                .onDisappear {
                    player.pause()
                }
        } else {
            ProgressView()
        }
    }
}
