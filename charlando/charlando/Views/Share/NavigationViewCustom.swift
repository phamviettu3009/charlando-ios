//
//  NavigationViewCustom.swift
//  2lab
//
//  Created by Phạm Việt Tú on 27/05/2024.
//

import Foundation
import SwiftUI

struct NavigationViewCustom<Content : View>: View {
    @State private var  searchToggle: Bool = false
    @State private var offset: CGFloat = 0
    @State private var starOffset: CGFloat = 0
    @State private var titleOffset: CGFloat = 0
    @State private var titleBarHeight: CGFloat = 100
    
    var title: LocalizedStringKey
    var leadingHeader: () -> AnyView = { AnyView(EmptyView()) }
    var trailingHeader: () -> AnyView = { AnyView(EmptyView()) }
    var showSearch: Bool = true
    var refreshable: () -> Void = {}
    @Binding var search: String
    var content: () -> Content
    
    init(
        title: LocalizedStringKey,
        leadingHeader: @escaping () -> AnyView = { AnyView(EmptyView()) },
        trailingHeader: @escaping () -> AnyView = { AnyView(EmptyView()) },
        showSearch: Bool = true,
        refreshable: @escaping () -> Void = {},
        search: Binding<String>? = nil,
        content: @escaping () -> Content
    ) {
        self.title = title
        self.leadingHeader = leadingHeader
        self.trailingHeader = trailingHeader
        self.showSearch = showSearch
        self.refreshable = refreshable
        self._search = search ?? .constant("")
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                if !searchToggle {
                    HStack {
                        leadingHeader()
                        Spacer()
                        trailingHeader()
                    }
                    .frame(maxHeight: 20)
                    .padding(.horizontal)
                    
                    // Title
                    HStack {
                        Text(title)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .overlay(
                                GeometryReader { reader -> Color in
                                    let width = reader.frame(in: .global).maxX
                                    
                                    DispatchQueue.main.async {
                                        if titleOffset == 0 {
                                            titleOffset = width
                                        }
                                    }
                                    
                                    return Color.clear
                                }
                                    .frame(width: 0, height: 0)
                            )
                            .padding()
                            .scaleEffect(getScale())
                            .offset(getOffset())
                        
                        Spacer()
                    }
                }
                
                if showSearch {
                    VStack {
                        HStack {
                            HStack(spacing: 15) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.gray)
                                
                                TextField(LocalizedStringKey("search"), text: $search)
                                
                                if !search.isEmpty {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .onTapGesture {
                                            search = ""
                                        }
                                }
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal)
                            .background(Color.primary.opacity(0.05))
                            .cornerRadius(8)
                            .onTapGesture {
                                searchToggle = true
                            }
                            
                            if searchToggle {
                                Text(LocalizedStringKey("cancel"))
                                    .foregroundColor(.accentColor)
                                    .onTapGesture {
                                        search = ""
                                        searchToggle = false
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                    .offset(y: offset > 0 && !searchToggle ? (offset <= 75 ? -offset : -75) : 0)
                }
            }
            .zIndex(1)
            .padding(.bottom, !searchToggle ? getOffset().height : 20)
            .background(
                Color.clear
                    .background(.ultraThinMaterial)
                    .opacity(getOffset().height > (searchToggle ? -1 : -50) ? 0 : 1)
                    .blur(radius: 0.5)
                    .ignoresSafeArea()
            )
            .overlay(
                GeometryReader { reader -> Color in
                    let height = reader.frame(in: .global).minY
                    
                    DispatchQueue.main.async {
                        if titleBarHeight == 0 {
                            // Get the current window scene
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                // Get the first window from the window scene
                                if let window = windowScene.windows.first {
                                    titleBarHeight = height - window.safeAreaInsets.top
                                }
                            }
                        }
                    }
                    
                    return Color.clear
                }
            )
            .animation(.easeInOut, value: searchToggle)
            
            ScrollView(.vertical, showsIndicators: false) {
                content()
                    .padding(.top, 10)
                    .padding(.top, !searchToggle ? titleBarHeight : 60)
                    .overlay(
                        GeometryReader { proxy -> Color in
                            let minY = proxy.frame(in: .global).minY
                            
                            DispatchQueue.main.async {
                                if starOffset == 0 {
                                    starOffset = minY
                                }
                                
                                offset = starOffset - minY
                            }
                            
                            return Color.clear
                        }
                            .frame(width: 0, height: 0), alignment: .top
                    )
            }
            .refreshable {
                refreshable()
            }
        }
        .onAppear {
            titleBarHeight = showSearch ? 160 : 100
        }
    }
    
    func getOffset() -> CGSize {
        var size: CGSize = .zero
        let screenWidth = UIScreen.main.bounds.width / 2
        size.width = offset > 0 ? (offset * 2.5 <= (screenWidth - titleOffset) ? offset * 2.5 : (screenWidth - titleOffset)) : 0
        size.height = offset > 0 ? (offset <= 50 ? -offset : -50) : 0
        return size
    }
    
    func getScale() -> CGFloat {
        if offset > 0 {
            let progress = 1 - ((getOffset().height) / -100)
            return progress
        } else {
            return 1
        }
    }
}
