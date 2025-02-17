//
//  Login.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 10/11/2023.
//

import SwiftUI
import Foundation

struct LoginScreen: View {
    @EnvironmentObject var contentViewViewModel: ContentViewViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject var viewModel = LoginViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    @State var isHidden: Bool = true
    
    var body: some View {
        VStack {
            if (!isHidden) {
                AnimatedBackground3 {
                    ScrollView(showsIndicators: false) {
                        Image("logo_image")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .scaledToFill()
                        
                        Text(LocalizedStringKey("login"))
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .padding(.bottom, 30)
                            .foregroundColor(.accentColor)
                        
                        TextFiledLine(LocalizedStringKey("email"), text: $viewModel.email, keyboardType: .emailAddress) {
                            Image(systemName: "envelope")
                        }
                        .textInputAutocapitalization(.never)
                        SecureFieldLine(LocalizedStringKey("password"), text: $viewModel.password) {
                            Image(systemName: "lock")
                        }
                        
                        ButtonCustom(
                            label: LocalizedStringKey("login"),
                            isLoading: viewModel.isLoading
                        ) {
                            Task {
                                await viewModel.login {
                                    DispatchQueue.main.async {
                                        contentViewViewModel.isLoggedIn = true
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .frame(height: 60)
                        
                        if let message = viewModel.message {
                            Text(message)
                                .foregroundColor(.red)
                                .padding(.bottom, 10)
                        }
                        
                        HStack {
                            Text(LocalizedStringKey("you_don't_have_an_account"))
                                .font(.system(size: 13, weight: .light, design: .rounded))
                            Text(LocalizedStringKey("register"))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.accentColor)
                                .onTapGesture {
                                    navigationManager.navigateTo(.register)
                                }
                                .listRowSeparator(.hidden)
                        }
                        
                        Text(LocalizedStringKey("forgot_password"))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.accentColor)
                            .onTapGesture {
                                navigationManager.navigateTo(.forgotPassword)
                            }
                            .listRowSeparator(.hidden)
                            .padding(.top, 10)
                        
                        Spacer()
                        
                        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                            Text(LocalizedStringKey("current_app_version \(appVersion)"))
                                .font(.system(size: 13, weight: .light, design: .rounded))
                                .padding(.top, 10)
                        }
                    }
                    .padding(20)
                }
                .ignoresSafeArea(.keyboard)
            }
        }
        .onAppear {
            isHidden = false
        }
        .onDisappear {
            isHidden = true
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(30)
        .shadow(color: colorScheme == .light ? Color.black.opacity(0.3) : Color.white.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(20)
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}

