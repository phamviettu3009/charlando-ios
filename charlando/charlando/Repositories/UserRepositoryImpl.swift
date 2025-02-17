//
//  UserRepositoryImpl.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 15/11/2023.
//

import Foundation

class UserRepositoryImpl: UserRepository {
    static let shared = UserRepositoryImpl()
    
    let apiManager = APIManager.shared
    
    func getUser() async throws -> User {
        let data = try await apiManager.performRequest(endpoint: GET_OWNER_USER_EDNPOINT, method: "GET")
        let user = try JSONDecoder().decode(User.self, from: data)
        return user
    }
    
    func getListUser(page: Int, keyword: String) async throws -> [User] {
        let params = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sizePerPage", value: String(SIZE_PER_PAGE)),
            URLQueryItem(name: "keyword", value: keyword)
        ]
        
        let data = try await apiManager.performRequest(endpoint: GET_LIST_USER_ENDPOINT, method: "GET", params: params)
        let users = try JSONDecoder().decode(ListResponse<User>.self, from: data)
        return users.data
    }
    
    func sendRequestAddFriend(friendID: String) async throws -> FriendRelationshipResponse {
        let endpoint = SEND_REQUEST_ADD_FRIEND_ENDPOINT.replacingOccurrences(of: "{id}", with: friendID)
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST")
        let friendRelationship = try JSONDecoder().decode(FriendRelationshipResponse.self, from: data)
        return friendRelationship
    }
        
    func confirmAddFriend(friendID: String) async throws -> FriendRelationshipResponse {
        let endpoint = CONFIRMATION_ADD_FRIEND_ENDPOINT.replacingOccurrences(of: "{id}", with: friendID)
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST")
        let friendRelationship = try JSONDecoder().decode(FriendRelationshipResponse.self, from: data)
        return friendRelationship
    }
    
    func cancelRequestAddFriend(friendID: String) async throws -> FriendRelationshipResponse {
        let endpoint = CANCEL_REQUEST_ADD_FRIEND_ENDPOINT.replacingOccurrences(of: "{id}", with: friendID)
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST")
        let friendRelationship = try JSONDecoder().decode(FriendRelationshipResponse.self, from: data)
        return friendRelationship
    }
    
    func unfriend(friendID: String) async throws -> FriendRelationshipResponse {
        let endpoint = UNFRIEND_ENDPOINT.replacingOccurrences(of: "{id}", with: friendID)
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST")
        let friendRelationship = try JSONDecoder().decode(FriendRelationshipResponse.self, from: data)
        return friendRelationship
    }
    
    func rejectFriendRequest(friendID: String) async throws -> FriendRelationshipResponse {
        let endpoint = REJECT_ADD_FRIEND_ENDPOINT.replacingOccurrences(of: "{id}", with: friendID)
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST")
        let friendRelationship = try JSONDecoder().decode(FriendRelationshipResponse.self, from: data)
        return friendRelationship
    }
    
    func getListFriend(page: Int, keyword: String) async throws -> [User] {
        let params = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sizePerPage", value: String(SIZE_PER_PAGE)),
            URLQueryItem(name: "keyword", value: keyword)
        ]
        
        let data = try await apiManager.performRequest(endpoint: GET_LIST_FRIEND_ENDPOINT, method: "GET", params: params)
        let users = try JSONDecoder().decode(ListResponse<User>.self, from: data)
        return users.data
    }
    
    func getListMemberInChannel(channelID: UUID, page: Int) async throws -> [Member] {
        let params = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sizePerPage", value: String(99))
        ]
        
        let channelID = channelID.uuidString.lowercased()
        let endpoint = GET_LIST_MEMBER_IN_CHANNEL_ENDPOINT.replacingOccurrences(of: "{id}", with: channelID)
        
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "GET", params: params)
        let members = try JSONDecoder().decode(ListResponse<Member>.self, from: data)
        return members.data
    }
    
    func getUserInfo(userID: UUID) async throws -> UserInfo {
        let endpoint = GET_USER_ENDPOINT.replacingOccurrences(of: "{id}", with: userID.uuidString)
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "GET")
        let userInfo = try JSONDecoder().decode(UserInfo.self, from: data)
        return userInfo
    }
        
    func updateUser(userUpdateRequest: UserUpdateRequest) async throws -> User {
        let endpoint = UPDATE_OWNER_USER_ENDPOINT
        let body = userUpdateRequest.asJson()
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "PUT", body: body)
        let user = try JSONDecoder().decode(User.self, from: data)
        return user
    }
    
    func getListRequestAddFriend(page: Int, keyword: String) async throws -> [User] {
        let params = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sizePerPage", value: String(SIZE_PER_PAGE)),
            URLQueryItem(name: "keyword", value: keyword)
        ]
        
        let data = try await apiManager.performRequest(endpoint: GET_LIST_REQUEST_ADD_FRIEND_ENDPOINT, method: "GET", params: params)
        let users = try JSONDecoder().decode(ListResponse<User>.self, from: data)
        return users.data
    }
    
    func getNumberRequestAddFriend() async throws {
        let _ = try await apiManager.performRequest(endpoint: GET_NUMBER_REQUEST_ADD_FRIEND_ENDPOINT, method: "GET")
    }
    
    func updateSetting(settingUpdateRequest: Setting) async throws -> Setting {
        let endpoint = UPDATE_OWNER_SETTING_ENDPOINT
        let body = settingUpdateRequest.asJson()
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "PUT", body: body)
        let setting = try JSONDecoder().decode(Setting.self, from: data)
        return setting
    }
}
