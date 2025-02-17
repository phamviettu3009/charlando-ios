//
//  MessageRepositoryImpl.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 01/12/2023.
//

import Foundation

class MessageRepositoryImpl: MessageRepository {
    static let shared = MessageRepositoryImpl()
    
    let apiManager = APIManager.shared
    
    func getListMessage(channelID: UUID, page: Int, keyword: String) async throws -> [Message] {
        let params = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sizePerPage", value: String(SIZE_PER_PAGE_MESSAGE)),
            URLQueryItem(name: "keyword", value: keyword)
        ]
        
        let channelID = channelID.uuidString.lowercased()
        let endpoint = GET_LIST_MESSAGE_ENDPOINT.replacingOccurrences(of: "{id}", with: channelID)
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "GET", params: params)
        let messages = try JSONDecoder().decode(ListResponse<Message>.self, from: data)
        return messages.data
    }
    
    func syncMessage(eventEntity: EventEntity) async throws -> Message {
        let channelID = eventEntity.requestID.uuidString.lowercased()
        let endpoint = SYNC_NEW_MESSAGE_ENDPOINT.replacingOccurrences(of: "{id}", with: channelID)
        let body = eventEntity.getPayload()
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST", body: body)
        let message = try JSONDecoder().decode(Message.self, from: data)
        return message
    }
    
    func syncMessageReaction(eventEntity: EventEntity) async throws -> Message {
        let messageID = eventEntity.requestID.uuidString.lowercased()
        let endpoint = SYNC_MESSAGE_REACTION_ENDPOINT.replacingOccurrences(of: "{id}", with: messageID)
        let body = eventEntity.getPayload()
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST", body: body)
        let message = try JSONDecoder().decode(Message.self, from: data)
        return message
    }
    
    func syncUpdateMessage(eventEntity: EventEntity) async throws -> Message {
        let messageID = eventEntity.requestID.uuidString.lowercased()
        let endpoint = SYNC_UPDATE_MESSAGE_ENDPOINT.replacingOccurrences(of: "{id}", with: messageID)
        let body = eventEntity.getPayload()
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "PUT", body: body)
        let message = try JSONDecoder().decode(Message.self, from: data)
        return message
    }
    
    func syncDeleteMessage(eventEntity: EventEntity) async throws -> Message {
        let messageID = eventEntity.requestID.uuidString.lowercased()
        let deleteOption = eventEntity.syncTarget == EventEntity.SYNC_TARGET_DELETE_MESSAGE_FOR_ALL ? "/for-all" : "/for-owner"
        let endpoint = SYNC_DELETE_MESSAGE_ENDPOINT.replacingOccurrences(of: "{id}", with: messageID) + deleteOption
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "DELETE")
        let message = try JSONDecoder().decode(Message.self, from: data)
        return message
    }
    
    func syncUploadFiles(eventEntity: EventEntity) async throws -> [ResourceResponse] {
        guard let multipart: MultipartRequest = eventEntity.getPayload() else { fatalError("Not found payload!") }
        let endpoint = UPLOAD_PRIVATE_MULTI
        let data = try await apiManager.performRequest(endpoint: endpoint, multipart: multipart)
        let resource = try JSONDecoder().decode([ResourceResponse].self, from: data)
        return resource
    }
    
    func readMessage(messageID: UUID) async throws -> [UserAvatar] {
        let messageID = messageID.uuidString.lowercased()
        let endpoint = READ_MESSAGE_ENDPOINT.replacingOccurrences(of: "{id}", with: messageID)
        let data = try await apiManager.performRequest(endpoint: endpoint, method: "POST")
        let message = try JSONDecoder().decode([UserAvatar].self, from: data)
        return message
    }
}
