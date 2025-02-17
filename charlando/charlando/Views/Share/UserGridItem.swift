//
//  UserGridItem.swift
//  2lab
//
//  Created by Phạm Việt Tú on 04/06/2024.
//

import Foundation
import SwiftUI

struct UserGridItem: View {
    var user: User
    var columns: Int
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let avatar = user.avatar {
                if let coverPhoto = user.coverPhoto {
                    CoverPhotoProfile(url: coverPhoto)
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                HStack {
                    Avatar(avatars: [avatar], size: getAvatarSize())
                    Text(user.fullName)
                        .foregroundColor(.white)
                        .font(.system(size: getNameSize()))
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    Color(UIColor.black)
                        .opacity(0.5)
                )
                .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
            }
            
        }
    }
    
    private func getAvatarSize() -> CGFloat {
        switch columns {
        case 1:
            return 60
        case 2:
            return 40
        case 3:
            return 20
        default:
            return 40
        }
    }
    
    private func getNameSize() -> CGFloat {
        switch columns {
        case 1:
            return 18
        case 2:
            return 15
        case 3:
            return 11
        default:
            return 15
        }
    }
}
