//
//  ButtonCustom.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 14/11/2023.
//

import SwiftUI
import Foundation

struct ButtonCustom: View {
    var label: LocalizedStringKey
    var isLoading: Bool
    var action: () -> Void
    var disabled: Bool
    
    init(label: LocalizedStringKey, isLoading: Bool, disabled: Bool = false, action: @escaping () -> Void) {
        self.action = action
        self.isLoading = isLoading
        self.label = label
        self.disabled = disabled
    }
    
    var body: some View {
        let isDisabled: Bool = !self.disabled ? isLoading : true
        
        Button {
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.accentColor)
                    .opacity(isDisabled ? 0.5 : 1)
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(label)
                        .foregroundColor(Color.white)
                        .bold()
                }
            }
        }
        .disabled(isDisabled)
    }
}
