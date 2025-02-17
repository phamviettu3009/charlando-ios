//
//  MessageItem.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 01/12/2023.
//

import Foundation
import SwiftUI

struct MessageItem: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    private var message: Message
    private var messageOnRightSide: Bool
    var onTap: (Attachment) -> Void
    var onLongPress: (Message) -> Void
    
    init(
        message: Message,
        onTap: @escaping (Attachment) -> Void = {_ in },
        onLongPress: @escaping (Message) -> Void = {_ in }
    ) {
        self.message = message
        self.messageOnRightSide = message.messageOnRightSide
        self.onTap = onTap
        self.onLongPress = onLongPress
    }
    
    var body: some View {
        VStack {
            DateTimeContent(
                message.timeOfMessageSentDisplay,
                message.consecutiveMessages
            )
            if message.edited {
                Text(LocalizedStringKey("edited"))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .font(.system(size: 13))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            if (messageOnRightSide) {
                RightSide(message: message, onTap: self.onTap)
            } else {
                LeftSide(message: message, onTap: self.onTap)
            }
        }
        .onTapGesture {  }
        .onLongPressGesture {
            guard message.type != MessageType.ICON_MESSAGE else { return }
            guard message.recordStatus != MessageRecordStatus.DELETE else { return }
            onLongPress(message)
        }
    }
    
    @ViewBuilder
    func DateTimeContent(_ timeOfMessageSentDisplay: String?, _ consecutiveMessages: Bool?) -> some View {
        if (consecutiveMessages == false) {
            Text(LocalizedStringKey(timeOfMessageSentDisplay.orEmpty()))
                .font(.system(size: 14, weight: .light))
                .padding(.top, 14)
        }
    }
}
