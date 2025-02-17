//
//  Example.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 22/11/2023.
//

import Foundation
import SwiftUI

struct Example: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject var viewModel = ExampleViewModel()
    
    var body: some View {
        ScrollView {
            Text("example")
        }
        .navigationTitle(LocalizedStringKey("title"))
    }
}

struct Example_Preview: PreviewProvider {
    static var previews: some View {
        Example()
    }
}
