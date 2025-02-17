//
//  ReplyContent.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 04/12/2023.
//

import Foundation
import SwiftUI

@ViewBuilder
func ReplyContent(
    hasReply: Bool,
    message: Message,
    sideWay: SideWayMessageItem
) -> some View {
    if hasReply, let type = message.reply?.type {
        HStack {
            switch type {
            case MessageType.MESSAGE:
                Text(message.reply?.message ?? "")
                    .opacity(0.5)
                    .padding(8)
                    .padding(.bottom, 10)
                    .background(Material.ultraThick.opacity(0.7))
                    .cornerRadius(8)
                    .frame(
                        maxWidth: UIScreen.main.bounds.width * 2 / 3,
                        alignment: sideWay == SideWayMessageItem.RIGHT ? .trailing : .leading
                    )
            case MessageType.ATTACHMENTS:
                VStack(alignment: sideWay == SideWayMessageItem.RIGHT ? .trailing : .leading) {
                    if let message = message.reply?.message, !message.isEmpty {
                        Text(message)
                            .opacity(0.5)
                            .padding(8)
                            .background(Material.ultraThick.opacity(0.7))
                            .cornerRadius(8)
                            .frame(
                                maxWidth: UIScreen.main.bounds.width * 2 / 3,
                                alignment: sideWay == SideWayMessageItem.RIGHT ? .trailing : .leading
                            )
                    }
                    AttachmentContent(attachments: message.reply?.attachments)
                        .opacity(0.5)
                        .frame(maxWidth: UIScreen.main.bounds.width * 1 / 2)
                }
            default:
                EmptyView()
            }
        }
        .offset(x: 0, y: 20)
    }
}
