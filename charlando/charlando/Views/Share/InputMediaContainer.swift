//
//  InputMediaContainer.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 22/02/2024.
//

import Foundation
import SwiftUI
import PhotosUI

struct InputMediaContainer: View {
    @State private var showCamera: Bool = false
    @State private var showRecording: Bool = false
    @State var imageFromCamera: UIImage?
    @Binding var photoItems: [PhotoItem]
    
    var onSendRecording: (URL, String) -> ()

    var body: some View {
        HStack(spacing: 10) {
            Button() {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    showCamera = true
                }
            } label: {
                Image(systemName: "camera.fill")
                    .foregroundColor(.accentColor)
            }
            .fullScreenCover(isPresented: $showCamera) {
                AccessCameraView(selectedImage: self.$imageFromCamera)
            }
            .onChange(of: imageFromCamera) { newValue in
                guard let data = newValue?.jpegData(compressionQuality: 1) else { return }
                guard let image = newValue else { return }
                DispatchQueue.main.async {
                    photoItems.append(PhotoItem(
                        type: AttachmentType.IMAGE,
                        data: data,
                        value: image,
                        mimeType: "image/jpeg",
                        extensionFile: "jpeg"
                    ))
                }
            }
            
            GalleryPickerView(content: {
                Image(systemName: "photo.fill")
                    .foregroundColor(.accentColor)
            }, filter: .any(of: [.images, .videos, .screenshots, .screenRecordings]), selectionLimit: 10) { values in
                photoItemsConverter(values: values)
            }
            
            Button() {
                showRecording = true
            } label: {
                Image(systemName: "mic.fill")
                    .foregroundColor(.accentColor)
            }
            .fullScreenCover(isPresented: $showRecording) {
                RecordView(
                    onClose: { showRecording = false },
                    onSendRecording: { url, fileName in onSendRecording(url, fileName) }
                )
            }
        }
    }
}

extension InputMediaContainer {
    private func photoItemsConverter(values: [(URL, Data)]) {
        for (url, data) in values {
            let extensionFile = url.pathExtension
            guard let mimeType = getMimeType(fileExtension: extensionFile) else { return }
            
            DispatchQueue.main.async {
                if(mimeType.contains("image")) {
                    guard let uiImage = UIImage(data: data) else { return }
                    photoItems.append(PhotoItem(
                        type: AttachmentType.IMAGE,
                        data: data,
                        value: uiImage,
                        mimeType: mimeType,
                        extensionFile: extensionFile
                    ))
                }
                
                if(mimeType.contains("video")) {
                    photoItems.append(PhotoItem(
                        type: AttachmentType.VIDEO,
                        data: data,
                        value: AVPlayer(url: url),
                        mimeType: mimeType,
                        extensionFile: extensionFile
                    ))
                }
            }
        }
    }
}
