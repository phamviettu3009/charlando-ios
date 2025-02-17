//
//  RecordView.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 09/03/2024.
//

import Foundation
import SwiftUI
import AVFoundation

struct RecordView: View {
    @State private var recordingTime = 0
    @State private var timer: Timer?
    @State private var isRecording: Bool = false
    
    @State private var isPlaying = false
    @State private var totalTime: TimeInterval = 0.0
    @State private var currentTime: TimeInterval = 0.0
    @State private var isFinishRecording: Bool = false
    
    var onClose: () -> ()
    var onSendRecording: (URL, String) -> ()
    
    let fileRecordName: String = UUID().uuidString
    var recorder: ARecorder = ARecorder.shared

    init(onClose: @escaping () -> (), onSendRecording: @escaping (URL, String) -> ()) {
        recorder.setup(fileRecordName: fileRecordName)
        self.onClose = onClose
        self.onSendRecording = onSendRecording
    }
    
    var body: some View {
        Color(UIColor.systemBackground).ignoresSafeArea()
            .overlay {
                VStack {
                    HStack {
                        Button {
                            onClose()
                        } label: {
                            Text(LocalizedStringKey("cancel"))
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                        
                        if isFinishRecording {
                            Button {
                                guard let url = recorder.audioRecorder?.url else { return }
                                onSendRecording(url, fileRecordName)
                                onClose()
                            } label: {
                                Text(LocalizedStringKey("send"))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    Spacer()
                    
                    if isFinishRecording {
                        RemoteAudio(url: fileRecordName)
                    }
                    
                    Text(LocalizedStringKey("recording_time \(formattedTime(recordingTime))") )
                        .padding()
                    
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 69, height: 69)
                        Circle()
                            .fill(Color(UIColor.systemBackground))
                            .frame(width: 60, height: 60)
                            .overlay(
                                ZStack {
                                    Circle()
                                        .stroke(Color(UIColor.systemBackground), lineWidth: 3)
                                    if(isRecording) {
                                        Rectangle()
                                            .fill(Color.red)
                                            .frame(width: 30, height: 30)
                                            .cornerRadius(10)
                                            .transition(.scale)
                                        
                                    } else {
                                        Circle()
                                            .fill(.red)
                                            .frame(width: 57, height: 57)
                                            .transition(.scale)
                                    }
                                    
                                }
                            )
                    }
                    .onTapGesture {
                        withAnimation {
                            if(isRecording) {
                                stopRecording()
                            } else {
                                guard !isFinishRecording else { return }
                                startRecording()
                            }
                        }
                    }
                    .onDisappear {
                        recorder.cancel()
                    }
                    .opacity(isFinishRecording ? 0.5 : 1)
                }
            }
    }
    
    private func startRecording() {
        isRecording = true
        recorder.startRecording()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordingTime += 1
        }
    }
    
    private func stopRecording() {
        isRecording = false
        recorder.stopRecording()
        isFinishRecording = true
        timer?.invalidate()
        timer = nil
    }
    
    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
