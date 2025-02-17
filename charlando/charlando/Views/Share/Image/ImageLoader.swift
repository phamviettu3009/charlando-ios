//
//  ImageLoader.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 16/11/2023.
//

import Foundation
import UIKit

class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var url: String
    private var task: URLSessionDataTask?

    init(url: String) {
        self.url = url
        
        let queue = DispatchQueue(label: "queue_io_image_loader")
        queue.async {
            self.loadImage()
        }
    }

    private func loadImage() {
        if let cachedImage = ImageCache.shared.get(forKey: url) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }
       
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        let token = APIManager.shared.getToken()
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            let image = UIImage(data: data)

            DispatchQueue.main.async {
                self.image = image
            }
            
            guard image != nil else {
                return
            }
            
            ImageCache.shared.set(image!, forKey: self.url)
        }
        task?.resume()
    }
}

extension ImageLoader {
    static func getAvatar(_ value: String) -> String {
        return BASE_URL + GET_RESOURCE_ENDPOINT + value.lowercased() + "?sizeOption=mobile-avatar"
    }
    
    static func getResource(_ value: String) -> String {
        return BASE_URL + GET_RESOURCE_ENDPOINT + value.lowercased() + "?sizeOption=mobile-image"
    }
    
    static func getThumbnail(_ value: String) -> String {
        return BASE_URL + GET_RESOURCE_ENDPOINT + value.lowercased() + "/thumbnail"
    }
    
    static func getRawResource(_ value: String) -> String {
        return BASE_URL + GET_RESOURCE_ENDPOINT + value.lowercased()
    }
}
