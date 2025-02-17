//
//  ProspectsView.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 09/05/2024.
//

import Foundation
import SwiftUI
import NavigationStackBackport

struct ProspectsView: View {
    enum FilterType {
        case channels, users, setting
    }
    
    let filter: FilterType
    
    var title: String {
        switch filter {
        case .channels:
            "Everyone"
        case .users:
            "Contacted people"
        case .setting:
            "Uncontacted people"
        }
    }
    
    var body: some View {
        NavigationStackBackport.NavigationStack {
            Text("Hello, World!")
                .navigationTitle(title)
        }
        .ignoresSafeArea(.all)
    }
}
