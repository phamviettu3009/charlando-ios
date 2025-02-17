//
//  DeviceManagerScreen.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 15/04/2024.
//

import Foundation
import SwiftUI

struct DeviceManagerScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var contentViewViewModel: ContentViewViewModel
    @StateObject var viewModel = DeviceManagerViewModel()
    
    var body: some View {
        List {
            HStack {
                Spacer()
                Text(LocalizedStringKey("logout_all"))
                    .foregroundColor(.red)
                Spacer()
            }
            .padding(10)
            .background(Color(UIColor.secondarySystemFill))
            .cornerRadius(10)
            .listRowInsets(EdgeInsets(top: 2, leading: 20, bottom: 2, trailing: 20))
            .listRowSeparator(.hidden)
            .onTapGesture {
                Task {
                    await viewModel.logoutAll {
                        navigationManager.back()
                        DispatchQueue.main.async {
                            contentViewViewModel.isLoggedIn = false
                        }
                    }
                }
            }
            
            ForEach(viewModel.devices, id: \.deviceID) { device in
                VStack(alignment: .leading) {
                    Text("\(device.deviceName) (\(device.os))")
                        .bold()
                        .lineLimit(1)
                    if let mostRecentLoginTimeDisplay = device.mostRecentLoginTimeDisplay {
                        HStack {
                            Text(LocalizedStringKey("most_recent_login_time"))
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(mostRecentLoginTimeDisplay)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }
                    if let mostRecentLogoutTimeDisplay = device.mostRecentLogoutTimeDisplay {
                        HStack {
                            Text(LocalizedStringKey("most_recent_logout_time"))
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(mostRecentLogoutTimeDisplay)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text(LocalizedStringKey("status"))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(LocalizedStringKey(device.login ? "login" : "logout"))
                            .font(.system(size: 13))
                            .foregroundColor(device.login ? .green : .secondary)
                    }
                    
                    if (device.login) {
                        HStack {
                            Spacer()
                            Text(LocalizedStringKey("logout"))
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                                .onTapGesture {
                                    Task {
                                        await viewModel.logout(deviceID: device.deviceID) {
                                            navigationManager.back()
                                            DispatchQueue.main.async {
                                                contentViewViewModel.isLoggedIn = false
                                            }
                                        }
                                    }
                                }
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(20)
                .background(Color(UIColor.secondarySystemFill))
                .cornerRadius(10)
                .listRowInsets(EdgeInsets(top: 2, leading: 20, bottom: 2, trailing: 20))
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .navigationTitle(LocalizedStringKey("device_manager"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
