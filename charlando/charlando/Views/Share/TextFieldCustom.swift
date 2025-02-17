//
//  TextFieldCustom.swift
//  2lab
//
//  Created by Phạm Việt Tú on 17/06/2024.
//

import Foundation
import SwiftUI

struct TextFieldCustom: View {
    var label: LocalizedStringKey
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField(label, text: $text)
                .padding(.horizontal, 20)
        }
        .frame(height: 40)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}
