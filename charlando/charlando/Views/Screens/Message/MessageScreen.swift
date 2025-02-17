//
//  MessageScreen.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 13/11/2023.
//

import SwiftUI
import Foundation

struct MessageScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var messageListener: MessageListener
    @ObservedObject var viewModel: MessageViewModel
    
    init(channelID: UUID) {
        viewModel = MessageViewModel(channelID: channelID)
    }
    
    var body: some View {
        ScrollViewReader { scrollReader in
            List {
                VStack {
                    ForEach(viewModel.usersTyping, id: \.self) { user in
                        HStack {
                            if let userAvatar: String = user.avatar {
                                RemoteImage(url: ImageLoader.getAvatar(userAvatar))
                                    .frame(width: 25, height: 25)
                                    .clipShape(Circle())
                                    .scaledToFill()
                            }
                            Text(LocalizedStringKey("typing"))
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .rotationEffect(.degrees(-180))
                    }
                }
                .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                .listRowSeparator(.hidden)
                .padding([.horizontal], 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.userReaders, id: \.self) { user in
                            if !user.source.uuidString.isEmpty {
                                let userAvatar: String = user.source.uuidString
                                RemoteImage(url: ImageLoader.getAvatar(userAvatar))
                                    .frame(width: 25, height: 25)
                                    .clipShape(Circle())
                                    .scaledToFill()
                                    .rotationEffect(.degrees(-180))
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                .listRowSeparator(.hidden)
                .padding([.horizontal], 16)
                
                ForEach(viewModel.messages, id: \.self) { message in
                    MessageItem(
                        message: message,
                        onTap: { attachment in
                            viewModel.isOpenFullScreenAttachment.toggle()
                            viewModel.attachmentTab = attachment
                        },
                        onLongPress: { message in
                            viewModel.messageSelected = message
                            viewModel.isOpenMessageReactionContainer = true
                            viewModel.isOpenInputExpandContainer = false
                            impactOccurred()
                        }
                    )
                    .id(message.id)
                    .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                    .listRowSeparator(.hidden)
                    .rotationEffect(.degrees(-180))
                    .padding([.horizontal], 16)
                }
                VStack {}
                .onAppear {
                    viewModel.loadMoreListMessage()
                }
                .listRowSeparator(.hidden)
            }
            .padding([.horizontal], -16)
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 0)
            .rotationEffect(.degrees(-180))
            
            InputExpandContainer(
                isOpen: viewModel.isOpenInputExpandContainer,
                mode: viewModel.sendMode,
                message: viewModel.messageSelected,
                photoItems: $viewModel.photoItems,
                onClose: {
                    viewModel.onCloseInputExpandContainer()
                }
            )
            .onChange(of: viewModel.photoItems) { pickerItems in
                if(!pickerItems.isEmpty) {
                    viewModel.isOpenInputExpandContainer = true
                    viewModel.sendMode = .Attachment
                    viewModel.inputMessage = ""
                }
            }
            
            InputMessageContainer(
                inputMessage: $viewModel.inputMessage,
                photoItems: $viewModel.photoItems,
                onSendMessage: {
                    viewModel.sendMessageController()
                },
                onSendIconMessage: { icon in
                    viewModel.sendMessage(icon: icon)
                },
                onSendRecording: { url, fileName in
                    viewModel.sendRecording(url: url, fileName: fileName)
                }
            )
        }
        .blur(radius: viewModel.isOpenMessageReactionContainer ? 15 : 0)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                MessageNavigationBarLeading(channel: viewModel.channel)
            }
        }
        .navigationBarTitleDisplayMode(viewModel.isOpenMessageReactionContainer ? .inline : .automatic)
        .navigationBarHidden(viewModel.isOpenMessageReactionContainer)
        .fullScreenCover(isPresented: $viewModel.isOpenFullScreenAttachment) {
            AttachmentScreenCover(
                toggle: $viewModel.isOpenFullScreenAttachment,
                attachment: $viewModel.attachmentTab,
                attachments: $viewModel.attachments
            )
        }
        .actionSheet(isPresented: $viewModel.isOpenAlertDeleteMessage) {
            ActionSheet(
                title: Text(LocalizedStringKey("delete_message")),
                message: Text(LocalizedStringKey("choose_an_option")),
                buttons: [
                    .destructive(Text(LocalizedStringKey("delete_for_all"))) {
                        viewModel.deleteMessage(
                            messageID: viewModel.deleteID,
                            syncTarget: EventEntity.SYNC_TARGET_DELETE_MESSAGE_FOR_ALL
                        )
                    },
                    .destructive(Text(LocalizedStringKey("delete_for_you"))) {
                        viewModel.deleteMessage(
                            messageID: viewModel.deleteID,
                            syncTarget: EventEntity.SYNC_TARGET_DELETE_MESSAGE_FOR_OWNER
                        )
                    },
                    .cancel() {}
                ]
            )
        }
        .overlay(content: {
            MessageReactionContainer(
                isOpen: viewModel.isOpenMessageReactionContainer,
                message: viewModel.messageSelected,
                onClose: {
                    viewModel.isOpenMessageReactionContainer = false
                },
                onTapReactionIcon: { icon, message in
                    viewModel.sendMessageReaction(
                        messageID: message.id,
                        messageReactionIcon: icon
                    )
                },
                onTapAction: {action, message in
                    viewModel.onPressMessageAction(
                        action: action,
                        message: message
                    )
                }
            )
        })
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            viewModel.fetchChanelFromCoreData()
            viewModel.onScreen = true
            Task {
                await viewModel.fetchChannelFromAPIs { channelID in
                    navigationManager.back()
                    DispatchQueue.main.async {
                        messageListener.message = .removeChannel(channelID: channelID)
                    }
                }
            }
        }
        .onDisappear {
            viewModel.onScreen = false
        }
    }
}

//.rotationEffect(.degrees(-180))
