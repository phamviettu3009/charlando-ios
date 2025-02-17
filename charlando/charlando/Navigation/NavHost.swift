//
//  NavHost.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 13/11/2023.
//

import SwiftUI
import Foundation

struct NavHost<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
    }
}
