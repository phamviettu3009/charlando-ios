//
//  PhoneTextField.swift
//  2lab
//
//  Created by Phạm Việt Tú on 16/06/2024.
//

import Foundation
import SwiftUI

struct PhoneTextField: View {
    @Binding var country: Country
    @Binding var phoneNumber: String
    
    var body: some View {
        HStack(spacing: 0) {
            Picker(LocalizedStringKey("country_code"), selection: $country) {
                ForEach(countryOptions, id: \.id) {
                    Text($0.flagSymbol + "( \($0.countryCode))")
                        .tag($0)
                }
            }
            .tint(Color(UIColor.label))
            
            Rectangle()
                .frame(width: 1, height: 28)
                .foregroundColor(.gray.opacity(0.3))
            
            TextField(LocalizedStringKey("phone"), text: $phoneNumber)
                .keyboardType(.numberPad)
                .padding(.horizontal)
        }
        .background {
            Rectangle()
                .fill(Color(UIColor.secondarySystemBackground))
                .frame(height: 40)
                .cornerRadius(10)
        }
    }
}
