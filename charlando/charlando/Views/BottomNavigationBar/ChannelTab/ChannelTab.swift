//
//  ChannelSide.swift
//  2lab
//
//  Created by Phạm Việt Tú on 02/06/2024.
//

import Foundation
import SwiftUI

struct ChannelTab: View {
    @Binding var tab: Int
    
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: ListChannelViewModel
    
    @State private var showBottomBarBackground: Bool = false
    @State private var showTabBarHeaderBackground: Bool = false
    
    @State private var offset: CGFloat = 0
    @State private var widthTitle: CGFloat = 0
    
    @State private var useSearch: Bool = true
    @State private var isSearching: Bool = false
    
    let heightScreen: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabBarHeader(title: LocalizedStringKey("messages"))
            ScrollView {
                ListChannelView()
                    .padding(.horizontal)
                    .padding(.top, useSearch ? (isSearching ? 110 : 210) : 140)
                    .overlay(
                        GeometryReader { proxy -> Color in
                            let maxY = proxy.frame(in: .global).maxY
                            let minY = proxy.frame(in: .global).minY
                            
                            DispatchQueue.main.async {
                                if (minY <= (useSearch ? (isSearching ? -10 : -60) : -40)) {
                                    showTabBarHeaderBackground = true
                                } else {
                                    showTabBarHeaderBackground = false
                                }
                                
                                if ((maxY + 70) >= heightScreen) {
                                    showBottomBarBackground = true
                                } else {
                                    showBottomBarBackground = false
                                }
                                
                                offset = minY
                            }
                            
                            return Color.clear
                        },
                        alignment: .top
                    )
            }
            .animation(.smooth, value: isSearching)
            .refreshable {
                viewModel.onRefresh()
            }
            BottomBar(tab: $tab, showBottomBarBackground: $showBottomBarBackground)
        }
    }
    
    @ViewBuilder private func TabBarHeader(title: LocalizedStringKey) -> some View {
        VStack {
            ZStack {
                if !isSearching {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(.top, 20)
                        .offset(getOffset())
                        .scaleEffect(getScale())
                        .overlay(
                            GeometryReader { reader -> Color in
                                let width = reader.frame(in: .global).width
                                
                                DispatchQueue.main.async {
                                    widthTitle = width
                                }
                                
                                return Color.clear
                            }
                        )
                }
                
                if useSearch {
                    HStack {
                        HStack {
                            HStack(spacing: 15) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.gray)
                                
                                TextField(LocalizedStringKey("search"), text: $viewModel.search)
                                
                                if !viewModel.search.isEmpty {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .onTapGesture {
                                            viewModel.search = ""
                                        }
                                }
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal)
                            .background(Color.primary.opacity(0.05))
                            .cornerRadius(30)
                        }
                        .offset(y: (isSearching ? 20 : offset + 90 <= 45 ? 45 : offset + 90))
                        .onTapGesture {
                            isSearching = true
                        }
                        
                        if isSearching {
                            Text(LocalizedStringKey("cancel"))
                                .foregroundColor(.accentColor)
                                .onTapGesture {
                                    isSearching = false
                                    viewModel.search = ""
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                                .offset(y: 20)
                        }
                    }
                }
                
                if !isSearching {
                    HStack {
                        Spacer()
                        Button {
                            navigationManager.navigateTo(.createGroupChannel)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 25))
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: useSearch ? (isSearching ? 70 : 120) : 70)
            .padding()
            .background(
                Color.clear
                    .background(.ultraThinMaterial)
                    .opacity(showTabBarHeaderBackground ? 1 : 0)
                    .ignoresSafeArea()
            )
            .animation(.easeInOut, value: isSearching)
            
            Spacer()
        }
        .zIndex(1)
    }
    
    private func getOffset() -> CGSize {
        let screenWidth = UIScreen.main.bounds.width / 2
        let startPositionX: CGFloat = (-screenWidth + (widthTitle / 2) + 20)
        
        var size: CGSize = .zero
        size.width = (startPositionX - (offset * 7) < 0) ? startPositionX - (offset * 7) : 0
        size.height = (offset > -30) ? 30 + offset : 0
        
        if (offset > 0) {
            size.width = startPositionX
            size.height = 30
        }
        
        return size
    }
    
    private func getScale() -> CGFloat {
        let progress = getOffset().height / 30
        return (progress > 0.5) ? progress : 0.5
    }
}

