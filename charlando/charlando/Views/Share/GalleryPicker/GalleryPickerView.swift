//
//  GalleryPickerView.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 03/05/2024.
//

import Foundation
import SwiftUI
import PhotosUI

struct GalleryPickerView<Content: View>: View {
    @ViewBuilder var content: () -> Content
    private let filter: PHPickerFilter
    private let selectionLimit: Int?
    private let onImagePicked: ([(URL, Data)]) -> Void
    
    @State private var showPicker: Bool = false
    
    init(content: @escaping () -> Content, filter: PHPickerFilter, selectionLimit: Int? = nil, onImagePicked: @escaping ([(URL, Data)]) -> Void) {
        self.content = content
        self.filter = filter
        self.selectionLimit = selectionLimit
        self.onImagePicked = onImagePicked
    }
    
    var body: some View {
        content()
            .onTapGesture {
                showPicker.toggle()
            }
            .sheet(isPresented: $showPicker) {
                GalleryPicker(filter: filter, selectionLimit: selectionLimit, onImagePicked: onImagePicked)
                    .edgesIgnoringSafeArea(.all)
            }
    }
}
