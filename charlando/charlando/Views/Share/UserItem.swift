//
//  UserItem.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 27/11/2023.
//

import Foundation
import SwiftUI

struct UserItem: View {
    var user: User
    var role: String? = nil
    
    init(user: User) {
        self.user = user
    }
    
    init(member: Member) {
        self.user = member.asUser()
        self.role = member.role
    }
    
    var body: some View {
        HStack {
            if let avatar = user.avatar {
                RemoteImage(url: ImageLoader.getAvatar(avatar))
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .foregroundColor(Color(UIColor.label))
                    .lineLimit(1)
                if let role = role {
                    Text(LocalizedStringKey(role.lowercased()))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .font(.system(size: 13))
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
