//
//  DatePickerCustom.swift
//  2lab
//
//  Created by Phạm Việt Tú on 27/06/2024.
//

import Foundation
import SwiftUI

struct DatePickerCustom: View {
    @State private var date = Date.now
    @Binding var selection: Date?
    @State var isOpen: Bool = false
    
    var body: some View {
        VStack {
            Text(selection == nil ? LocalizedStringKey("select_date") : LocalizedStringKey(selection!.asStringDate(dateFormat: "dd-MM-yyyy")))
                .frame(maxWidth: .infinity)
                .background {
                    Rectangle()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .frame(height: 40)
                        .cornerRadius(10)
                }
                .onAppear {
                    if let selection = selection {
                        date = selection
                    }
                }
                .onChange(of: date, perform: { newDate in
                    selection = newDate
                })
                .onTapGesture {
                    isOpen.toggle()
                }
                .sheet(isPresented: $isOpen) {
                    VStack {
                        DatePicker(selection: $date, in: ...Date.now, displayedComponents: .date) {
                            
                        }
                        .labelsHidden()
                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                        .datePickerStyle(.graphical)
                        .padding(.top, 200)
                        
                        Spacer()
                        
                        ButtonCustom(
                            label: LocalizedStringKey("done"),
                            isLoading: false,
                            disabled: false
                        ) {
                            isOpen.toggle()
                        }
                        .frame(height: 40)
                        .padding(.horizontal)
                    }
                }
        }
    }
}
