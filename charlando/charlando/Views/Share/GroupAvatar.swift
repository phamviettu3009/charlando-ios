//
//  GroupAvatar.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 28/11/2023.
//

import Foundation
import SwiftUI

struct GroupAvatar: View {
    var avatar1: String?
    var avatar2: String?
    var size: CGFloat
    
    init(avatar1: String?, avatar2: String?, size: CGFloat) {
        self.avatar1 = avatar1
        self.avatar2 = avatar2
        self.size = size
    }
    
    var body: some View {
        ZStack {
            SingleAvatar(avatar: avatar1, size: size / 1.75)
                .offset(x: -(size / 5), y: -(size / 2.5))
            SingleAvatar(avatar: avatar2, size: size / 1.2)
                .offset(x: 0)
        }
        .frame(width: size, height: size)
    }
}

struct GroupAvatar_Preview: PreviewProvider {
    static var previews: some View {
        GroupAvatar(
            avatar1: "empty_avatar_user.jpg", avatar2: "empty_avatar_user.jpg", size: 50
        )
    }
}

