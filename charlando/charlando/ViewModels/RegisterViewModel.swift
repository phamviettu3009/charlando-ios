//
//  RegisterViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 19/11/2023.
//

import Foundation
import SwiftUI
import FirebaseMessaging
import FormValidator

class RegisterViewModel: ViewModel {
    private let authRepository: AuthenticationRepository = AuthenticationRepositoryImpl.shared
    
    enum LoadType: LoadCase {
        case RegisteringEmail
        case VerifyingCode
        case ResendingVerifyCode
    }
    
    @Published var validatorManager = FormManager(validationType: .immediate)
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var code: String = ""
    @Published var isRegisteringEmail: Bool = false
    @Published var isVerifyingCode: Bool = false
    @Published var isResendingVerifyCode: Bool = false
    @Published var side: String = RegisterSide.REGISTER_EMAIL
    @Published var isDisabledVerifyAccountButton: Bool = true
    @Published var textOtp: String = ""
    
    // MARK: - VALIDATION FILED
    
    @FormField(validator: CompositeValidator(validators: [
        NonEmptyValidator(message: LocalizedStringKey("password_is_not_empty").stringValue()),
        CountValidator(count: 6, type: .greaterThanOrEquals, message: LocalizedStringKey("password_must_be_at_least_6_characters").stringValue()),
        CountValidator(count: 25, type: .lessThan, message: LocalizedStringKey("password_is_to_long").stringValue())
    ], type: .all, strategy: .all))
    var password: String = ""
    lazy var passwordValidationContainer = _password.validation(manager: validatorManager)
    
    @FormField(validator: CompositeValidator(validators: [
        NonEmptyValidator(message: LocalizedStringKey("email_is_not_empty").stringValue()),
        EmailValidator(message: LocalizedStringKey("incorrect_email_format").stringValue())
    ], type: .all, strategy: .all))
    var email: String = ""
    lazy var emailValidationContainer = _email.validation(manager: validatorManager)
    
    
    func registerEmail() async {
        loader(true, LoadType.RegisteringEmail)
        do {
            let accountRegister = AccountRegister(
                user: email.trimmingCharacters(in: .whitespaces),
                password: password.trimmingCharacters(in: .whitespaces),
                tenantCode: TENANT_CODE
            )
            let registerResponse = try await authRepository.registeringEmail(accountRegister: accountRegister)
            DispatchQueue.main.async {
                self.side = registerResponse.status
            }
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, LoadType.RegisteringEmail)
    }
    
    func verifyAccount(onSuccess: @escaping () -> Void) async {
        guard !isDisabledVerifyAccountButton else { return }
        
        loader(true, LoadType.VerifyingCode)
        do {
            let accountVerify = AccountVerify(
                user: email.trimmingCharacters(in: .whitespaces),
                verifyCode: textOtp,
                tenantCode: TENANT_CODE
            )
            let _ = try await authRepository.verifyAccount(accountVerify: accountVerify)
            await loginAfterVerify(onSuccess: onSuccess)
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, LoadType.VerifyingCode)
    }
    
    func resendVerifyCode() async {
        loader(true, LoadType.ResendingVerifyCode)
        do {
            let account = Account(user: email.trimmingCharacters(in: .whitespaces), tenantCode: TENANT_CODE)
            let _ = try await authRepository.resendVerifyCode(account: account)
            putMessage("resend_verify_code_success", .accentColor)
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, LoadType.ResendingVerifyCode)
    }
    
    func loginAfterVerify(onSuccess: @escaping () -> Void) async {
        do {
            let deviceID = await UIDevice.current.identifierForVendor ?? UUID()
            let deviceName = await UIDevice.current.name
            let deviceSystemName = await UIDevice.current.systemName
            let systemVersion = await UIDevice.current.systemVersion
            let os = await getDeviceOS()
            let accountLogin = AccountLogin(
                user: email.trimmingCharacters(in: .whitespaces),
                password: password.trimmingCharacters(in: .whitespaces),
                tenantCode: TENANT_CODE,
                deviceID: deviceID.uuidString.lowercased(),
                deviceName: deviceName,
                deviceSystemName: deviceSystemName,
                os: os,
                description: systemVersion
            )
            let token = try await authRepository.login(accountLogin: accountLogin)
            guard let tokenData = token.asData() else { return }
            try KeyChainManager.save(service: SERVICE_NAME, account: ACCOUNT_NAME, data: tokenData)
            APIManager.shared.setToken(token: token.accessToken)
            SocketIOManager.shared.setup() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    NotificationCenter.default.post(name: Notification.Name("initSocketListChannel"), object: nil)
                }
            }
            await updateFirebaseToken()
            resetData()
            onSuccess()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func updateFirebaseToken() async {
        do {
            guard let token = Messaging.messaging().fcmToken else { return }
            let deviceID = await UIDevice.current.identifierForVendor ?? UUID()
            let firebaseDeviceToken = FirebaseDeviceToken(
                deviceID: deviceID.uuidString.lowercased(),
                firebaseToken: token
            )
            try await authRepository.updateFirebaseToken(firebaseDeviceToken: firebaseDeviceToken)
        } catch {
            print("error upload fcm token: \(error)")
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
}

extension RegisterViewModel {
    private func putMessage(_ message: String?, _ messageColor: Color = .red) {
        DispatchQueue.main.async {
            self.message = message
            self.messageColor = messageColor
        }
    }
    
    private func loader(_ value: Bool, _ caseLoader: LoadCase? = nil) {
        DispatchQueue.main.async {
            switch caseLoader! {
            case LoadType.RegisteringEmail:
                self.isRegisteringEmail = value
            case LoadType.VerifyingCode:
                self.isVerifyingCode = value
            case LoadType.ResendingVerifyCode:
                self.isResendingVerifyCode = value
            default:
                break
            }
        }
    }
    
    private func resetData() {
        DispatchQueue.main.async {
            self.message = nil
            self.messageColor = .red
            self.email = ""
            self.code = ""
            self.password = ""
            self.isRegisteringEmail = false
            self.isVerifyingCode = false
            self.isResendingVerifyCode = false
            self.side = RegisterSide.REGISTER_EMAIL
            self.isDisabledVerifyAccountButton = true
            self.textOtp = ""
        }
    }
}

//RegexValidationRule(pattern: "^[\\w\\.-]+@([\\w-]+\\.)+[\\w-]{2,4}$", error: LocalizedStringKey("incorrect_email_format").stringValue())
