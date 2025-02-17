//
//  Setting.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 13/11/2023.
//

import SwiftUI
import Foundation
import PhotosUI
import ScrollViewSectionKit

struct SettingView: View {
    @EnvironmentObject var contentViewViewModel: ContentViewViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: SettingViewModel
    @AppStorage("language") private var language: String = "default"
    
    var rowBackgroundColor = Color(UIColor.secondarySystemBackground)
    
    var body: some View {
        LazyVStack {
            ScrollViewSection {
                Button {
                    viewModel.isOpenSheetLanguage = true
                } label: {
                    HStack {
                        if let currentLanguage = languages.first(where: { lang in
                            lang.key == language
                        }) {
                            Text(currentLanguage.label)
                                .foregroundColor(Color(UIColor.label))
                        }
                        
                        Spacer()
                    }
                }
            } header: {
                Text(LocalizedStringKey("language"))
            }
            .scrollViewRowBackgroundColor(rowBackgroundColor)
            
            ScrollViewSection {
                SwitcherTheme()
                    .scrollViewRowInsets(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
            } header: {
                Text(LocalizedStringKey("theme"))
            }
            .scrollViewRowBackgroundColor(rowBackgroundColor)
            
            ScrollViewSection {
                Button {
                    navigationManager.navigateTo(.deviceManager)
                } label: {
                    HStack {
                        Text(LocalizedStringKey("device_manager"))
                            .foregroundColor(Color(UIColor.label))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .imageScale(.small)
                            .foregroundColor(Color(UIColor.placeholderText))
                    }
                }
                
                Button {
                    navigationManager.navigateTo(.changePassword)
                } label: {
                    HStack {
                        Text(LocalizedStringKey("change_password"))
                            .foregroundColor(Color(UIColor.label))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .imageScale(.small)
                            .foregroundColor(Color(UIColor.placeholderText))
                    }
                }
            }
            .scrollViewRowBackgroundColor(rowBackgroundColor)
            
            ScrollViewSection {
                Button {
                    Task {
                        await viewModel.logout {
                            DispatchQueue.main.async {
                                contentViewViewModel.isLoggedIn = false
                            }
                        }
                    }
                } label: {
                    if (viewModel.isLogout) {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .id(UUID())
                    } else {
                        HStack {
                            Text(LocalizedStringKey("logout"))
                                .foregroundColor(Color(UIColor.label))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .imageScale(.small)
                                .foregroundColor(Color(UIColor.placeholderText))
                        }
                    }
                }
                .disabled(viewModel.isLogout)
            }
            .scrollViewRowBackgroundColor(rowBackgroundColor)
            
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                ScrollViewSection {
                    Text(LocalizedStringKey("current_app_version \(appVersion)"))
                }
                .scrollViewRowBackgroundColor(rowBackgroundColor)
            }
        }
        .scrollViewSectionBackgroundColor(.clear)
        .sheet(isPresented: $viewModel.isOpenSheetLanguage) {
            List(languages, id: \.self) { lang in
                Button {
                    DispatchQueue.main.async {
                        language = lang.key
                        viewModel.isOpenSheetLanguage.toggle()
                    }
                } label: {
                    HStack {
                        Text(lang.label)
                        Spacer()
                        if (language == lang.key) {
                            Image(systemName: lang.icon)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isOpenSheetEditInfo) {
            ScrollView {
                VStack(spacing: 30) {
                    if let avatarUrl = viewModel.avatarUrl, !viewModel.isUpdatingUser {
                        GalleryPickerView(content: {
                            ZStack {
                                if let avatarPhoto = viewModel.avatarPhoto {
                                    Image(uiImage: avatarPhoto.value as! UIImage)
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(.circle)
                                        .frame(width: 120, height: 120)
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                } else {
                                    Avatar(avatars: [avatarUrl], size: 120)
                                }
                                
                                Image(systemName: "pencil")
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .background(Color.accentColor)
                                    .clipShape(.circle)
                                    .offset(x: 40, y: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(.background, lineWidth: 2)
                                            .offset(x: 40, y: 40)
                                    )
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
                        }
                    }
                    
                    LabelTextFieldContainer(systemName: "person.fill", label: LocalizedStringKey("full_name")) {
                        TextFieldCustom(label: LocalizedStringKey("full_name"), text: $viewModel.fullNameField)
                    }
                    .padding(.horizontal)
                    .validation(viewModel.fullNameValidationContainer, errorView: { message in
                        Text(message)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.leading, 20)
                            .padding(.top, 10)
                    })
                    
                    LabelTextFieldContainer(systemName: "envelope.fill", label: LocalizedStringKey("email")) {
                        TextFieldCustom(label: LocalizedStringKey("email"), text: $viewModel.emailField)
                    }
                    .padding(.horizontal)
                    .validation(viewModel.emailValidationContainer, errorView: { message in
                        Text(message)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.leading, 20)
                            .padding(.top, 10)
                    })
                    
                    LabelTextFieldContainer(systemName: "phone.fill", label: LocalizedStringKey("phone_number")) {
                        PhoneTextField(country: $viewModel.country, phoneNumber: $viewModel.phoneField)
                    }
                    .padding(.horizontal)
                    .validation(viewModel.phoneValidationContainer, errorView: { message in
                        Text(message)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.leading, 20)
                            .padding(.top, 10)
                    })
                    
                    LabelTextFieldContainer(label: LocalizedStringKey("gender")) {
                        GenderPicker(select: $viewModel.genderField)
                            .padding(.top, 6)
                    }
                    .padding(.horizontal)
                    
                    LabelTextFieldContainer(label: LocalizedStringKey("dob")) {
                        DatePickerCustom(selection: $viewModel.dob)
                            .padding(.top, 6)
                    }
                    .padding(.horizontal)
                    
                    LabelTextFieldContainer(label: LocalizedStringKey("show_email_to_everyone")) {
                        ToggleCustom(
                            toggle: $viewModel.publicEmail,
                            yesLabel: LocalizedStringKey("show"),
                            noLabel: LocalizedStringKey("hide"),
                            onChange: {
                                Task { await viewModel.updateSetting() }
                            }
                        )
                    }
                    .padding(.horizontal)
                    
                    LabelTextFieldContainer(label: LocalizedStringKey("show_phone_number_to_everyone")) {
                        ToggleCustom(
                            toggle: $viewModel.publicPhoneNumber,
                            yesLabel: LocalizedStringKey("show"),
                            noLabel: LocalizedStringKey("hide"),
                            onChange: {
                                Task { await viewModel.updateSetting() }
                            }
                        )
                    }
                    .padding(.horizontal)
                    
                    LabelTextFieldContainer(label: LocalizedStringKey("show_gender_to_everyone")) {
                        ToggleCustom(
                            toggle: $viewModel.publicGender,
                            yesLabel: LocalizedStringKey("show"),
                            noLabel: LocalizedStringKey("hide"),
                            onChange: {
                                Task { await viewModel.updateSetting() }
                            }
                        )
                    }
                    .padding(.horizontal)
                    
                    LabelTextFieldContainer(label: LocalizedStringKey("show_dob_to_everyone")) {
                        ToggleCustom(
                            toggle: $viewModel.publicDob,
                            yesLabel: LocalizedStringKey("show"),
                            noLabel: LocalizedStringKey("hide"),
                            onChange: {
                                Task { await viewModel.updateSetting() }
                            }
                        )
                    }
                    .padding(.horizontal)
                    
                    LabelTextFieldContainer(label: LocalizedStringKey("cover_photo")) {
                        VStack(spacing: 0) {
                            Group {
                                if let coverPhotoUrl = viewModel.coverPhotoUrl {
                                    if let coverPhoto = viewModel.coverPhoto {
                                        Image(uiImage: coverPhoto.value as! UIImage)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        CoverPhotoProfile(url: coverPhotoUrl)
                                            .scaledToFill()
                                    }
                                }
                            }
                            .cornerRadius(10)
                            
                            GalleryPickerView(content: {
                                Image(systemName: "pencil")
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .background(Color.accentColor)
                                    .clipShape(.circle)
                                    .overlay(
                                        Circle()
                                            .stroke(.background, lineWidth: 2)
                                    )
                            }, filter: .any(of: [.images, .screenshots])) { values in
                                let (url, data) = values[0]
                                let extensionFile = url.pathExtension
                                guard let mimeType = getMimeType(fileExtension: extensionFile) else { return }
                                guard let uiImage = UIImage(data: data) else { return }
                                
                                viewModel.coverPhoto = PhotoItem(
                                    type: AttachmentType.IMAGE,
                                    data: data,
                                    value: uiImage,
                                    mimeType: mimeType,
                                    extensionFile: extensionFile
                                )
                            }
                            .offset(y: -15)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    HStack {
                        ButtonCustom(
                            label: LocalizedStringKey("save"),
                            isLoading: viewModel.isUpdatingUser,
                            disabled: false
                        ) {
                            if (viewModel.validatorManager.isAllValid()) {
                                Task { await viewModel.saveUser() }
                            }
                        }
                        .frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .onAppear {
                viewModel.fetchUserFromCoreData()
                Task {
                    await viewModel.fetchUserFromAPIs()
                }
            }
            .onDisappear {
                viewModel.avatarPhoto = nil
                viewModel.coverPhoto = nil
            }
            .padding(.top, 50)
        }
    }
}


struct SettingScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

