//
//  BottomNavigationCustom.swift
//  2lab
//
//  Created by Phạm Việt Tú on 29/05/2024.
//

import Foundation
import SwiftUI

struct BottomNavigation: View {
    @State private var tab: Int = 0
    
    @StateObject var listChannelViewModel = ListChannelViewModel()
    @StateObject var listUserViewModel = ListUserViewModel()
    @StateObject var listFriendViewModel = ListFriendViewModel()
    @StateObject var settingViewModel = SettingViewModel()
    
    var body: some View {
        Group {
            switch tab {
            case 0:
                ChannelTab(tab: $tab)
                    .environmentObject(listChannelViewModel)
                    .environmentObject(settingViewModel)
            case 1:
                UserTab(tab: $tab)
                    .environmentObject(listUserViewModel)
                    .environmentObject(listFriendViewModel)
                    .environmentObject(settingViewModel)
            case 2:
                ProfileTab(tab: $tab)
                .environmentObject(settingViewModel)
            default:
                EmptyView()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea([.bottom, .top])
    }
}
