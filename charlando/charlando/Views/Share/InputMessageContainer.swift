//
//  InputMessageContainer.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 22/02/2024.
//

import Foundation
import SwiftUI
import PhotosUI
import MCEmojiPicker

struct InputMessageContainer: View {
    @Binding var inputMessage: String
    @Binding var photoItems: [PhotoItem]
    var onSendMessage: () -> ()
    var onSendIconMessage: (String) -> ()
    var onSendRecording: (URL, String) -> ()
    
    @State private var displayEmojiPicker: Bool = false
    @State private var selectedEmoji: String = ""
    
    var body: some View {
        HStack {
            InputMediaContainer(
                photoItems: $photoItems,
                onSendRecording: { url, fileName in onSendRecording(url, fileName) }
            )
            
            TextField("Type a message", text: $inputMessage)
                .padding(.leading, 15)
                .padding(.trailing, 40)
                .autocapitalization(.sentences)
                .disableAutocorrection(true)
                .font(.system(size: 14))
                .frame(height: 40)
                .overlay(
                    ZStack(alignment: .trailing) {
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.gray, lineWidth: 1)
                        
                        Button() {
                            onSendMessage()
                            hideKeyboard()
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.accentColor)
                                .padding(.leading, 8)
                        }
                        .offset(x: -10, y: 0)
                    }
                )
                .cornerRadius(40)
            
            Text("👍")
                .font(.system(size: 30))
                .onTapGesture {
                    onSendIconMessage("👍")
                }
                .onLongPressGesture {
                    displayEmojiPicker.toggle()
                    impactOccurred()
                }
                .emojiPicker(
                    isPresented: $displayEmojiPicker,
                    selectedEmoji: $selectedEmoji,
                    arrowDirection: .down
                )
                .onChange(of: selectedEmoji) { value in
                    onSendIconMessage(value)
                }
        }
        .padding(.horizontal, 10)
    }
}
