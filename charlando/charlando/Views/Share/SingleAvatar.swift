//
//  SingleAvatar.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 28/11/2023.
//

import Foundation
import SwiftUI

struct SingleAvatar: View {
    var avatar: String?
    var size: CGFloat
    var online: Bool = false
    
    var body: some View {
        if let avatar = avatar {
            RemoteImage(url: ImageLoader.getAvatar(avatar))
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
    }
}
