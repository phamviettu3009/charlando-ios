//
//  TextFiledLine.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 22/04/2024.
//

import Foundation
import SwiftUI

struct TextFiledLine: View {
    @Binding var text: String
    var label: LocalizedStringKey
    var keyboardType: UIKeyboardType
    var icon: () -> Image
    
    
    init(_ label: LocalizedStringKey, text: Binding<String>, keyboardType: UIKeyboardType = .default, icon: @escaping () -> Image) {
        self.label = label
        self._text = text
        self.keyboardType = keyboardType
        self.icon = icon
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.system(size: 13, weight: .light, design: .rounded))
                .foregroundColor(Color(UIColor.label))
            HStack {
                VStack {
                    icon()
                }
                .frame(width: 25, height: 25)
                TextField(label, text: $text)
                    .font(.system(size: 15, design: .rounded))
                    .keyboardType(keyboardType)
            }
            .overlay(Rectangle().frame(height: 1).padding(.top, 35))
            .foregroundColor(Color(UIColor.secondaryLabel))
            .padding(.bottom, 20)
        }
    }
}
