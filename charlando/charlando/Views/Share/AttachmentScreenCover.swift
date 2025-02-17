//
//  AttachmentScreen.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 07/12/2023.
//

import Foundation
import SwiftUI
import Photos

class PhotoSaver: NSObject, ObservableObject {
    @Published var isSaving: Bool = false
    
    func writeImageToPhotoAlbum(url: String) {
        DispatchQueue.main.async {
            self.isSaving = true
        }
        let highQualityURL = ImageLoader.getRawResource(url)
        if let highQualityImage: UIImage = ImageCache.shared.get(forKey: highQualityURL) {
            UIImageWriteToSavedPhotosAlbum(highQualityImage, self, #selector(saveImageCompleted), nil)
        } else {
            let lowQualityURL = ImageLoader.getResource(url)
            if let lowQualityImage: UIImage = ImageCache.shared.get(forKey: lowQualityURL) {
                UIImageWriteToSavedPhotosAlbum(lowQualityImage, self, #selector(saveImageCompleted), nil)
            }
        }
    }
    
    @objc private func saveImageCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            self.isSaving = false
        }
    }
    
    func writeVideoToPhotoAlbum(url: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        DispatchQueue.main.async {
            self.isSaving = true
        }
        let highQualityURL = VideoLoader.getResource(url)
        let sanitizedKey = sanitizeFileName(highQualityURL)
        let fileURL = documentsDirectory.appendingPathComponent(sanitizedKey + ".mp4")
        if let highQualityVideoURL = URL(string: fileURL.absoluteString) {
            saveVideoToPhotoAlbum(videoURL: highQualityVideoURL)
        }
    }
    
    private func saveVideoToPhotoAlbum(videoURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { saved, error in
            DispatchQueue.main.async {
                self.isSaving = false
                if let error = error {
                    print("Error saving video: \(error.localizedDescription)")
                } else if saved {
                    print("Video saved successfully.")
                }
            }
        }
    }
    
    private func sanitizeFileName(_ fileName: String) -> String {
        let invalidFileNameCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>")
        return fileName.components(separatedBy: invalidFileNameCharacters).joined(separator: "_")
    }
}

struct AttachmentScreenCover: View {
    @StateObject var photoSaver: PhotoSaver = PhotoSaver()
    
    @State private var url: String = ""
    @Binding var toggle: Bool
    @Binding var attachment: Attachment?
    @Binding var attachments: [Attachment]
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $url) {
                ForEach(attachments, id: \.self) { value in
                    ZStack(alignment: .top) {
                        AttachmentViewForScreenCover(attachment: value)
                            .frame(maxWidth: UIScreen.main.bounds.width)
                    }
                    .tag(value.id.uuidString)
                }
            }
            .onChange(of: url) { value in
                url = value
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            HStack(alignment: .center) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.red)
                    .onTapGesture {
                        toggle.toggle()
                    }
                
                Spacer()
                
                Button {
                    if photoSaver.isSaving == true { return }
                    let type = attachments.first { $0.id.uuidString == self.url }?.type
                    
                    switch type {
                    case AttachmentType.IMAGE:
                        photoSaver.writeImageToPhotoAlbum(url: self.url)
                    case AttachmentType.VIDEO:
                        photoSaver.writeVideoToPhotoAlbum(url: self.url)
                    default:
                        break
                    }
                } label: {
                    if (photoSaver.isSaving) {
                        ProgressView().id(UUID())
                    } else {
                        Text(LocalizedStringKey("save"))
                            .foregroundColor(.white)
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 100))
            }
            .padding(.horizontal, 20)
        }
        .background(
            Color.black.ignoresSafeArea()
        )
        .onAppear {
            if let id = attachment?.id {
                url = id.uuidString
            }
        }
    }
    
    @ViewBuilder
    func AttachmentViewForScreenCover(attachment: Attachment) -> some View {
        let resourceID = attachment.id
        switch (attachment.type) {
        case AttachmentType.IMAGE:
            RemoteImage(url: ImageLoader.getRawResource(resourceID.uuidString))
                .aspectRatio(contentMode: .fit)
                .clipped()
        case AttachmentType.VIDEO:
            RemoteVideo(url: VideoLoader.getResource(resourceID.uuidString))
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .clipped()
        case AttachmentType.AUDIO:
            RemoteAudio(url: AudioLoader.getResource(resourceID.uuidString))
        default:
            EmptyView()
        }
    }
}
