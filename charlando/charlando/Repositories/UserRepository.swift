//
//  UserRepository.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 15/11/2023.
//

import Foundation

protocol UserRepository {
    func getUser() async throws -> User
    func getListUser(page: Int, keyword: String) async throws -> [User]
    func sendRequestAddFriend(friendID: String) async throws -> FriendRelationshipResponse
    func confirmAddFriend(friendID: String) async throws -> FriendRelationshipResponse
    func cancelRequestAddFriend(friendID: String) async throws -> FriendRelationshipResponse
    func unfriend(friendID: String) async throws -> FriendRelationshipResponse
    func rejectFriendRequest(friendID: String) async throws -> FriendRelationshipResponse
    func getListFriend(page: Int, keyword: String) async throws -> [User]
    func getListMemberInChannel(channelID: UUID, page: Int) async throws -> [Member]
    func getUserInfo(userID: UUID) async throws -> UserInfo
    func updateUser(userUpdateRequest: UserUpdateRequest) async throws -> User
    func getListRequestAddFriend(page: Int, keyword: String) async throws -> [User]
    func getNumberRequestAddFriend() async throws
    func updateSetting(settingUpdateRequest: Setting) async throws -> Setting
}
