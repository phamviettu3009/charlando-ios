//
//  OtpTextField.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 19/11/2023.
//

import SwiftUI
import Foundation

struct OtpTextField: View {
    @State var otpText: String = ""
    @FocusState private var isKeyboardShowing: Bool
    private var numberOfFields: Int
    private var onChange: (String, Bool) -> Void
    private var isCloseKeyboardWhenDone: Bool
    
    init(otpText: String = "", numberOfFields: Int, isCloseKeyboardWhenDone: Bool = true, onChange: @escaping (String, Bool) -> Void) {
        self.otpText = otpText
        self.numberOfFields = numberOfFields
        self.isCloseKeyboardWhenDone = isCloseKeyboardWhenDone
        self.onChange = onChange
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<numberOfFields, id: \.self) { index in
                OTPTextBox(index)
            }
        }
        .background(content: {
            TextField("", text: $otpText.limit(numberOfFields))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .blendMode(.screen)
                .focused($isKeyboardShowing)
        })
        .contentShape(Rectangle())
        .onTapGesture {
            isKeyboardShowing.toggle()
        }
        .onChange(of: otpText) { newValue in
            if newValue.count == numberOfFields {
                onChange(otpText, true)
                if isCloseKeyboardWhenDone {
                    isKeyboardShowing = false
                }
            } else {
                onChange(otpText, false)
            }
        }
    }
    
    @ViewBuilder
    func OTPTextBox(_ index: Int) -> some View {
        ZStack {
            if otpText.count > index {
                let startIndex = otpText.startIndex
                let charIndex = otpText.index(startIndex, offsetBy: index)
                let charToString = String(otpText[charIndex])
                Text(charToString).bold()
            } else {
                Text("")
            }
        }
            .frame(width: 45, height: 45)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(.gray, lineWidth: 0.5)
            )
            .frame(maxWidth: .infinity)
    }
}

extension Binding where Value == String {
    func limit(_ length: Int) -> Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        return self
    }
}
