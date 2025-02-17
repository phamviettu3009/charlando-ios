//
//  MultipleSelectContainer.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 30/11/2023.
//

import Foundation
import SwiftUI

struct SelectContainer<Content: View>: View {
    var id: UUID
    var onChange: (UUID, Bool) -> Void
    var content: () -> Content
    @State var isSelected: Bool = false
    
    init(id: UUID, onChange: @escaping (UUID, Bool) -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.id = id
        self.onChange = onChange
        self.content = content
    }
    
    var body: some View {
        Button {
            isSelected.toggle()
            onChange(id, isSelected)
        } label: {
            HStack {
                if (isSelected) {
                    Image(systemName: "checkmark").foregroundColor(.accentColor)
                }
                content()
                Spacer()
            }
        }
    }
}
