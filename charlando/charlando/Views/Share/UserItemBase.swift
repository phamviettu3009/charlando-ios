//
//  UserItemBase.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 30/11/2023.
//

import Foundation
import SwiftUI

struct UserItemBase: View {
    @Binding var user: User
    
    var body: some View {
        HStack {
            if let avatar = user.avatar {
                RemoteImage(url: ImageLoader.getAvatar(avatar))
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            
            Text(user.fullName)
                .lineLimit(1)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
