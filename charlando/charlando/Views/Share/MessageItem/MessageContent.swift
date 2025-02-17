//
//  MessageContent.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 02/12/2023.
//

import Foundation
import SwiftUI

@ViewBuilder
func MessageContent(
    message: Message,
    type: Int?,
    isDeleted: Bool,
    @ViewBuilder textContent: @escaping () -> some View,
    @ViewBuilder attachmentContent: @escaping () -> some View,
    @ViewBuilder iconMessageContent: @escaping () -> some View
) -> some View {
    if isDeleted {
        DeleteContent(message: message)
    } else {
        switch type {
        case MessageType.MESSAGE:
            textContent()
        case MessageType.ATTACHMENTS:
            textContent()
            attachmentContent()
        case MessageType.ICON_MESSAGE:
            iconMessageContent()
        default:
            EmptyView()
        }
    }
}
