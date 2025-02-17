//
//  BottomNavigationForIOS15.swift
//  2lab
//
//  Created by Phạm Việt Tú on 28/05/2024.
//

import Foundation
import SwiftUI

struct BottomNavigationForIOS15: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @AppStorage("language") private var language: String = "default"
    @State var tab: Int = 0
    @State var title: String = "messages"
    
    @StateObject var listChannelViewModel = ListChannelViewModel()
    @StateObject var listUserViewModel = ListUserViewModel()
    @StateObject var settingViewModel = SettingViewModel()
    
    var body: some View {
        TabView(selection: $tab) {
            NavigationView {
                ScrollView() {
                    ListChannelScreen()
                        .padding()
                }
                .refreshable {
                    listChannelViewModel.onRefresh()
                }
                .navigationTitle(LocalizedStringKey("messages"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button {
                            navigationManager.navigateTo(.createGroupChannel)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
                .searchable(text: $listChannelViewModel.search, placement: .navigationBarDrawer(displayMode: .always), prompt: LocalizedStringKey("search"))
            }
            .environmentObject(listChannelViewModel)
            .tabItem {
                Label(LocalizedStringKey("messages"), systemImage: "message")
            }
            .tag(0)
            
            NavigationView {
                ScrollView {
                    ListUserScreen()
                        .padding()
                }
                .navigationTitle(LocalizedStringKey("users"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button {
                            navigationManager.navigateTo(.requestAddFriend)
                        } label: {
                            Image(systemName: "bell.fill")
                                .overlay(
                                    NotificationCountView(
                                        value: $listUserViewModel.numberRequestAddFriend,
                                        foreground: .white,
                                        background: .red
                                    )
                                )
                        }
                    }
                }
                .refreshable {
                    listUserViewModel.onRefresh()
                }
                .searchable(text: $listUserViewModel.search, placement: .navigationBarDrawer(displayMode: .always), prompt: LocalizedStringKey("search"))
            }
            .environmentObject(listUserViewModel)
            .tabItem {
                Label(LocalizedStringKey("users"), systemImage: "person")
            }
            .tag(1)
            
            NavigationView {
                ScrollView {
                    SettingScreen()
                }
                .navigationTitle(LocalizedStringKey("setting"))
                .navigationBarTitleDisplayMode(.inline)
            }
            .environmentObject(settingViewModel)
            .tabItem {
                Label(LocalizedStringKey("setting"), systemImage: "gearshape.fill")
            }
            .tag(2)
        }
        .navigationTitle(LocalizedStringKey(title))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .onAppear {
            title = ""
        }
        .onDisappear {
            title = UUID().uuidString
        }
        .onChange(of: tab) { value in
            switch value {
            case 0:
                title = "messages"
            case 1:
                title = "users"
            case 2:
                title = "setting"
            default:
                title = ""
            }
        }
    }
}
