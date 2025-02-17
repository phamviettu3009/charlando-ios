//
//  SwitcherScreenMode.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/03/2024.
//

import Foundation
import SwiftUI

struct SwitcherTheme: View {
    @AppStorage("useTheme") private var useTheme: Theme = .systemDefault
    
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Theme.allCases, id: \.self) { theme in
                Text(LocalizedStringKey(theme.rawValue.lowercased()))
                    .padding(.vertical, 5)
                    .frame(width: (UIScreen.main.bounds.width - 50) / 3)
                    .background {
                        ZStack {
                            if (useTheme == theme) {
                                Rectangle()
                                    .fill(Color(UIColor.secondarySystemFill))
                                    .cornerRadius(10)
                                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                            }
                        }
                        .animation(.snappy, value: useTheme)
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        useTheme = theme
                    }
            }
        }
    }
}

#Preview {
    SwitcherTheme()
}
