//
//  ToggleCustom.swift
//  2lab
//
//  Created by Phạm Việt Tú on 18/06/2024.
//

import Foundation
import SwiftUI

struct ToggleCustom: View {
    @Binding var toggle: Bool
    
    var yesLabel: LocalizedStringKey = LocalizedStringKey("yes")
    var noLabel: LocalizedStringKey = LocalizedStringKey("no")
    var onChange: () -> () = {}
    
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            Text(yesLabel)
                .padding(.vertical, 5)
                .frame(maxWidth: (UIScreen.main.bounds.width) / 2)
                .background {
                    BackgroundActive(isActive: toggle == true)
                    .animation(.snappy, value: toggle)
                }
                .contentShape(.rect)
                .onTapGesture {
                    let preToggle = toggle
                    toggle = true
                    preToggle == false ? onChange() : nil
                }
            
            
            Text(noLabel)
                .padding(.vertical, 5)
                .frame(maxWidth: (UIScreen.main.bounds.width) / 2)
                .background {
                    BackgroundActive(isActive: toggle == false)
                    .animation(.snappy, value: toggle)
                }
                .contentShape(.rect)
                .onTapGesture {
                    let preToggle = toggle
                    toggle = false
                    preToggle == true ? onChange() : nil
                }
        }
        .padding(.horizontal, 4)
        .background {
            Rectangle()
                .fill(Color(UIColor.secondarySystemBackground))
                .frame(height: 40)
                .cornerRadius(10)
        }
    }
    
    @ViewBuilder private func BackgroundActive(isActive: Bool) -> some View {
        ZStack {
            if (isActive) {
                Rectangle()
                    .fill(Color(UIColor.secondarySystemFill))
                    .cornerRadius(10)
                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
            }
        }
    }
}
