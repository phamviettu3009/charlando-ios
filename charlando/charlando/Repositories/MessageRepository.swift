//
//  MessageRepository.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 01/12/2023.
//

import Foundation

protocol MessageRepository {
    func getListMessage(channelID: UUID, page: Int, keyword: String) async throws -> [Message]
    func syncMessage(eventEntity: EventEntity) async throws -> Message
    func syncMessageReaction(eventEntity: EventEntity) async throws -> Message
    func syncUpdateMessage(eventEntity: EventEntity) async throws -> Message
    func syncDeleteMessage(eventEntity: EventEntity) async throws -> Message
    func syncUploadFiles(eventEntity: EventEntity) async throws -> [ResourceResponse]
    func readMessage(messageID: UUID) async throws -> [UserAvatar]
}
