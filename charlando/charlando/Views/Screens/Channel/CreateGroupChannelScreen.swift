//
//  GroupChannel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 30/11/2023.
//

import Foundation
import SwiftUI

struct CreateGroupChannelScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject var viewModel = CreateGroupChannelViewModel()
    
    var body: some View {
        TextField(LocalizedStringKey("group_name"), text: $viewModel.groupName)
            .validation(viewModel.groupNameValidationContainer) { message in
                Text(message)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 20)
        List {
            ForEach(viewModel.friends, id: \.self) { friend in
                SelectContainer(id: friend.id) { id, isSelected in
                    viewModel.onSelectedFriends(id, isSelected)
                } content: {
                    UserItemBase(user: Binding.constant(friend))
                }
            }
            
            VStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity)
                    .isHidden(!viewModel.isLoadMoreListFriend)
                    .id(UUID())
            }
            .onAppear {
                viewModel.loadMoreListFriend()
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.onRefresh()
        }
        .navigationTitle(LocalizedStringKey("create_group_chat"))
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.search, prompt: LocalizedStringKey("search"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if (viewModel.validatorManager.isAllValid()) {
                        Task {
                            await viewModel.createGroup {
                                navigationManager.back()
                            }
                        }
                    }
                } label: {
                    if (viewModel.isCreatingGroupChat) {
                        ProgressView()
                    } else {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                .disabled(viewModel.isCreatingGroupChat)
            }
        }
    }
}

#Preview {
    CreateGroupChannelScreen()
}
