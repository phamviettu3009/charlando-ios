//
//  MessageReactionsContent.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 03/12/2023.
//

import Foundation
import SwiftUI

@ViewBuilder
func MessageReactionsContent(
    messageReactions: [MessageReaction]?,
    sideWay: SideWayMessageItem
) -> some View {
    let hasMessageReaction: Bool = messageReactions != nil
    if (hasMessageReaction) {
        let (offsetX, offsetY) = switch sideWay {
        case .RIGHT:
            (-20 as CGFloat, -20 as CGFloat)
        case .LEFT:
            (20 as CGFloat, -20 as CGFloat)
        }
        
        HStack(spacing: 6) {
            ForEach(messageReactions!, id: \.self) { messageReaction in
                let color = if (messageReaction.toOwn) {
                    Color.yellow
                } else {
                    Color.white
                }
                
                HStack(spacing: 3) {
                    Text(messageReaction.icon)
                        .foregroundColor(color)
                        .font(.system(size: 14))
                    
                    Text(String(messageReaction.quantity))
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Material.ultraThick)
        .cornerRadius(20)
        .offset(x: offsetX, y: offsetY)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(.background, lineWidth: 2)
                .offset(x: offsetX, y: offsetY)
        )
    } else {
        EmptyView()
    }
}
