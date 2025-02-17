//
//  ForgotPasswordViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 19/04/2024.
//

import Foundation
import SwiftUI
import FormValidator

class ForgotPasswordViewModel: ViewModel {
    private let authenticationRepository: AuthenticationRepository = AuthenticationRepositoryImpl.shared
    
    @Published var validatorManager = FormManager(validationType: .immediate)
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var side: ForgotPasswordSide = .request
    @Published var textOtp: String = ""
    @Published var isDisabledVerifyAccountButton: Bool = true
    
    // MARK: - VALIDATION FILED
    
    @FormField(validator: CompositeValidator(validators: [
        NonEmptyValidator(message: LocalizedStringKey("new_password_is_not_empty").stringValue()),
        CountValidator(count: 6, type: .greaterThanOrEquals, message: LocalizedStringKey("new_password_must_be_at_least_6_characters").stringValue()),
        CountValidator(count: 25, type: .lessThan, message: LocalizedStringKey("new_password_must_be_at_least_6_characters").stringValue())
    ], type: .all, strategy: .all))
    var newPassword: String = ""
    lazy var newPasswordValidationContainer = _newPassword.validation(manager: validatorManager)
    
    public enum ForgotPasswordSide {
        case request
        case setPassword
        case verify
        case success
    }
    
    private enum LoadType: LoadCase {
        case Loading
    }
    
    // MARK: - FORGOT PASSWORD
    
    func requestForgot() async {
        do {
            loader(true, LoadType.Loading)
            let account = Account(user: email.trimmingCharacters(in: .whitespaces), tenantCode: TENANT_CODE)
            let _ = try await authenticationRepository.requestForgotPassword(account: account)
            DispatchQueue.main.async {
                self.side = .setPassword
            }
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, LoadType.Loading)
    }
    
    func setPassword() {
        DispatchQueue.main.async {
            self.side = .verify
        }
    }
    
    func changePassword() async {
        do {
            loader(true, LoadType.Loading)
            let accountForgotPassword = AccountForgotPassword(
                user: email.trimmingCharacters(in: .whitespaces),
                tenantCode: TENANT_CODE,
                newPassword: newPassword.trimmingCharacters(in: .whitespaces),
                verifyCode: textOtp
            )
            let _ = try await authenticationRepository.forgotPassword(accountForgotPassword: accountForgotPassword)
            putMessage("change_password_success", .green)
            DispatchQueue.main.async {
                self.side = .success
            }
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, LoadType.Loading)
    }
}

extension ForgotPasswordViewModel {
    func putMessage(_ message: String?, _ messageColor: Color = .red) {
        DispatchQueue.main.async {
            self.message = message
            self.messageColor = messageColor
        }
    }
    
    func loader(_ value: Bool, _ caseLoader: LoadCase? = nil) {
        DispatchQueue.main.async {
            switch caseLoader! {
            case LoadType.Loading:
                self.isLoading = value
            default:
                break
            }
            
        }
    }
}
