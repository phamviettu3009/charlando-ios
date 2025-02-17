//
//  Register.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 19/11/2023.
//

import Foundation
import SwiftUI

struct RegisterScreen: View {
    @StateObject var viewModel = RegisterViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            AnimatedBackground3 {
                ScrollView(showsIndicators: false) {
                    Text(LocalizedStringKey("register"))
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .padding(.bottom, 30)
                        .foregroundColor(.accentColor)
                    
                    switch (viewModel.side) {
                    case RegisterSide.REGISTER_EMAIL:
                        RegisterEmailSide()
                    case RegisterSide.VERIFICATION_ACCOUNT:
                        VerificationAccountSide()
                    default:
                        EmptyView()
                    }
                }
                .padding(20)
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(30)
        .shadow(color: colorScheme == .light ? Color.black.opacity(0.3) : Color.white.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(20)
        .environmentObject(viewModel)
    }
}

struct RegisterEmailSide: View {
    @EnvironmentObject var viewModel: RegisterViewModel
    
    var body: some View {
        VStack {
            TextFiledLine(LocalizedStringKey("email"), text: $viewModel.email, keyboardType: .emailAddress) {
                Image(systemName: "envelope")
            }
            .textInputAutocapitalization(.never)
            .validation(viewModel.emailValidationContainer) { message in
                Text(message)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
            
            SecureFieldLine(LocalizedStringKey("password"), text: $viewModel.password) {
                Image(systemName: "lock")
            }
            .validation(viewModel.passwordValidationContainer) { message in
                Text(message)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
            
            ButtonCustom(
                label: LocalizedStringKey("next"),
                isLoading: viewModel.isRegisteringEmail
            ) {
                if (viewModel.validatorManager.isAllValid()) {
                    Task { await viewModel.registerEmail() }
                }
            }
            .padding(.vertical, 10)
            .frame(height: 60)
            
            if let message = viewModel.message {
                Text(message)
                    .foregroundColor(viewModel.messageColor)
            }
        }
    }
}

struct VerificationAccountSide: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var contentViewViewModel: ContentViewViewModel
    @EnvironmentObject var viewModel: RegisterViewModel
    
    var body: some View {
        VStack {
            OtpTextField(numberOfFields: 6) { value, isDone in
                viewModel.textOtp = value
                if isDone {
                    viewModel.isDisabledVerifyAccountButton = false
                    Task {
                        await viewModel.verifyAccount {
                            navigationManager.back()
                            DispatchQueue.main.async {
                                contentViewViewModel.isLoggedIn = true
                            }
                        }
                    }
                } else {
                    viewModel.isDisabledVerifyAccountButton = true
                }
            }
            
            Group {
                if viewModel.isResendingVerifyCode {
                    ProgressView()
                } else {
                    Text(LocalizedStringKey("resend_verification_code"))
                        .foregroundColor(.accentColor)
                        .onTapGesture {
                            Task { await viewModel.resendVerifyCode() }
                        }
                }
            }
            .id(UUID())
            .frame(maxWidth: .infinity)
            .isHidden(viewModel.isVerifyingCode)
            
            ButtonCustom(
                label: LocalizedStringKey("next"),
                isLoading: viewModel.isVerifyingCode,
                disabled: viewModel.isDisabledVerifyAccountButton
            ) {
                Task {
                    await viewModel.verifyAccount {
                        navigationManager.back()
                        DispatchQueue.main.async {
                            contentViewViewModel.isLoggedIn = true
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            .frame(height: 60)
            
            if let message = viewModel.message {
                Text(LocalizedStringKey(message))
                    .foregroundColor(viewModel.messageColor)
                    .listRowSeparator(.hidden)
            }
        }
    }
}

struct RegisterScreen_Previews: PreviewProvider {
    static var previews: some View {
        RegisterScreen()
    }
}
