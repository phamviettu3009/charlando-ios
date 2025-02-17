//
//  File.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 01/12/2023.
//

import Foundation
import SwiftUI

@ViewBuilder
func RightSide(message: Message, onTap: @escaping (Attachment) -> Void = {_ in }) -> some View {
    let type: Int? = message.type
    let isDeleted: Bool = message.recordStatus == MessageRecordStatus.DELETE
    
    let hasMessageReaction: Bool = message.messageReactions != nil
    let messageReactions = message.messageReactions
    let hasReply: Bool = message.reply != nil
    
    HStack {
        Spacer()
        VStack(alignment: .trailing) {
            ReplyContent(
                hasReply: hasReply,
                message: message,
                sideWay: SideWayMessageItem.RIGHT
            )
            MessageContent(message: message, type: type, isDeleted: isDeleted) {
                if let messageText = message.message, !messageText.isEmpty {
                    Text(messageText)
                        .padding(8)
                        .padding(.trailing, 10)
                        .padding(.leading, 4)
                        .padding(.bottom, (hasMessageReaction && message.type == MessageType.MESSAGE) ? 10 : 0)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .clipShape(BubbleShapeClone(myMessage: true))
                        .overlay {
                            if (hasReply) {
                                BubbleShapeClone(myMessage: true)
                                    .stroke(.background, lineWidth: 2)
                            }
                        }
                        .frame(maxWidth: UIScreen.main.bounds.width * 2 / 3, alignment: .trailing)
                } else {
                    EmptyView()
                }
            } attachmentContent: {
                AttachmentContent(attachments: message.attachments, onTap: onTap)
                    .frame(maxWidth: UIScreen.main.bounds.width * 1 / 2, alignment: .trailing)
            } iconMessageContent: {
                if let iconMessage = message.iconMessage {
                    Text(iconMessage)
                        .lineLimit(1)
                        .font(.system(size: 35))
                }
            }
            MessageReactionsContent(
                messageReactions: messageReactions,
                sideWay: SideWayMessageItem.RIGHT
            )
            
            if let urlsPreview = message.urlsPreview, !urlsPreview.isEmpty {
                ForEach(urlsPreview, id: \.self) {urlPreview in
                    LinkPreview(urlPreview)
                        .frame(width: UIScreen.main.bounds.width * 2 / 3, alignment: .trailing)
                }
            }
        }
        if !message.sync {
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .foregroundColor(.blue)
                .font(.system(size: 10))
        }
    }
}
