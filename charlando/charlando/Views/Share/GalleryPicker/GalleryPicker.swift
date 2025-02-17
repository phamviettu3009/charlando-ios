//
//  ImagePickerView.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 07/03/2024.
//

import Foundation
import SwiftUI

struct GalleryPicker: UIViewControllerRepresentable {
    
    private var sourceType: UIImagePickerController.SourceType
    private let onImagePicked: (UIImage, URL) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    
    public init(sourceType: UIImagePickerController.SourceType, onImagePicked: @escaping (UIImage, URL) -> Void) {
        self.sourceType = sourceType
        self.onImagePicked = onImagePicked
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.delegate = context.coordinator
        
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { self.presentationMode.wrappedValue.dismiss() },
            onImagePicked: self.onImagePicked
        )
    }
    
    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage, URL) -> Void
        
        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage, URL) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }
        
        public func imagePickerController(_ picker: UIImagePickerController,
                                          didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let image = info[.originalImage] as? UIImage else {
                self.onDismiss()
                return
            }
            
            guard let imageUrl = info[.imageURL] as? URL else {
                self.onDismiss()
                return
            }
            
            self.onImagePicked(image, imageUrl)
            
            self.onDismiss()
        }
        
        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }
    }
}
