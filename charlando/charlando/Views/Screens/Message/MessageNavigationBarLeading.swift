//
//  MessageNavigationBar.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 12/03/2024.
//

import Foundation
import SwiftUI

struct MessageNavigationBarLeading: View {
    @EnvironmentObject var navigationManager: NavigationManager
    var channel: Channel?
    
    var body: some View {
        HStack {
            Button {
                navigationManager.back()
            } label: {
                Image(systemName: "chevron.left")
            }
            Group {
                if let avatars = channel?.avatars {
                    Avatar(avatars: avatars, size: avatars.count == 1 ? 40 : 30)
                }
                VStack(alignment: .leading) {
                    if let name = channel?.name {
                        Text(name)
                            .font(.system(size: 16))
                    }
                    if let online = channel?.online {
                        Text(LocalizedStringKey(online ? "online" : "offline"))
                            .font(.system(size: 13))
                            .foregroundColor(online ? .green : Color(UIColor.secondaryLabel))
                    }
                }
            }
            .onTapGesture {
                guard channel?.type == ChannelType.GROUP_TYPE else { return }
                guard let channelID = channel?.id else { return }
                navigationManager.navigateTo(.groupChannel(channelID: channelID))
            }
            Spacer()
        }
        .padding(.bottom, 4)
    }
}
