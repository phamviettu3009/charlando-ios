//
//  CoverPhoto.swift
//  2lab
//
//  Created by Phạm Việt Tú on 22/06/2024.
//

import Foundation
import SwiftUI

struct CoverPhotoProfile: View {
    var url: String
    
    var body: some View {
        Group {
            RemoteImage(url: ImageLoader.getResource(url))
        }
        .aspectRatio(contentMode: .fill)
    }
}
