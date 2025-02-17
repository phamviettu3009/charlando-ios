//
//  ChannelRepositoryImpl.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 28/11/2023.
//

import Foundation

class ChannelRepositoryImpl: ChannelRepository {
    static let shared = ChannelRepositoryImpl()
    
    let apiManager = APIManager.shared
    
    func getListChannel(page: Int, keyword: String) async throws -> [Channel] {
        let params = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sizePerPage", value: String(SIZE_PER_PAGE)),
            URLQueryItem(name: "keyword", value: keyword)
        ]
        
        let data = try await apiManager.performRequest(endpoint: GET_LIST_CHANNEL_ENDPOINT, method: "GET", params: params)
        let channels = try JSONDecoder().decode(ListResponse<Channel>.self, from: data)
        return channels.data
    }
    
    func createChannelGroup(channelGroupRequest: ChannelGroupRequest) async throws -> Any {
        let body = channelGroupRequest.asJson()
        let data = try await apiManager.performRequest(endpoint: CREATE_GROUP_CHANNEL_ENDPOINT, method: "POST", body: body)
        return data
    }
    
    func getChannel(channelID: UUID) async throws -> Channel {
        let channelID = channelID.uuidString.lowercased()
        let endpoint = GET_CHANNEL_ENDPOINT.replacingOccurrences(of: "{id}", with: channelID)
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "GET")
        let channel = try JSONDecoder().decode(Channel.self, from: data)
        return channel
    }
    
    func updateChannel(channelID: UUID, groupChannelUpdateRequest: GroupChannelUpdateRequest) async throws -> Channel {
        let channelID = channelID.uuidString.lowercased()
        let endpoint = UPDATE_GROUP_CHANNEL_ENDPOINT.replacingOccurrences(of: "{id}", with: channelID)
        let body = groupChannelUpdateRequest.asJson()
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "PUT", body: body)
        let channel = try JSONDecoder().decode(Channel.self, from: data)
        return channel
    }
    
    func getRole(channelID: UUID) async throws -> MyRole {
        let channelID = channelID.uuidString.lowercased()
        let endpoint = GET_ROLE_ENDPOINT.replacingOccurrences(of: "{id}", with: channelID)
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "GET")
        let myRole = try JSONDecoder().decode(MyRole.self, from: data)
        return myRole
    }
    
    func removeMembers(channelID: UUID, members: GroupChannelMembers) async throws -> Channel {
        let channelID = channelID.uuidString.lowercased()
        let endpoint = REMOVE_MEMBER_ENDPOINT.replacingOccurrences(of: "{id}", with: channelID)
        let body = members.asJson()
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST", body: body)
        let channel = try JSONDecoder().decode(Channel.self, from: data)
        return channel
    }
    
    func addMembers(channelID: UUID, members: GroupChannelMembers) async throws -> Channel {
        let channelID = channelID.uuidString.lowercased()
        let endpoint = ADD_MEMBER_ENDPOINT.replacingOccurrences(of: "{id}", with: channelID)
        let body = members.asJson()
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST", body: body)
        let channel = try JSONDecoder().decode(Channel.self, from: data)
        return channel
    }
    
    func getFriendOutsideChannel(page: Int, keyword: String, channelID: UUID) async throws -> [User] {
        let channelID = channelID.uuidString.lowercased()
        let endpoint = GET_FRIEND_OUTSIDE_CHANNEL_ENDPOINT.replacingOccurrences(of: "{id}", with: channelID)
        
        let params = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sizePerPage", value: String(SIZE_PER_PAGE)),
            URLQueryItem(name: "keyword", value: keyword)
        ]
        
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "GET", params: params)
        let users = try JSONDecoder().decode(ListResponse<User>.self, from: data)
        return users.data
    }
    
    func leaveGroup(channelID: UUID) async throws -> Any {
        let channelID = channelID.uuidString.lowercased()
        let endpoint = LEAVE_GROUP_ENDPOINT.replacingOccurrences(of: "{id}", with: channelID)
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST")
        return data
    }
    
    func addAdminRole(channelID: UUID, members: GroupChannelMembers) async throws -> Any {
        let channelID = channelID.uuidString.lowercased()
        let endpoint = ADD_ADMIN_ROLE_ENDPOINT.replacingOccurrences(of: "{id}", with: channelID)
        let body = members.asJson()
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST", body: body)
        return data
    }
    
    func revokeAdminRole(channelID: UUID, members: GroupChannelMembers) async throws -> Any {
        let channelID = channelID.uuidString.lowercased()
        let endpoint = REVOKE_ADMIN_ROLE_ENDPOINT.replacingOccurrences(of: "{id}", with: channelID)
        let body = members.asJson()
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST", body: body)
        return data
    }
    
    func setOwnerRole(channelID: UUID, member: GroupChannelMember) async throws -> Any {
        let channelID = channelID.uuidString.lowercased()
        let endpoint = SET_OWNER_ROLE_ENDPOINT.replacingOccurrences(of: "{id}", with: channelID)
        let body = member.asJson()
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST", body: body)
        return data
    }
}
