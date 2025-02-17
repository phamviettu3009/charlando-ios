//
//  AuthenticationReposetory.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 10/11/2023.
//

import Foundation

class AuthenticationRepositoryImpl: AuthenticationRepository {
    static let shared = AuthenticationRepositoryImpl()
    
    let apiManager = APIManager.shared
    
    func login(accountLogin: AccountLogin) async throws -> Token {
        let body = accountLogin.asJson()
        let data = try await apiManager.performRequest(endpoint: LOGIN_ENDPOINT_ENDPOINT, method: "POST", body: body)
        let token = try JSONDecoder().decode(Token.self, from: data)
        return token
    }
    
    func registeringEmail(accountRegister: AccountRegister) async throws -> RegisterResponse {
        let body = accountRegister.asJson()
        let data = try await apiManager.performRequest(endpoint: REGISTER_EMAIL_ENDPOINT, method: "POST", body: body)
        let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
        return registerResponse
    }
    
    func verifyAccount(accountVerify: AccountVerify) async throws -> Any {
        let body = accountVerify.asJson()
        let data = try await apiManager.performRequest(endpoint: VERIFY_ACCOUNT_ENDPOINT, method: "POST", body: body)
        return data
    }
    
    func resendVerifyCode(account: Account) async throws -> Any {
        let body = account.asJson()
        let data = try await apiManager.performRequest(endpoint: RESEND_VERIFY_CODE_ENDPOINT, method: "POST", body: body)
        return data
    }
    
    func getDevices() async throws -> [Device] {
        let data = try await apiManager.performRequest(endpoint: GET_LIST_DEVICE_ENDPOINT, method: "GET")
        let devices = try JSONDecoder().decode([Device].self, from: data)
        return devices
    }
    
    func logout(deviceID: String) async throws {
        let deviceID = deviceID.lowercased().data(using: .utf8)
        let _ = try await apiManager.performRequest(endpoint: LOGOUT_ENDPOINT, method: "POST", body: deviceID)
    }
    
    func logoutAll() async throws {
        let _ = try await apiManager.performRequest(endpoint: LOGOUT_ALL_ENDPOINT, method: "POST")
    }
    
    func changePassword(account: AccountChangePassword) async throws {
        let body = account.asJson()
        let _ = try await apiManager.performRequest(endpoint: CHANGE_PASSWORD_ENDPOINT, method: "POST", body: body)
    }
    
    func requestForgotPassword(account: Account) async throws {
        let body = account.asJson()
        let _ = try await apiManager.performRequest(endpoint: REQUEST_FORGOT_PASSWORD, method: "POST", body: body)
    }
    
    func forgotPassword(accountForgotPassword: AccountForgotPassword) async throws {
        let body = accountForgotPassword.asJson()
        let _ = try await apiManager.performRequest(endpoint: FORGOT_PASSWORD, method: "POST", body: body)
    }
    
    func updateFirebaseToken(firebaseDeviceToken: FirebaseDeviceToken) async throws {
        let body = firebaseDeviceToken.asJson()
        let _ = try await apiManager.performRequest(endpoint: UPDATE_FIREBASE_TOKEN, method: "POST", body: body)
    }
}
