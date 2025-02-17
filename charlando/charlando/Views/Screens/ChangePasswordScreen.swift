//
//  ChangePasswordScreen.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/04/2024.
//

import Foundation
import SwiftUI

struct ChangePasswordScreen: View {
    @StateObject var viewModel = ChangePasswordViewModel()
    
    var body: some View {
        Form {
            SecureField(LocalizedStringKey("old_password"), text: $viewModel.oldPassword)
                .validation(viewModel.oldPasswordValidationContainer) { message in
                    Text(message)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.top, 10)
                }
            
            SecureField(LocalizedStringKey("new_password"), text: $viewModel.newPassword)
                .validation(viewModel.newPasswordValidationContainer) { message in
                    Text(message)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.top, 10)
                }
            
            VStack(alignment: .leading) {
                SecureField(LocalizedStringKey("confirm_password"), text: $viewModel.confirmPassword)
                    .validation(viewModel.confirmPasswordValidationContainer) { message in
                        Text(message)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.top, 10)
                    }
                
                if (viewModel.confirmPasswordIncorrect) {
                    Text(LocalizedStringKey("confirm_passwords_do_not_match"))
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                }
            }
            
            Button {
                if (viewModel.validatorManager.isAllValid()) {
                    Task { await viewModel.changePassword() }
                }
            } label: {
                if (viewModel.changingPassword) {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text(LocalizedStringKey("change_password"))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            }
            
            if let message = viewModel.message {
                Text(LocalizedStringKey(message))
                    .foregroundColor(viewModel.messageColor)
                    .font(.system(size: 14))
            }
        }
        .navigationTitle(LocalizedStringKey("change_password"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
