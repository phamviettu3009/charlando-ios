//
//  UserSide.swift
//  2lab
//
//  Created by Phạm Việt Tú on 02/06/2024.
//

import Foundation
import SwiftUI

struct HeaderTabOption: Identifiable {
    var id: Int
    var label: LocalizedStringKey
}

struct UserTab: View {
    private enum FocusedField {
        case search
    }
    
    @Binding var tab: Int
    @State var headerTab: Int = 0
    @State var headerTabOptions: [HeaderTabOption] = [
        HeaderTabOption(id: 0, label: LocalizedStringKey("all")),
        HeaderTabOption(id: 1, label: LocalizedStringKey("friends"))
    ]
    
    @EnvironmentObject var listUserViewModel: ListUserViewModel
    @EnvironmentObject var listFriendViewModel: ListFriendViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    
    @State private var showBottomBarBackground: Bool = false
    @State private var showTabBarHeaderBackground: Bool = false
    
    @State private var offset: CGFloat = 0
    @State private var widthTitle: CGFloat = 0
    @State private var search: String = ""
    @State private var useSearch: Bool = true
    @State private var isSearching: Bool = false
    @FocusState private var focusedField: FocusedField?
    @AppStorage("user_columns") private var columns: Int = 2
    
    let heightScreen: CGFloat = UIScreen.main.bounds.height
    
    @Namespace private var animationTab
    @Namespace private var animationGrid
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabBarHeader(title: LocalizedStringKey("users"))
            ScrollView {
                Group {
                    if (headerTab == 0) {
                        StaggeredGird(list: listUserViewModel.users, columns: columns) { user in
                            Button(action: {
                                navigationManager.navigateTo(.userInfo(userID: user.id))
                            }, label: {
                                UserGridItem(user: user, columns: columns)
                            })
                            .matchedGeometryEffect(id: user.id, in: animationGrid)
                        }
                    } else {
                        StaggeredGird(list: listFriendViewModel.friends, columns: columns) { friend in
                            Button(action: {
                                navigationManager.navigateTo(.userInfo(userID: friend.id))
                            }, label: {
                                UserGridItem(user: friend, columns: columns)
                            })
                            .matchedGeometryEffect(id: friend.id, in: animationGrid)
                        }
                    }
                }
                .padding(.top, useSearch ? (isSearching ? 110 : 210) : 140)
                .padding(.horizontal, 20)
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
                VStack {}
                    .listRowSeparator(.hidden)
                    .onAppear {
                        listUserViewModel.loadMoreListUser()
                    }
            }
            .padding(.bottom, 80)
            .animation(.easeInOut, value: columns)
            .animation(.smooth, value: isSearching)
            .refreshable {
                listUserViewModel.onRefresh()
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
                        HStack(spacing: 0) {
                            if !isSearching {
                                HStack {
                                    ForEach(headerTabOptions, id: \.id) { tabOption in
                                        Text(tabOption.label)
                                            .foregroundColor(headerTab == tabOption.id ? .white : Color(UIColor.label))
                                            .padding(.vertical, 5)
                                            .frame(width: (UIScreen.main.bounds.width - 160) / 2)
                                            .background {
                                                ZStack {
                                                    if (headerTab == tabOption.id) {
                                                        Rectangle()
                                                            .fill(Color.accentColor)
                                                            .cornerRadius(35)
                                                            .matchedGeometryEffect(id: "ACTIVETAB", in: animationTab)
                                                    }
                                                }
                                                .animation(.snappy, value: headerTab)
                                            }
                                            .contentShape(.rect)
                                            .onTapGesture {
                                                headerTab = tabOption.id
                                            }
                                    }
                                }
                                .frame(height: 35)
                                .padding(.horizontal, 2)
                                .background(Color(UIColor.secondarySystemBackground).opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 35))
                            }
                            
                            if !isSearching {
                                Spacer()
                            }
                            
                            HStack(spacing: 15) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.gray)
                                    .onTapGesture {
                                        isSearching = true
                                        focusedField = .search
                                    }
                                
                                if isSearching {
                                    TextField(LocalizedStringKey("search"), text: $search)
                                        .focused($focusedField, equals: .search)
                                        .onChange(of: search) { value in
                                            if (headerTab == 0) {
                                                listUserViewModel.search = value
                                            } else {
                                                listFriendViewModel.search = value
                                            }
                                        }
                                }
                                
                                if !search.isEmpty {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .onTapGesture {
                                            search = ""
                                        }
                                }
                            }
                            .padding(.vertical, isSearching ? 6 : 8)
                            .padding(.horizontal)
                            .background(Color(UIColor.secondarySystemBackground).opacity(0.7))
                            .cornerRadius(30)
                            .frame(maxWidth: isSearching ? .infinity : 50)
                        }
                        .offset(y: (isSearching ? 20 : offset + 90 <= 45 ? 45 : offset + 90))
                        
                        if isSearching {
                            Text(LocalizedStringKey("cancel"))
                                .foregroundColor(.accentColor)
                                .onTapGesture {
                                    isSearching = false
                                    search = ""
                                    listUserViewModel.search = ""
                                    listFriendViewModel.search = ""
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                                .offset(y: 20)
                        }
                    }
                    .padding(.horizontal, 6)
                }
                
                if !isSearching {
                    HStack {
                        Spacer()
                        
                        Menu {
                            Button(LocalizedStringKey("list"), action: { setColumm(1) })
                            Button(LocalizedStringKey("grid_2_column"), action: { setColumm(2) })
                            Button(LocalizedStringKey("grid_3_column"), action: { setColumm(3) })
                        } label: {
                            Label("", systemImage: "list.bullet")
                                .font(.system(size: 22))
                        }
                        
                        Button {
                            navigationManager.navigateTo(.requestAddFriend)
                        } label: {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 22))
                                .overlay(
                                    NotificationCountView(
                                        value: $listUserViewModel.numberRequestAddFriend,
                                        foreground: .white,
                                        background: .red
                                    )
                                )
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 6)
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
    
    private func setColumm(_ column: Int) {
        DispatchQueue.main.async {
            self.columns = column
        }
    }
}
