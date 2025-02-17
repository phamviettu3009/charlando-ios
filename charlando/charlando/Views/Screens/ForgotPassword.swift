//
//  ForgotPassword.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 19/04/2024.
//

import Foundation
import SwiftUI

struct ForgotPassword: View {
    @StateObject var viewModel = ForgotPasswordViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            AnimatedBackground3 {
                ScrollView(showsIndicators: false) {
                    Text(LocalizedStringKey("create_new_password"))
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .padding(.bottom, 30)
                        .foregroundColor(.accentColor)
                    
                    switch viewModel.side {
                    case .request:
                        requestSide()
                    case .setPassword:
                        setPasswordSide()
                    case .verify:
                        verifySide()
                    case .success:
                        successSide()
                    }
                }
                .padding(20)
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(30)
        .shadow(color: colorScheme == .light ? Color.black.opacity(0.3) : Color.white.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(20)
    }
    
    @ViewBuilder private func requestSide() -> some View {
        VStack {
            TextFiledLine(LocalizedStringKey("email"), text: $viewModel.email) {
                Image(systemName: "envelope")
            }
            .textInputAutocapitalization(.never)
            
            ButtonCustom(
                label: LocalizedStringKey("next"),
                isLoading: viewModel.isLoading
            ) {
                Task { await viewModel.requestForgot() }
            }
            .padding(.vertical, 10)
            .frame(height: 60)
            
            if let message = viewModel.message {
                Text(LocalizedStringKey(message))
                    .foregroundColor(viewModel.messageColor)
                    .font(.system(size: 14))
            }
        }
    }
    
    @ViewBuilder private func setPasswordSide() -> some View {
        VStack {
            SecureFieldLine(LocalizedStringKey("new_password"), text: $viewModel.newPassword) {
                Image(systemName: "lock")
            }
            .validation(viewModel.newPasswordValidationContainer) { message in
                Text(message)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding(.top, 10)
            }
            
            ButtonCustom(
                label: LocalizedStringKey("next"),
                isLoading: viewModel.isLoading
            ) {
                if (viewModel.validatorManager.isAllValid()) {
                    viewModel.setPassword()
                }
            }
            .padding(.vertical, 10)
            .frame(height: 60)
        }
    }
    
    @ViewBuilder private func verifySide() -> some View {
        VStack {
            OtpTextField(numberOfFields: 6) { value, isDone in
                viewModel.textOtp = value
                if isDone {
                    viewModel.isDisabledVerifyAccountButton = false
                    Task { await viewModel.changePassword() }
                } else {
                    viewModel.isDisabledVerifyAccountButton = true
                }
            }

            
            ButtonCustom(
                label: LocalizedStringKey("done"),
                isLoading: viewModel.isLoading
            ) {
                Task { await viewModel.changePassword() }
            }
            .padding(.vertical, 10)
            .frame(height: 60)
            .disabled(viewModel.isDisabledVerifyAccountButton)
            
            if let message = viewModel.message {
                Text(LocalizedStringKey(message))
                    .foregroundColor(viewModel.messageColor)
                    .font(.system(size: 14))
            }
        }
    }
    
    @ViewBuilder private func successSide() -> some View {
        if let message = viewModel.message {
            Text(LocalizedStringKey(message))
                .foregroundColor(viewModel.messageColor)
                .font(.system(size: 14))
        }
    }
}
