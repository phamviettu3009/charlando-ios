//
//  AudioRecorder.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 09/03/2024.
//

import Foundation
import SwiftUI
import AVFoundation

class ARecorder {
    static let shared = ARecorder()
    
    private(set) var audioRecorder: AVAudioRecorder?
    
    func requestRecordPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                // Permission granted
            } else {
                // Handle permission denied
            }
        }
    }
    
    func setupAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default)
        try audioSession.setActive(true)
    }
    
    func setupRecorder(fileRecordName: String) throws {
        let recordingSettings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("\(fileRecordName).m4a")
        
        audioRecorder = try AVAudioRecorder(url: audioFilename, settings: recordingSettings)
        audioRecorder?.prepareToRecord()
    }
    
    func startRecording() {
        audioRecorder?.record()
    }
    
    func stopRecording() {
        audioRecorder?.stop()
    }
    
    func setup(fileRecordName: String) {
        requestRecordPermission()
        try? setupAudioSession()
        try? setupRecorder(fileRecordName: fileRecordName)
    }
    
    func cancel() {
        audioRecorder = nil
    }
    
    func data() -> Data? {
        guard let audioUrl = audioRecorder?.url else { return nil }
        guard let data = try? Data(contentsOf: audioUrl) else { return nil }
        return data
    }
}
