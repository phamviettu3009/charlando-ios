//
//  AttachmentContent.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 04/12/2023.
//

import Foundation
import SwiftUI

@ViewBuilder
func AttachmentContent(
    attachments: [Attachment]?,
    onTap: @escaping (Attachment) -> Void = {_ in}
) -> some View {
    if let count = attachments?.count, attachments != nil {
        switch count {
        case 1:
            SingleAttachment(attachment: attachments![0], onTap: onTap)
        case 2...Int.max:
            GroupAttachment(attachments: attachments!, onTap: onTap)
        default:
            EmptyView()
        }
    }
}

@ViewBuilder
func SingleAttachment(attachment: Attachment, onTap: @escaping (Attachment) -> Void = {_ in}) -> some View {
    AttachmentView(attachment: attachment)
        .frame(maxHeight: 250)
        .clipped()
        .cornerRadius(20)
        .onTapGesture {
            onTap(attachment)
        }
}

@ViewBuilder
func GroupAttachment(attachments: [Attachment], onTap: @escaping (Attachment) -> Void = {_ in}) -> some View {
    let adaptiveColumn = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    
    LazyVGrid(columns: adaptiveColumn, spacing: 0) {
        ForEach(attachments, id: \.self) { attachment in
            AttachmentView(attachment: attachment)
                .scaledToFill()
                .frame(maxWidth: UIScreen.main.bounds.width / 3, minHeight: 50, maxHeight: 100)
                .aspectRatio(contentMode: .fill)
                .clipped()
                .onTapGesture {
                    onTap(attachment)
                }
        }
    }
    .cornerRadius(20)
}

@ViewBuilder
func AttachmentView(attachment: Attachment) -> some View {
    let resourceID = attachment.id
    switch (attachment.type) {
    case AttachmentType.IMAGE:
        RemoteImage(url: ImageLoader.getResource(resourceID.uuidString))
            .aspectRatio(contentMode: .fill)
            .clipped()
    case AttachmentType.VIDEO:
        RemoteImage(url: ImageLoader.getThumbnail(resourceID.uuidString), isThumbnail: true)
            .scaledToFill()
    case AttachmentType.AUDIO:
        AudioSkeleton()
    default:
        EmptyView()
    }
}
