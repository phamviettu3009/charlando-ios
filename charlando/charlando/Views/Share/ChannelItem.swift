//
//  ChannelItem.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 28/11/2023.
//

import Foundation
import SwiftUI

struct ChannelItem: View {
    @Binding var channel: Channel
    
    var body: some View {
        HStack {
            Avatar(
                avatars: channel.avatars, 
                size: 50,
                online: channel.online
            )
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(channel.name)
                        .foregroundColor(Color(UIColor.label))
                        .lineLimit(1)
                        .font(.system(size: 17, weight: .medium))
                    Spacer()
                    if let timeOfMessageSentDisplay = channel.message?.timeOfMessageSentDisplay {
                        Text(LocalizedStringKey(timeOfMessageSentDisplay))
                            .foregroundColor(Color(UIColor.label))
                            .lineLimit(1)
                            .opacity(0.5)
                            .font(.system(size: 14))
                    }
                }
                
                VStack {
                    HStack {
                        content(channel)
                        Spacer()
                        if (channel.unreadCounter != 0) {
                            ZStack {
                                Text(String(channel.unreadCounter))
                                    .lineLimit(1)
                                    .font(.system(size: 13))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .foregroundColor(.white)
                            }
                            .clipShape(Circle())
                            .frame(height: 16)
                            .background(.red)
                            .cornerRadius(8)
                        }
                    }
                    
                    Divider()
                }
            }
        }
    }
    
    @ViewBuilder
    private func content(_ channel: Channel) -> some View {
        if (channel.message?.recordStatus == MessageRecordStatus.DELETE) {
            Text(LocalizedStringKey(channel.message?.subMessage ?? ""))
                .foregroundColor(.red)
                .font(.system(size: 14))
        } else {
            switch channel.message?.type {
            case MessageType.MESSAGE:
                if let message = channel.message?.message {
                    Text(message)
                        .foregroundColor(Color(UIColor.label))
                        .lineLimit(1)
                        .font(.system(size: 14, weight: channel.read == true ? .light: .bold))
                }
            case MessageType.ATTACHMENTS:
                HStack {
                    Image(systemName: "paperclip")
                        .foregroundColor(Color(UIColor.label))
                        .opacity(0.8)
                        .font(.system(size: 14))
                    Text(LocalizedStringKey("attachment"))
                        .foregroundColor(Color(UIColor.label))
                        .lineLimit(1)
                        .font(.system(size: 14))
                        .opacity(0.8)
                }
            case MessageType.ICON_MESSAGE:
                if let iconMessage = channel.message?.iconMessage {
                    Text(iconMessage)
                        .foregroundColor(Color(UIColor.label))
                        .lineLimit(1)
                        .opacity(0.8)
                        .font(.system(size: 14))
                }
            default:
                Text(LocalizedStringKey(channel.type == ChannelType.SINGLE_TYPE ? "new_friend" : "new_group"))
                    .foregroundColor(.accentColor)
                    .font(.system(size: 14))
            }
        }
    }
}
