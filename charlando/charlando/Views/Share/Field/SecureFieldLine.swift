//
//  SecureFieldLine.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 22/04/2024.
//

import Foundation
import SwiftUI

struct SecureFieldLine: View {
    @Binding var text: String
    var label: LocalizedStringKey
    var icon: () -> Image
    @State var showSecureField: Bool = true
    
    init(_ label: LocalizedStringKey, text: Binding<String>, icon: @escaping () -> Image) {
        self.label = label
        self._text = text
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
                if (showSecureField) {
                    SecureField(label, text: $text)
                        .font(.system(size: 15, design: .rounded))
                } else {
                    TextField(label, text: $text)
                        .font(.system(size: 15, design: .rounded))
                }
                Image(systemName: showSecureField ? "eye.slash" : "eye")
                    .onTapGesture {
                        showSecureField.toggle()
                    }
            }
            .overlay(Rectangle().frame(height: 1).padding(.top, 35))
            .foregroundColor(Color(UIColor.secondaryLabel))
            .padding(.bottom, 20)
        }
    }
}
