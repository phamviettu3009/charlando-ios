//
//  AuthenticationReposetory.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 15/11/2023.
//

import Foundation

protocol AuthenticationRepository {
    func login(accountLogin: AccountLogin) async throws -> Token
    func registeringEmail(accountRegister: AccountRegister) async throws -> RegisterResponse
    func verifyAccount(accountVerify: AccountVerify) async throws -> Any
    func resendVerifyCode(account: Account) async throws -> Any
    func getDevices() async throws -> [Device]
    func logout(deviceID: String) async throws
    func logoutAll() async throws
    func changePassword(account: AccountChangePassword) async throws
    func requestForgotPassword(account: Account) async throws
    func forgotPassword(accountForgotPassword: AccountForgotPassword) async throws
    func updateFirebaseToken(firebaseDeviceToken: FirebaseDeviceToken) async throws
}
