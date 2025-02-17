//
//  SettingTap2.swift
//  2lab
//
//  Created by Phạm Việt Tú on 03/06/2024.
//

import Foundation
import SwiftUI

struct ProfileTab: View {
    @Binding var tab: Int
    
    @State private var offsetY: CGFloat = 0
    @State private var showBottomBarBackground: Bool = false
    
    @EnvironmentObject var viewModel: SettingViewModel
    
    let heightScreen: CGFloat = UIScreen.main.bounds.height
    let widthScreen: CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            let size = $0.size
            
            ZStack(alignment: .bottom) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack{
                        // MARK: - Cover photo
                        CoverPhoto(size: size, safeArea: safeArea)
            
                        HStack {
                            Spacer()
                            Avatar(avatars: [viewModel.avatarUrl], size: 100)
                                .background(
                                    Circle()
                                        .stroke(.background, lineWidth: 2)
                                )
                            Spacer()
                        }
                        .frame(height: 100)
                        .padding(.top, -70)
                        .zIndex(1)
                        
                        VStack(spacing: 0) {
                            if let fullName = viewModel.fullName {
                                Text(fullName)
                                    .fontWeight(.heavy)
                            }
                            
                            ProfileView()
                            SettingView()
                            VStack{}
                                .frame(height: 200)
                        }
                        .padding(.top, 10)
                        .zIndex(0)
                        
                    }
                    .overlay(
                        GeometryReader { proxy -> Color in
                            let maxY = proxy.frame(in: .global).maxY
                            DispatchQueue.main.async {
                                if ((maxY + 70) >= heightScreen) {
                                    showBottomBarBackground = true
                                } else {
                                    showBottomBarBackground = false
                                }
                            }
                            
                            return Color.clear
                        },
                        alignment: .top
                    )
                    .overlay(alignment: .top) {
                        HeaderView(size: size, safeArea: safeArea)
                    }
                }
                .padding(.bottom, 80)
                .coordinateSpace(name: "SCROLL")
                BottomBar(tab: $tab, showBottomBarBackground: $showBottomBarBackground)
            }
            .ignoresSafeArea(.container, edges: .top)
        }
        
    }
    
    @ViewBuilder
    func CoverPhoto(size: CGSize, safeArea: EdgeInsets) -> some View {
        let height = size.height * 0.65
        GeometryReader { proxy in
            let size = proxy.size
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.8))
            
            if let coverPhotoUrl = viewModel.coverPhotoUrl {
                CoverPhotoProfile(url: coverPhotoUrl)
                    .offset(y: minY < 0 ? (-minY / 1.2) : 0)
                    .frame(width: size.width, height: size.height + (minY > 0 ? minY : 0 ))
                    .clipped()
                    .offset(y: minY < 0 ? 0 : -minY)
            }
        }
        .frame(height: height + safeArea.top )
    }
    
    // MARK: - Header View
    @ViewBuilder
    func HeaderView(size: CGSize, safeArea: EdgeInsets) -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let height = size.height * 0.65
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.9))
            
            HStack(spacing: 15) {
                
                Avatar(avatars: [viewModel.avatarUrl], size: 50)
                    .opacity(-progress > 1 ? 1 : 0)
                    .animation(.smooth, value: -progress > 1 ? 1 : 0)
                
                Spacer()
                
                Image(systemName: "square.and.pencil")
                    .foregroundColor(-progress > 1 ? Color(UIColor.label) : .white)
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.horizontal, -progress > 1 ? 0 : 20)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 100)
                            .fill(Color.accentColor.opacity(-progress > 1 ? 0 : 1))
                    )
                    .animation(.smooth, value: -progress > 1 ? 0 : 1)
                    .onTapGesture {
                        viewModel.isOpenSheetEditInfo.toggle()
                    }
            }
            .overlay(content: {
                VStack(alignment: .leading) {
                    if let fullName = viewModel.fullName {
                        Text(fullName)
                            .fontWeight(.semibold)
                            .offset(y: -progress > 1 ? 0 : 45)
                            .clipped()
                            .animation(.easeOut(duration: 0.25), value: -progress > 1 ? 0 : 45)
                    }
                }
            })
            .padding(.top, safeArea.top + 55)
            .padding([.horizontal,.bottom], 15)
            .background(
                .ultraThinMaterial
                .opacity(-progress > 1 ? 1 : 0)
            )
            .offset(y: -minY)
        }
        .frame(height: 100)
    }
    
    private func getScaleAvatar() -> CGFloat {
        if offsetY > 100 {
            return 1
        }
        
        let progress = offsetY / 100
        return (progress > 0.5) ? progress : 0.5
    }
}
