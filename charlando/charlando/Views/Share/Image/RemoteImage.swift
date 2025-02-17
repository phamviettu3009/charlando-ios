//
//  RemoteImage.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 16/11/2023.
//

import Foundation
import SwiftUI

struct RemoteImage: View, Equatable {
    @ObservedObject var imageLoader: ImageLoader
    var url: String
    var isThumbnail: Bool
    
    static func == (lhs: RemoteImage, rhs: RemoteImage) -> Bool {
        return lhs.url == rhs.url
    }
    
    init(url: String, isThumbnail: Bool = false) {
        imageLoader = ImageLoader(url: url)
        self.url = url
        self.isThumbnail = isThumbnail
    }

    var body: some View {
        if (url == ImageLoader.getAvatar("empty") || url == ImageLoader.getResource("empty")) {
            Image("empty_image").resizable()
        } else {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .overlay {
                        if isThumbnail {
                            AsyncImage(url: URL(string: ""))
                            Image(systemName: "play.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                    }
            } else {
                ProgressView()
            }
        }
    }
}
