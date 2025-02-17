//
//  MessageReactionContainer.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 24/02/2024.
//

import Foundation
import SwiftUI
import MCEmojiPicker

struct MessageReactionContainer: View {
    var isOpen: Bool
    var message: Message?
    var onClose:() -> ()
    var onTapReactionIcon: (String, Message) -> ()
    var onTapAction: (String, Message) -> ()
    @State private var useAnimation: Bool = false
    @State var messageActionsFinal: [MessageAction] = []
    @State private var displayEmojiPicker: Bool = false
    @State private var selectedEmoji: String = ""
    
    let reactionIcons = ["❤️️", "👍", "👎", "😆", "😂", "😢", "☹️"]
    let messageActions = [
        MessageAction(key: "Copy", label: LocalizedStringKey("copy"), icon: "doc.on.doc"),
        MessageAction(key: "Edit", label: LocalizedStringKey("edit"), icon: "pencil"),
        MessageAction(key: "Reply", label: LocalizedStringKey("reply"), icon: "arrowshape.turn.up.left"),
        MessageAction(key: "Delete", label: LocalizedStringKey("delete"), icon: "delete.left")
    ]
    
    var body: some View {
        if (isOpen) {
            ZStack {
                ZStack{
                    Color(UIColor.white).opacity(0.1).edgesIgnoringSafeArea(.all)
                }
                .onTapGesture {
                    onClose()
                }
                VStack(alignment: message?.messageOnRightSide == true ? .trailing : .leading) {
                    HStack {
                        ForEach(reactionIcons, id: \.self) {icon in
                            Text(icon)
                                .onTapGesture {
                                    onTapReactionIcon(icon, message!)
                                    onClose()
                                }
                        }
                        Image(systemName: "plus.circle.fill")
                            .onTapGesture {
                                displayEmojiPicker.toggle()
                                impactOccurred()
                            }
                            .onDisappear {
                                displayEmojiPicker = false
                            }
                            .emojiPicker(
                                isPresented: $displayEmojiPicker,
                                selectedEmoji: $selectedEmoji,
                                arrowDirection: .up
                            )
                            .onChange(of: selectedEmoji) { value in
                                onTapReactionIcon(value, message!)
                                onClose()
                            }
                    }
                    .padding(15)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .isHidden(message?.unsent == true)
                    .scaleEffect(useAnimation ? 1 : 0)
                    
                    if let message = message {
                        if (message.messageOnRightSide) {
                            RightSide(message: message, onTap: { _ in })
                                .scaleEffect(useAnimation ? 1 : 0)
                        } else {
                            LeftSide(message: message, removeAvatarWhitespace: true, onTap: { _ in })
                                .scaleEffect(useAnimation ? 1 : 0)
                        }
                    }
                    
                    if (!messageActionsFinal.isEmpty) {
                        VStack {
                            ForEach(Array(messageActionsFinal.enumerated()), id: \.offset) { index, action in
                                HStack {
                                    Text(action.label)
                                    Spacer()
                                    Image(systemName: action.icon)
                                }
                                .background(Color(UIColor.secondarySystemBackground))
                                .onTapGesture {
                                    onTapAction(action.key, message!)
                                    onClose()
                                }
                                if(index < messageActionsFinal.count - 1) {
                                    Divider()
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .frame(width: 200)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .scaleEffect(useAnimation ? 1 : 0)
                    }
                }.padding(.horizontal, 10)
            }
            .onAppear {
                getActions()
                withAnimation {
                    useAnimation = true
                }
            }
            .onDisappear {
                messageActionsFinal.removeAll()
                useAnimation = false
            }
        }
    }
    
    private func getActions() {
        guard let type = message?.type else { return }
        switch type {
        case MessageType.MESSAGE:
            messageActionsFinal = messageActions
            break
        case MessageType.ATTACHMENTS:
            messageActionsFinal = messageActions.filter({ action in
                if let message = message?.message, !message.isEmpty {
                    return true
                } else {
                    return !["Copy", "Edit"].contains(action.key)
                }
            })
            break
        default:
            break
        }
        
        if(message?.messageOnRightSide == false) {
            messageActionsFinal = messageActionsFinal.filter({ action in
                return !["Delete", "Edit"].contains(action.key)
            })
        }
    }
}

struct MessageAction {
    var key: String
    var label: LocalizedStringKey
    var icon: String
}
