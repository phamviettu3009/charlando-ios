//
//  RemoteAudio.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 09/03/2024.
//

import Foundation
import SwiftUI

struct RemoteAudio: View {
    @ObservedObject var audioLoader: AudioLoader
    var url: String
    
    @State private var isPlaying = false
    @State private var totalTime: TimeInterval = 0.0
    @State private var currentTime: TimeInterval = 0.0
    
    init(url: String) {
        self.audioLoader = AudioLoader(url: url)
        self.url = url
    }
    
    var body: some View {
        if audioLoader.player != nil {
            HStack {
                if(isPlaying) {
                    Image(systemName: "pause.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 30))
                        .transition(.scale)
                        .onTapGesture {
                            withAnimation { 
                                pauseAudio()
                            }
                        }
                } else {
                    Image(systemName: "play.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 30))
                        .transition(.scale)
                        .onTapGesture {
                            withAnimation {
                                playAudio()
                            }
                            
                        }
                }
                
                Slider(value: Binding(get: {
                    currentTime
                }, set: { newValue in
                    seekAudio(to: newValue)
                }), in: 0...totalTime)
                .accentColor(.white)
                .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                    updateProgress()
                }
            }
            .padding(.horizontal, 8)
            .frame(height: 50)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal, 8)
            .onAppear {
                setup()
            }
            .onDisappear {
                stopAudio()
            }
        }
    }
    
    private func setup() {
        audioLoader.player?.prepareToPlay()
        totalTime = audioLoader.player?.duration ?? 0.0
    }
    
    private func stopAudio() {
        pauseAudio()
        audioLoader.player?.stop()
    }
    
    private func pauseAudio() {
        isPlaying = false
        audioLoader.player?.pause()
    }
    
    private func playAudio() {
        isPlaying = true
        audioLoader.player?.play()
    }
    
    private func seekAudio(to time: TimeInterval) {
        audioLoader.player?.currentTime = time
    }
    
    private func updateProgress() {
        guard isPlaying else { return }
        guard let player = audioLoader.player else { return }
        currentTime = player.currentTime
        if(currentTime == 0.0) {
            withAnimation {
                isPlaying = false
            }
        }
    }
}
