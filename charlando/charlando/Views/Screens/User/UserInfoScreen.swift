//
//  UserInfo.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 15/03/2024.
//

import Foundation
import SwiftUI
import ScrollViewSectionKit

struct UserInfoScreen: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var viewModel: UserInfoViewModel
    
    let widthScreen: CGFloat = UIScreen.main.bounds.width - 40
    
    init(userID: UUID) {
        viewModel = UserInfoViewModel(userID: userID)
    }
    
    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            let size = $0.size
            
            ZStack(alignment: .top) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack{
                        // MARK: - Cover photo
                        CoverPhoto(size: size, safeArea: safeArea)
            
                        HStack {
                            Spacer()
                            
                            if let avatar = viewModel.userInfo?.avatar {
                                Avatar(avatars: [avatar], size: 100)
                                    .background(
                                        Circle()
                                            .stroke(.background, lineWidth: 2)
                                    )
                            }
                            
                            Spacer()
                        }
                        .frame(height: 100)
                        .padding(.top, -70)
                        .zIndex(1)
                        
                        VStack{
                            if let fullName = viewModel.userInfo?.fullName {
                                Text(fullName)
                                    .fontWeight(.heavy)
                            }
                            
                            HStack(spacing: 0) {
                                VStack {
                                    let isDisabledChat: Bool = viewModel.userInfo?.channelID == nil
                                    Button {
                                        guard let channelID = viewModel.userInfo?.channelID else { return }
                                        navigationManager.navigateTo(.messageScreen(channelID: channelID))
                                    } label: {
                                        Text(LocalizedStringKey("chat"))
                                            .font(.system(size: 14))
                                            .foregroundColor(isDisabledChat ? .gray.opacity(0.5) : .blue)
                                    }
                                    .disabled(isDisabledChat)
                                }
                                .frame(width: widthScreen/3)
                                
                                VStack {
                                    Text(LocalizedStringKey("friend"))
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                    
                                    if let friend = viewModel.userInfo?.friend {
                                        Text("\(friend)")
                                            .foregroundColor(.blue)
                                            .bold()
                                    }
                                }
                                .frame(width: widthScreen/3)
                                .overlay(
                                    Rectangle()
                                        .frame(width: 1)
                                        .foregroundColor(Color.gray),
                                    alignment: .leading
                                )
                                .overlay(
                                    Rectangle()
                                        .frame(width: 1)
                                        .foregroundColor(Color.gray),
                                    alignment: .trailing
                                )
                                
                                VStack {
                                    if (viewModel.isUpdate) {
                                        ProgressView()
                                            .id(UUID())
                                    } else {
                                        ActionButton()
                                    }
                                }
                                .frame(width: widthScreen/3)
                            }
                            .padding(.vertical, 10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .padding(.top, 10)
                            
                            ScrollViewSection {
                                if let email = viewModel.userInfo?.email {
                                    HStack {
                                        Text(LocalizedStringKey("email"))
                                        Spacer()
                                        Text(email)
                                            .font(.subheadline)
                                            .opacity(0.5)
                                    }
                                }
                                
                                if let phone = viewModel.userInfo?.phone {
                                    if let countryCode = viewModel.userInfo?.countryCode {
                                        HStack {
                                            Text(LocalizedStringKey("phone_number"))
                                            Spacer()
                                            Text("(\(countryCode))" + phone)
                                                .font(.subheadline)
                                                .opacity(0.5)
                                        }
                                    }
                                }
                                
                                if let gender = viewModel.userInfo?.gender {
                                    HStack {
                                        Text(LocalizedStringKey("gender"))
                                        Spacer()
                                        Text(LocalizedStringKey(gender))
                                            .font(.subheadline)
                                            .opacity(0.5)
                                    }
                                }
                                
                                if let dob = viewModel.userInfo?.dob {
                                    HStack {
                                        Text(LocalizedStringKey("dob"))
                                        Spacer()
                                        Text(LocalizedStringKey(dob.asDate().asStringDate(dateFormat: "dd-MM-yyyy")))
                                            .font(.subheadline)
                                            .opacity(0.5)
                                    }
                                }
                            } header: {
                                Text(LocalizedStringKey("infomation"))
                            }
                            .scrollViewRowBackgroundColor(Color(UIColor.secondarySystemBackground))
                            .scrollViewSectionBackgroundColor(.clear)
                        }
                        .padding(.bottom, 20)
                        .zIndex(0)
                    }
                }
                .coordinateSpace(name: "SCROLL")
                
                HeaderView()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea([.bottom, .top])
    }
    
    @ViewBuilder func ActionButton() -> some View {
        let (label, labelColor): (LocalizedStringKey, Color) = switch viewModel.userInfo?.relationshipStatus {
        case FriendStatus.UNFRIEND:
            (LocalizedStringKey("add_friend"), .blue)
        case FriendStatus.FRIEND:
            (LocalizedStringKey("unfriend"), .red)
        case FriendStatus.FRIEND_REQUEST_SENT:
            (LocalizedStringKey("cancel"), .red)
        case FriendStatus.WAIT_FOR_CONFIRMATION:
            (LocalizedStringKey("confirm"), .blue)
        default:
            (LocalizedStringKey(""), .clear)
        }
        
        if (viewModel.userInfo?.relationshipStatus == FriendStatus.WAIT_FOR_CONFIRMATION) {
            VStack {
                Button {
                    Task(priority: .background) {
                        await viewModel.onConfirmAddFriend()
                    }
                } label: {
                    Text(LocalizedStringKey("confirm"))
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
                
                Button {
                    Task(priority: .background) {
                        await viewModel.onRejectAddFriend()
                    }
                } label: {
                    Text(LocalizedStringKey("reject"))
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
                .padding(.top, 10)
            }
        } else {
            Button {
                Task(priority: .background) {
                    await viewModel.onSendAction()
                }
            } label: {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(labelColor)
            }
        }
    }
    
    @ViewBuilder
    func CoverPhoto(size: CGSize, safeArea: EdgeInsets) -> some View {
        let height = size.height * 0.65
        GeometryReader { proxy in
            let size = proxy.size
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.8))
            
            if let coverPhotoUrl = viewModel.userInfo?.coverPhoto {
                CoverPhotoProfile(url: coverPhotoUrl)
                    .offset(y: minY < 0 ? (-minY / 1.2) : 0)
                    .frame(width: size.width, height: size.height + (minY > 0 ? minY : 0 ))
                    .clipped()
                    .offset(y: minY < 0 ? 0 : -minY)
            }
        }
        .frame(height: height + safeArea.top )
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        HStack {
            Image(systemName: "chevron.backward.circle.fill")
                .foregroundColor(Color.accentColor)
                .font(.system(size: 35, weight: .semibold))
                .onTapGesture {
                    navigationManager.back()
                }
            
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 150)
    }
}
