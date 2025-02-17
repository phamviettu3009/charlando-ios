//
//  SettingSide.swift
//  2lab
//
//  Created by Phạm Việt Tú on 02/06/2024.
//

import Foundation
import SwiftUI

struct SettingTab: View {
    @Binding var tab: Int
    
    @EnvironmentObject var viewModel: SettingViewModel
    
    @State private var showBottomBarBackground: Bool = false
    @State private var offset: CGFloat = 0
    @State private var avatarOffsetY: CGFloat = 0
    @State private var avatarOffsetX: CGFloat = 0
    @State private var headerActive: Bool = false
    @State private var thumbnailHeight: CGFloat = 0
    
    let heightScreen: CGFloat = UIScreen.main.bounds.height
    let widthScreen: CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            let size = $0.size
        }
    }
}
