//
//  ListRequestAddFriendScreen.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 20/03/2024.
//

import Foundation
import SwiftUI

struct ListRequestAddFriendScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject var viewModel = ListRequestAddFriendViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.users, id: \.self) { user in
                Button(action: {
                    navigationManager.navigateTo(.userInfo(userID: user.id))
                }, label: {
                    UserItem(user: user)
                })
                .listSectionSeparator(.hidden, edges: .top)
            }
            
            VStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity)
                    .isHidden(!viewModel.isLoadMoreListUser)
                    .id(UUID())
            }
            .listRowSeparator(.hidden)
            .onAppear {
                viewModel.loadMoreListUser()
            }
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.search, prompt: LocalizedStringKey("search"))
        .refreshable {
            viewModel.onRefresh()
        }
        .navigationTitle(LocalizedStringKey("friend_request_list"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
