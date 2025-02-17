//
//  GalleryPicker.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 03/05/2024.
//

import Foundation
import SwiftUI
import PhotosUI

struct GalleryPicker: UIViewControllerRepresentable {
    private let filter: PHPickerFilter
    private let selectionLimit: Int?
    private let onImagePicked: ([(URL, Data)]) -> Void
    
    init(filter: PHPickerFilter, selectionLimit: Int? = nil, onImagePicked: @escaping ([(URL, Data)]) -> Void) {
        self.filter = filter
        self.selectionLimit = selectionLimit
        self.onImagePicked = onImagePicked
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = filter
        
        if let selectionLimit = selectionLimit {
            config.selectionLimit = selectionLimit
        }
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: GalleryPicker
        
        init(_ parent: GalleryPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            var urls: [(URL, Data)] = []
            let itemProviders: [NSItemProvider] = results.map(\.itemProvider)
            
            let dispatchGroup = DispatchGroup()
            
            for itemProvider in itemProviders {
                dispatchGroup.enter()
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                    if let fileURL = url {
                        guard let data = try? Data(contentsOf: fileURL) else { return }
                        urls.append((fileURL, data))
                        dispatchGroup.leave()
                    }
                }
                
                itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let fileURL = url {
                        guard let data = try? Data(contentsOf: fileURL) else { return }
                        urls.append((fileURL, data))
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if (!urls.isEmpty) {
                    self.parent.onImagePicked(urls)
                }
            }
        }
    }
}
