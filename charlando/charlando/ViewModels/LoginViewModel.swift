//
//  LoginViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 10/11/2023.
//

import Foundation
import SwiftUI
import FirebaseMessaging

class LoginViewModel: ViewModel {
    private let authRepository: AuthenticationRepository = AuthenticationRepositoryImpl.shared
    
    enum LoadType: LoadCase {
        case LoadingToken
    }
    
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading: Bool = false
    
    func login(loginSuccess: @escaping () -> Void) async {
        loader(true, LoadType.LoadingToken)
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
            loginSuccess()
            resetData()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, LoadType.LoadingToken)
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

extension LoginViewModel {
    private func putMessage(_ message: String?, _ messageColor: Color = .red) {
        DispatchQueue.main.async {
            self.message = message
            self.messageColor = messageColor
        }
    }
    
    private func loader(_ value: Bool, _ caseLoader: LoadCase? = nil) {
        DispatchQueue.main.async {
            switch caseLoader! {
            case LoadType.LoadingToken:
                self.isLoading = value
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
            self.password = ""
            self.isLoading = false
        }
    }
}
