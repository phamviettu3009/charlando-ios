//
//  SyncManager.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 27/02/2024.
//

import Foundation
import CoreData

class SyncManager {
    static let shared = SyncManager()
    private let queue = DispatchQueue(label: "queue_io_chat")
    private let coreDataProvider = CoreDataProvider.shared
    private let messageRepository: MessageRepository = MessageRepositoryImpl.shared
    
    func syncController(
        context: NSManagedObjectContext,
        eventEntity: EventEntity
    ) async throws {
        switch(eventEntity.syncTarget) {
        case EventEntity.SYNC_TARGET_NEW_MESSAGE:
            try await syncMessage(context: context, eventEntity: eventEntity)
        case EventEntity.SYNC_TARGET_MESSAGE_REACTION:
            try await syncMessageReaction(context: context, eventEntity: eventEntity)
        case EventEntity.SYNC_TARGET_UPDATE_MESSAGE:
            try await syncUpdateMessage(context: context, eventEntity: eventEntity)
        case EventEntity.SYNC_TARGET_DELETE_MESSAGE_FOR_ALL, EventEntity.SYNC_TARGET_DELETE_MESSAGE_FOR_OWNER:
            try await syncDeleteMessage(context: context, eventEntity: eventEntity)
        case EventEntity.SYNC_TARGET_ATTACHMENT:
            try await syncAttachment(context: context, eventEntity: eventEntity)
        default:
            break
        }
    }
    
    private func syncMessage(context: NSManagedObjectContext, eventEntity: EventEntity) async throws {
        let message = try await self.messageRepository.syncMessage(eventEntity: eventEntity)
        guard let syncID = message.syncID else { return }
        // tìm tin nhắn chưa đồng bộ bằng syncID
        let messageRequest = MessageEntity.findMessageBySyncID(syncID: syncID)
        guard let messageEntity = try? context.fetch(messageRequest).first else { return }
        let _ = message.asMessageEntity(context: context)
        try? context.performAndWait {
            // tìm và xoá sự kiện gửi tin nhắn
            self.findAndDeleteEvent(context, eventEntity.id)
            // xoá tin nhắn chưa đồng bộ
            try? self.coreDataProvider.delete(messageEntity, in: context)
            // thay thế bằng 1 tin nhắn đã đồng bộ
            try self.coreDataProvider.persist(in: context)
        }
    }
    
    private func syncMessageReaction(context: NSManagedObjectContext, eventEntity: EventEntity) async throws {
        let message = try await self.messageRepository.syncMessageReaction(eventEntity: eventEntity)
        let _ = message.asMessageEntity(context: context)
        context.performAndWait {
            try? self.coreDataProvider.persist(in: context)
            // tìm và xoá sự kiện gửi phản ứng
            self.findAndDeleteEvent(context, eventEntity.id)
        }
    }
    
    private func syncUpdateMessage(context: NSManagedObjectContext, eventEntity: EventEntity) async throws {
        let message = try await self.messageRepository.syncUpdateMessage(eventEntity: eventEntity)
        let _ = message.asMessageEntity(context: context)
        context.performAndWait {
            try? self.coreDataProvider.persist(in: context)
            // tìm và xoá sự kiện cập nhật tin nhắn
            self.findAndDeleteEvent(context, eventEntity.id)
        }
    }
    
    private func syncDeleteMessage(context: NSManagedObjectContext, eventEntity: EventEntity) async throws {
        let message = try await self.messageRepository.syncDeleteMessage(eventEntity: eventEntity)
        let _ = message.asMessageEntity(context: context)
        context.performAndWait {
            try? self.coreDataProvider.persist(in: context)
            // tìm và xoá sự kiện xoá tin nhắn
            self.findAndDeleteEvent(context, eventEntity.id)
        }
    }
    
    private func syncAttachment(context: NSManagedObjectContext, eventEntity: EventEntity) async throws {
        let resources = try await self.messageRepository.syncUploadFiles(eventEntity: eventEntity)
        guard let childEvent = eventEntity.getChildEvent() else { return }
        guard var postMessage = childEvent.asPostMessage() else { return }
        postMessage.attachmentIDs = resources.map { it in it.id.uuidString.lowercased() }
        let childEventEntity = EventEntity(
            context: context,
            requestID: childEvent.requestID,
            syncTarget: childEvent.syncTarget,
            payload: postMessage
        )
        try await self.syncMessage(context: context, eventEntity: childEventEntity)
        self.findAndDeleteEvent(context, eventEntity.id)
    }
    
    private func findAndDeleteEvent(_ context: NSManagedObjectContext, _ eventID: UUID) {
        let request = EventEntity.findByEventID(eventID: eventID)
        if let eventEntity = try? context.fetch(request).first {
            try? self.coreDataProvider.delete(eventEntity, in: context)
        }
    }
    
    func findAllEventAndSync(_ context: NSManagedObjectContext) async throws {
        let request = EventEntity.findAll()
        if let eventEntitys: [EventEntity] = try? context.fetch(request), !eventEntitys.isEmpty {
            print("sync count: \(eventEntitys.count)")
            try await syncEvent(context: context, eventEntitys: eventEntitys, index: 0)
        }
    }
    
    private func syncEvent(context: NSManagedObjectContext, eventEntitys: [EventEntity], index: Int = 0) async throws {
        if (eventEntitys.count <= index) { return }
        try await syncController(context: context, eventEntity: eventEntitys[index])
        try await syncEvent(context: context, eventEntitys: eventEntitys, index: index + 1)
    }
}
