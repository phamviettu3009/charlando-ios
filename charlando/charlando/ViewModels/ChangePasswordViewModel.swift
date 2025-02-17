//
//  ChangePasswordViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/04/2024.
//

import Foundation
import SwiftUI
import FormValidator


class ChangePasswordViewModel: ViewModel {
    private let authenticationRepository: AuthenticationRepository = AuthenticationRepositoryImpl.shared
    
    @Published var validatorManager = FormManager(validationType: .immediate)
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var confirmPasswordIncorrect: Bool = false
    @Published var changingPassword: Bool = false
    
    // MARK: - VALIDATION FILED
    
    @FormField(validator: CompositeValidator(validators: [
        NonEmptyValidator(message: LocalizedStringKey("old_password_is_not_empty").stringValue()),
    ], type: .all, strategy: .all))
    var oldPassword: String = ""
    lazy var oldPasswordValidationContainer = _oldPassword.validation(manager: validatorManager)
    
    
    @FormField(validator: CompositeValidator(validators: [
        NonEmptyValidator(message: LocalizedStringKey("new_password_is_not_empty").stringValue()),
        CountValidator(count: 6, type: .greaterThanOrEquals, message: LocalizedStringKey("new_password_must_be_at_least_6_characters").stringValue()),
        CountValidator(count: 25, type: .lessThan, message: LocalizedStringKey("new_password_is_to_long").stringValue())
    ], type: .all, strategy: .all))
    var newPassword: String = ""
    lazy var newPasswordValidationContainer = _newPassword.validation(manager: validatorManager)
    
    @FormField(validator: CompositeValidator(validators: [
        NonEmptyValidator(message: LocalizedStringKey("confirm_password_is_not_empty").stringValue()),
        CountValidator(count: 6, type: .greaterThanOrEquals, message: LocalizedStringKey("confirm_password_must_be_at_least_6_characters").stringValue()),
        CountValidator(count: 25, type: .lessThan, message: LocalizedStringKey("confirm_password_is_to_long").stringValue())
    ], type: .all, strategy: .all))
    var confirmPassword: String = ""
    lazy var confirmPasswordValidationContainer = _confirmPassword.validation(manager: validatorManager)
    
    // MARK: - CHANGE PASSWORD
    
    func changePassword() async {
        guard newPassword == confirmPassword else {
            DispatchQueue.main.async {
                self.confirmPasswordIncorrect = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.confirmPasswordIncorrect = false
            }
            return
        }
        
        DispatchQueue.main.async {
            self.changingPassword = true
        }
        let account = AccountChangePassword(
            tenantCode: TENANT_CODE,
            oldPassword: oldPassword.trimmingCharacters(in: .whitespaces),
            newPassword: newPassword.trimmingCharacters(in: .whitespaces)
        )
        do {
            let _ = try await authenticationRepository.changePassword(account: account)
            putMessage("change_password_success", .green)
            resetData()
        } catch {
            print("error: \(error)")
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.putMessage(nil)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.changingPassword = false
        }
    }
}

extension ChangePasswordViewModel {
    func putMessage(_ message: String?, _ messageColor: Color = .red) {
        DispatchQueue.main.async {
            self.message = message
            self.messageColor = messageColor
        }
    }
    
    func resetData() {
        DispatchQueue.main.async {
            self.oldPassword = ""
            self.newPassword = ""
            self.confirmPassword = ""
            self.changingPassword = false
        }
    }
}
