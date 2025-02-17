//
//  GenderPicker.swift
//  2lab
//
//  Created by Phạm Việt Tú on 27/06/2024.
//

import Foundation
import SwiftUI

struct GenderPicker: View {
    private let genderOptions = ["Male", "Female"]
    @State private var value: String = "select_gender"
    @Binding var select: String?
    
    
    var body: some View {
        VStack {
            Menu {
                ForEach(genderOptions, id: \.self) { option in
                    Button {
                        value = option
                        select = option
                    } label: {
                        Text(LocalizedStringKey(option))
                    }
                }
            } label: {
                Text(LocalizedStringKey(value))
                    .foregroundColor(Color(UIColor.label))
            }
        }
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(Color(UIColor.secondarySystemBackground))
                .frame(height: 40)
                .cornerRadius(10)
        }
        .onAppear {
            if let select = select, genderOptions.contains(select) {
                value = select
            } else {
                value = "select_gender"
            }
        }
    }
}
