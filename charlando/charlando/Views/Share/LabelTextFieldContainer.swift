//
//  LabelTextFieldContainer.swift
//  2lab
//
//  Created by Phạm Việt Tú on 17/06/2024.
//

import Foundation
import SwiftUI

struct LabelTextFieldContainer<Content: View>: View {
    var systemName: String?
    var label: LocalizedStringKey
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let systemName = systemName {
                    Image(systemName: systemName)
                }
                
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(Color(UIColor.secondaryLabel))
            content()
        }
    }
}
