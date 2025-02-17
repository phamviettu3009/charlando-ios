//
//  GroupChannel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 12/03/2024.
//

import Foundation
import SwiftUI
import PhotosUI

struct GroupChannelScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var viewModel: GroupChannelViewModel
    @State private var isOpenActionSheetLeaveGroup: Bool = false
    @State private var memberIDSelected: UUID? = nil
    @State private var activeConfirm: ActiveConfirm?
    
    init(channelID: UUID) {
        viewModel = GroupChannelViewModel(channelID: channelID)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if !viewModel.isUpdatingChannel {
                    Group {
                        if let avatars = viewModel.channel?.avatars, !viewModel.isUpdatingChannel {
                            GalleryPickerView(content: {
                                VStack {
                                    if let avatarPhoto = viewModel.avatarPhoto {
                                        Image(uiImage: avatarPhoto.value as! UIImage)
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(.circle)
                                            .frame(width: 120, height: 120)
                                            .aspectRatio(contentMode: .fill)
                                            .clipped()
                                    } else {
                                        Avatar(avatars: avatars, size: 120)
                                    }
                                }
                            }, filter: .any(of: [.images, .screenshots])) { values in
                                let (url, data) = values[0]
                                let extensionFile = url.pathExtension
                                guard let mimeType = getMimeType(fileExtension: extensionFile) else { return }
                                guard let uiImage = UIImage(data: data) else { return }
                                
                                viewModel.avatarPhoto = PhotoItem(
                                    type: AttachmentType.IMAGE,
                                    data: data,
                                    value: uiImage,
                                    mimeType: mimeType,
                                    extensionFile: extensionFile
                                )
                                
                                viewModel.shouldSave = true
                            }
                        }
                        
                        Text(viewModel.channelName)
                            .font(.system(size: 20))
                            .bold()
                            .onTapGesture {
                                viewModel.groupName = viewModel.channelName
                                viewModel.isOpenSheetChangeChanelName.toggle()
                            }
                    }
                } else {
                    ProgressView()
                        .id(UUID())
                }
                
                Form {
                    Section {
                        Button {
                            viewModel.isOpenSheetListMember.toggle()
                        } label: {
                            Label(LocalizedStringKey("members"), systemImage: "person.fill")
                                .foregroundColor(Color(UIColor.label))
                        }
                        
                        Button {
                            viewModel.isOpenSheetAddMembers.toggle()
                        } label: {
                            Label(LocalizedStringKey("add_members"), systemImage: "person.fill.badge.plus")
                                .foregroundColor(Color(UIColor.label))
                        }
                        
                        Button {
                            viewModel.isOpenSheetChangeChanelName.toggle()
                        } label: {
                            Label(LocalizedStringKey("change_group_name"), systemImage: "pencil")
                                .foregroundColor(Color(UIColor.label))
                        }
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            isOpenActionSheetLeaveGroup.toggle()
                        } label: {
                            Label(LocalizedStringKey("leave_group"), systemImage: "chevron.right")
                                .foregroundColor(.red)
                        }
                    }
                }
                .frame(height: 270)
                
                Spacer()
            }
            .padding(.top, 50)
        }
        .navigationBarItems(
            trailing: Button {
                Task { await viewModel.saveGroupChannel() }
            } label: {
                Text(LocalizedStringKey("save"))
            }
                .isHidden(!viewModel.shouldSave)
        )
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(isPresented: $viewModel.isOpenSheetChangeChanelName) {
            Group {
                TextField(LocalizedStringKey("group_name"), text: $viewModel.groupName)
                    .padding(.horizontal, 40)
                    .background {
                        Rectangle()
                            .fill(Color(UIColor.secondarySystemBackground))
                            .frame(height: 40)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    .validation(viewModel.groupNameValidationContainer) { message in
                        Text(message)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.leading, 20)
                            .padding(.top, 10)
                    }
                
                Spacer()
                
                HStack {
                    ButtonCustom(
                        label: LocalizedStringKey("save"),
                        isLoading: viewModel.isUpdatingChannel,
                        disabled: false
                    ) {
                        if (viewModel.validatorManager.isAllValid()) {
                            Task { await viewModel.saveGroupChannel() }
                        }
                    }
                    .frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
        }
        .sheet(isPresented: $viewModel.isOpenSheetListMember) {
            List {
                ForEach(viewModel.members, id: \.self) { member in
                    UserItem(member: member)
                        .swipeActions {
                            if let myRole = viewModel.myRole,
                               [ChannelRole.OWNER, ChannelRole.ADMIN].contains(myRole.role),
                               myRole.userID != member.id,
                               member.role != ChannelRole.OWNER {
                                Button {
                                    memberIDSelected = member.id
                                    activeConfirm = .kickout
                                } label: {
                                    Text(LocalizedStringKey("kick_out"))
                                }
                            }
                            
                            if let myRole = viewModel.myRole,
                               [ChannelRole.OWNER, ChannelRole.ADMIN].contains(myRole.role),
                               myRole.userID != member.id {
                                if (member.role == ChannelRole.MEMBER) {
                                    Button {
                                        Task { await viewModel.addAdminRole(memberID: member.id) }
                                    } label: {
                                        Text(LocalizedStringKey("add_admin_role"))
                                    }
                                }
                                
                                if (member.role == ChannelRole.ADMIN) {
                                    Button {
                                        Task { await viewModel.revokeAdminRole(memberID: member.id) }
                                    } label: {
                                        Text(LocalizedStringKey("revoke_admin_role"))
                                    }
                                }
                            }
                            
                            if let myRole = viewModel.myRole,
                               myRole.role == ChannelRole.OWNER,
                               myRole.userID != member.id {
                                Button {
                                    memberIDSelected = member.id
                                    activeConfirm = .ownershipTransfer
                                } label: {
                                    Text(LocalizedStringKey("ownership_transfer"))
                                }
                            }
                        }
                }
            }
            .onAppear {
                Task { await viewModel.fetchListMember() }
            }
            .actionSheet(item: $activeConfirm) { item in
                ActionSheet(
                    title: Text(LocalizedStringKey("confirm_action")),
                    buttons: [
                        .destructive(Text(LocalizedStringKey("accept"))) {
                            Task {
                                switch item {
                                case .kickout:
                                    if let memberIDSelected = memberIDSelected {
                                        await viewModel.removeMembers(memberID: memberIDSelected)
                                    }
                                case .ownershipTransfer:
                                    if let memberIDSelected = memberIDSelected {
                                        await viewModel.setOwnerRole(memberID: memberIDSelected)
                                    }
                                }
                            }
                        },
                        .cancel() {
                            activeConfirm = nil
                            memberIDSelected = nil
                        }
                    ]
                )
            }
        }
        .sheet(isPresented: $viewModel.isOpenSheetAddMembers) {
            List {
                TextField(LocalizedStringKey("search"), text: $viewModel.searchFriend)
                ForEach(viewModel.friends, id: \.self) { friend in
                    SelectContainer(id: friend.id) { id, isSelected in
                        viewModel.onSelectedFriends(id, isSelected)
                    } content: {
                        UserItem(user: friend)
                    }
                }
            }
            .onAppear {
                viewModel.onRefresh()
            }
            .overlay {
                VStack {
                    Spacer()
                    ButtonCustom(
                        label: LocalizedStringKey("save"),
                        isLoading: viewModel.isAddingMembers,
                        disabled: viewModel.selectedFriends.isEmpty
                    ) {
                        Task { await viewModel.addMembers() }
                    }
                    .frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
            VStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity)
                    .isHidden(!viewModel.isLoadMoreListFriend)
                    .id(UUID())
            }
            .onAppear {
                viewModel.loadMoreListFriendOutsideChannel()
            }
            .listRowSeparator(.hidden)
        }
        .actionSheet(isPresented: $isOpenActionSheetLeaveGroup) {
            ActionSheet(
                title: Text(LocalizedStringKey("confirm_action")),
                buttons: [
                    .destructive(Text(LocalizedStringKey("accept"))) {
                        Task {
                            await viewModel.leaveGroup {
                                navigationManager.back(2)
                            }
                        }
                    },
                    .cancel() {}
                ]
            )
        }
    }
}

enum ActiveConfirm: Identifiable {
    case kickout, ownershipTransfer
    
    var id: Int {
        hashValue
    }
}
