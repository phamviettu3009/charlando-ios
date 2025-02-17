//
//  Avatar.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/02/2024.
//

import Foundation
import SwiftUI

struct Avatar: View {
    var avatars: [String?]
    var size: CGFloat
    var online: Bool = false
    
    var body: some View {
        ZStack {
            if avatars.count == 1 {
                SingleAvatar(avatar: avatars[0], size: size, online: online)
            } else {
                GroupAvatar(avatar1: avatars[0], avatar2: avatars[1], size: size)
            }
            
            if online {
                Circle()
                    .frame(width: size / 5, height: size / 5)
                    .foregroundColor(Color.green)
                    .offset(x: size / 2.941, y: size / 2.941)
                    .overlay(
                        Circle()
                            .stroke(.background, lineWidth: 2)
                            .offset(x: size / 2.941, y: size / 2.941)
                    )
            }
        }
    }
}

