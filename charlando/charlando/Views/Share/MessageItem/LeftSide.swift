//
//  LeftSide.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 02/12/2023.
//

import Foundation
import SwiftUI

@ViewBuilder
func LeftSide(message: Message, removeAvatarWhitespace: Bool = false, onTap: @escaping (Attachment) -> Void = {_ in }) -> some View {
    let type: Int? = message.type
    let isDeleted: Bool = message.recordStatus ==  MessageRecordStatus.DELETE
    let shouldShowAvatar: Bool = !message.consecutiveMessages && !removeAvatarWhitespace
    let avatarUrl: String? = message.user?.avatar
    let hasMessageReaction: Bool = message.messageReactions != nil
    let messageReactions = message.messageReactions
    let hasReply: Bool = message.reply != nil
    
    HStack(alignment: .top, spacing: 0) {
        AvatarLeftSide(shouldShowAvatar, removeAvatarWhitespace, avatarUrl)
            .offset(x: 0, y: hasReply ? 20: 0)
        VStack(alignment: .leading) {
            ReplyContent(
                hasReply: hasReply,
                message: message,
                sideWay: SideWayMessageItem.LEFT
            )
            MessageContent(message: message, type: type, isDeleted: isDeleted) {
                if let messageText = message.message, !messageText.isEmpty {
                    Text(messageText)
                        .padding(8)
                        .padding(.leading, 10)
                        .padding(.trailing, 4)
                        .padding(.bottom, (hasMessageReaction && message.type == MessageType.MESSAGE) ? 10 : 0)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(BubbleShapeClone(myMessage: false))
                        .overlay {
                            if (hasReply) {
                                BubbleShapeClone(myMessage: false)
                                    .stroke(.background, lineWidth: 2)
                            }
                        }
                        .frame(maxWidth: UIScreen.main.bounds.width * 2 / 3, alignment: .leading)
                } else {
                    EmptyView()
                }
            } attachmentContent: {
                AttachmentContent(attachments: message.attachments, onTap: onTap)
                    .frame(maxWidth: UIScreen.main.bounds.width * 1 / 2, alignment: .leading)
            } iconMessageContent: {
                if let iconMessage = message.iconMessage {
                    Text(iconMessage)
                        .lineLimit(1)
                        .font(.system(size: 35))
                }
            }
            MessageReactionsContent(
                messageReactions: messageReactions,
                sideWay: SideWayMessageItem.LEFT
            )
            
            if let urlsPreview = message.urlsPreview, !urlsPreview.isEmpty {
                ForEach(urlsPreview, id: \.self) {urlPreview in
                    LinkPreview(urlPreview)
                        .frame(width: UIScreen.main.bounds.width * 2 / 3, alignment: .leading)
                }
            }
        }
        Spacer()
    }
}


@ViewBuilder
func AvatarLeftSide(
    _ shouldShowAvatar: Bool,
    _ removeAvatarWhitespace: Bool,
    _ avatarUrl: String?
) -> some View {
    if (shouldShowAvatar) {
        if let avatarUrl = avatarUrl {
            RemoteImage(url: ImageLoader.getAvatar(avatarUrl))
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .scaledToFill()
                .padding(.trailing, 5)
        }
    } else {
        if (!removeAvatarWhitespace) {
            Spacer()
                .frame(width: 40, height: 40)
                .padding(.trailing, 5)
        }
    }
}
