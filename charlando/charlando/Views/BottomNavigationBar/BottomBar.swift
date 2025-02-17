//
//  BottomTab.swift
//  2lab
//
//  Created by Phạm Việt Tú on 02/06/2024.
//

import Foundation
import SwiftUI

struct BottomBar: View {
    @Binding var tab: Int
    @Binding var showBottomBarBackground: Bool
    @EnvironmentObject var settingViewModel: SettingViewModel
    
    var body: some View {
        HStack {
            VStack {
                Image(systemName: "message.fill")
                    .font(.system(size: 25))
                Text(LocalizedStringKey("messages"))
                    .font(.system(size: 12))
            }
            .foregroundColor(tab == 0 ? .accentColor : Color(UIColor.secondaryLabel))
            .onTapGesture {
                tab = 0
            }
            Spacer()
            VStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 25))
                Text(LocalizedStringKey("users"))
                    .font(.system(size: 12))
            }
            .foregroundColor(tab == 1 ? .accentColor : Color(UIColor.secondaryLabel))
            .onTapGesture {
                tab = 1
            }
            Spacer()
            VStack {
                if let avatar = settingViewModel.avatarUrl {
                    RemoteImage(url: ImageLoader.getAvatar(avatar))
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(tab == 2 ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                } else {
                    VStack {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 25))
                        Text(LocalizedStringKey("setting"))
                            .font(.system(size: 12))
                    }
                    .foregroundColor(tab == 2 ? .accentColor : Color(UIColor.secondaryLabel))
                }
            }
            .onTapGesture {
                tab = 2
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 6)
        .padding(.bottom, 30)
        .background(
            Color.clear
                .background(.ultraThinMaterial)
                .opacity(showBottomBarBackground ? 1 : 0)
                .ignoresSafeArea()
        )
    }
}
