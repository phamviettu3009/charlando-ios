//
//  BottomNavigation.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 13/11/2023.
//

import SwiftUI
import Foundation

struct BottomNavigation: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @AppStorage("language") private var language: String = "default"
    @State var tab: Int = 0
    @State var title: String = "messages"
    
    @StateObject var listChannelViewModel = ListChannelViewModel()
    @StateObject var listUserViewModel = ListUserViewModel()
    @StateObject var settingViewModel = SettingViewModel()
    
    var body: some View {
        TabView(selection: $tab) {
            NavigationViewCustom(
                title: LocalizedStringKey("messages"),
                trailingHeader: {
                    AnyView(
                        Button {
                            navigationManager.navigateTo(.createGroupChannel)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    )
                },
                refreshable: {
                    listChannelViewModel.onRefresh()
                }, 
                search: $listChannelViewModel.search
            ) {
                ListChannelView()
                    .padding(.horizontal)
            }
            .environmentObject(listChannelViewModel)
            .tabItem {
                Label(LocalizedStringKey("messages"), systemImage: "message")
            }
            .tag(0)
            
            NavigationViewCustom(
                title: LocalizedStringKey("users"),
                trailingHeader: {
                    AnyView(
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
                    )
                },
                refreshable: {
                    listUserViewModel.onRefresh()
                },
                search: $listUserViewModel.search
            ) {
                ListUserView()
                    .padding(.horizontal)
            }
            .environmentObject(listUserViewModel)
            .tabItem {
                Label(LocalizedStringKey("users"), systemImage: "person")
            }
            .tag(1)
            
            NavigationViewCustom(
                title: LocalizedStringKey("setting"),
                showSearch: false,
                refreshable: {
                    Task { await settingViewModel.fetchUserFromAPIs() }
                }
            ) {
                SettingView()
            }
            .environmentObject(settingViewModel)
            .tabItem {
                Label(LocalizedStringKey("setting"), systemImage: "gearshape.fill")
            }
            .tag(2)
        }
        .navigationTitle(LocalizedStringKey(title))
        .navigationBarHidden(true)
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

struct BottomNavigation_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavigation()
    }
}

