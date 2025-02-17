//
//  LinkPreview.swift
//  2lab
//
//  Created by Phạm Việt Tú on 18/05/2024.
//

import Foundation
import SwiftUI
import LinkPresentation
import UniformTypeIdentifiers
import CoreData

struct LinkPreview: View {
    let coreDataProvider = CoreDataProvider.shared
    var context: NSManagedObjectContext
    
    @State var image: UIImage?
    @State var title: String?
    @State var url: URL?
    
    let previewURL: URL?
    
    init(_ url: String) {
        self.previewURL = URL(string: url)
        self.context = coreDataProvider.newContext
    }
    
    var body: some View {
        HStack(spacing: 15) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 107, maxHeight: 107)
                    .clipped()
                    .cornerRadius(16)
            }
            
            if let title = title {
                Text(title)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .onAppear {
            fetchMetadata()
        }
        .onTapGesture {
            if let url = url {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func fetchMetadata() {
        guard let previewURL else { return }
        
        if let cachedImage = ImageCache.shared.get(forKey: previewURL.absoluteString) {
            let linkPreviewRequest = LinkPreviewEntity.findByURL(url: previewURL.absoluteString)
            guard let linkPreviewEntity: LinkPreviewEntity = try? context.fetch(linkPreviewRequest).first else { return }
            
            DispatchQueue.main.async {
                self.image = cachedImage
                self.title = linkPreviewEntity.title
                self.url = URL(string: linkPreviewEntity.url)
            }
            return
        }
        
        let provider = LPMetadataProvider()
        
        Task {
            let metadata = try await provider.startFetchingMetadata(for: previewURL)
            
            guard let image = try await convertToImage(metadata.imageProvider) else { return }
            guard let title = metadata.title else { return }
            guard let url = metadata.url else { return }
            
            self.image = image
            self.title = title
            self.url = url
            
            ImageCache.shared.set(image, forKey: previewURL.absoluteString)
            let linkPreviewEntity = LinkPreviewEntity(context: context)
            linkPreviewEntity.title = title
            linkPreviewEntity.url = url.absoluteString
            try? coreDataProvider.persist(in: context)
        }
    }
    
    private func convertToImage(_ imageProvider: NSItemProvider?) async throws -> UIImage? {
        var image: UIImage?
        
        if let imageProvider {
            let type = String(describing: UTType.image)
            
            if imageProvider.hasItemConformingToTypeIdentifier(type) {
                let item = try await imageProvider.loadItem(forTypeIdentifier: type)
                
                if item is UIImage {
                    image = item as? UIImage
                }
                
                if item is URL {
                    guard let url = item as? URL,
                          let data = try? Data(contentsOf: url) else { return nil }
                    
                    image = UIImage(data: data)
                }
                
                if item is Data {
                    guard let data = item as? Data else { return nil }
                    
                    image = UIImage(data: data)
                }
            }
        }
        
        return image
    }
}
