//
//  InputExpandContainer.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 28/02/2024.
//

import Foundation
import SwiftUI
import PhotosUI
import AVKit

struct InputExpandContainer: View {
    var isOpen: Bool
    var mode: SendMode
    var message: Message?
    @Binding var photoItems: [PhotoItem]
    var onClose: () -> ()
    
    var body: some View {
        if (isOpen) {
            VStack() {
                Divider()
                HStack(alignment: .top) {
                    Spacer()
                    Button {
                        photoItems.removeAll()
                        onClose()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                
                switch mode {
                case .Update(_):
                    if let message = message?.message {
                        HStack {
                            Image(systemName: "pencil")
                            Text(message).font(.system(size: 14))
                            Spacer()
                        }
                    }
                case .Attachment:
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach($photoItems, id: \.id) { itemBinding in
                                let item = itemBinding.wrappedValue
                                if (item.type == AttachmentType.IMAGE) {
                                    Image(uiImage: item.value as! UIImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                } else if (item.type  == AttachmentType.VIDEO) {
                                    VideoPlayer(player: item.value as? AVPlayer)
                                        .disabled(true)
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                }
                            }
                        }
                    }
                case .Reply:
                    if let message = message?.message {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.left")
                            Text(message).font(.system(size: 14))
                            Spacer()
                        }
                    }
                    
                    if let attachments = message?.attachments {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(attachments, id: \.id) { attachment in
                                    switch attachment.type {
                                    case AttachmentType.IMAGE:
                                        RemoteImage(url: ImageLoader.getResource(attachment.id.uuidString))
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .aspectRatio(contentMode: .fill)
                                            .clipped()
                                    case AttachmentType.VIDEO:
                                        RemoteImage(url: ImageLoader.getThumbnail(attachment.id.uuidString))
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .aspectRatio(contentMode: .fill)
                                            .clipped()
                                    default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    }
                default:
                    EmptyView()
                }
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}
