//
//  DeleteContent.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 02/12/2023.
//

import Foundation
import SwiftUI

@ViewBuilder
func DeleteContent(
    message: Message
) -> some View {
    VStack {
        Text(LocalizedStringKey(message.subMessage.orEmpty()))
            .foregroundColor(.red)
            .padding(8)
            .background(Material.ultraThickMaterial)
            .cornerRadius(8)
    }
}
