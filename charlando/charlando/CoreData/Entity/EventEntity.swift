//
//  EventEntity.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 27/02/2024.
//

import Foundation
import CoreData

@objc(Event)
class EventEntity: NSManagedObject, Identifiable {
    static let SYNC_TARGET_NEW_MESSAGE = "SYNC_TARGET_NEW_MESSAGE"
    static let SYNC_TARGET_MESSAGE_REACTION = "SYNC_TARGET_MESSAGE_REACTION"
    static let SYNC_TARGET_UPDATE_MESSAGE = "SYNC_TARGET_UPDATE_MESSAGE"
    static let SYNC_TARGET_DELETE_MESSAGE_FOR_ALL = "SYNC_TARGET_DELETE_MESSAGE_FOR_ALL"
    static let SYNC_TARGET_DELETE_MESSAGE_FOR_OWNER = "SYNC_TARGET_DELETE_MESSAGE_FOR_OWNER"
    static let SYNC_TARGET_ATTACHMENT = "SYNC_TARGET_ATTACHMENT"
    
    @NSManaged public var id: UUID
    @NSManaged public var requestID: UUID
    @NSManaged private var payloadData: Data?
    @NSManaged public var syncTarget: String
    @NSManaged public var makerDate: Date
    @NSManaged private var childEventData: Data?
    
    convenience init<T: Encodable>(context: NSManagedObjectContext, requestID: UUID, syncTarget: String, payload: T) {
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.id = UUID()
        self.requestID = requestID
        self.syncTarget = syncTarget
        self.makerDate = Date()
        self.payloadData = try? JSONEncoder().encode(payload)
    }
    
    convenience init(context: NSManagedObjectContext, requestID: UUID, syncTarget: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.id = UUID()
        self.requestID = requestID
        self.syncTarget = syncTarget
        self.makerDate = Date()
    }
    
    func setPayload<T: Encodable>(payload: T) {
        let data = try? JSONEncoder().encode(payload)
        payloadData = data
    }
    
    func getPayload<T: Decodable>() -> T? {
        if (payloadData == nil) {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: payloadData!)
    }
    
    func getPayload() -> Data? {
        return payloadData
    }
    
    func setChildEvent(childEvent: ChildEvent) {
        let data = try? JSONEncoder().encode(childEvent)
        childEventData = data
    }
    
    func getChildEvent() -> ChildEvent? {
        if (childEventData == nil) { return nil }
        return try? JSONDecoder().decode(ChildEvent.self, from: childEventData!)
    }
}

extension EventEntity {
    private static var eventFetchRequest: NSFetchRequest<EventEntity> {
        NSFetchRequest(entityName: "Event")
    }
    
    static func findAll() -> NSFetchRequest<EventEntity> {
        let request: NSFetchRequest<EventEntity> = eventFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \EventEntity.makerDate,
                ascending: true
            )
        ]
        return request
    }
    
    static func findByEventID(eventID: UUID) -> NSFetchRequest<EventEntity> {
        let request: NSFetchRequest<EventEntity> = eventFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \EventEntity.makerDate,
                ascending: false
            )
        ]
        
        let IDPredicate = NSPredicate(format: "id == %@", eventID as CVarArg)
        request.predicate = IDPredicate
        
        return request
    }
    
    static func findByRequestIDAndSyncTarget(requestID: UUID, syncTarget: String) -> NSFetchRequest<EventEntity> {
        let request: NSFetchRequest<EventEntity> = eventFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \EventEntity.makerDate,
                ascending: false
            )
        ]
        
        var predicates: [NSPredicate] = []
        // Tìm kiếm theo trường "requestID"
        let requestIDPredicate = NSPredicate(format: "requestID == %@", requestID as CVarArg)
        request.predicate = requestIDPredicate
        
        // Tìm kiếm theo trường "syncTarget"
        let syncTargetPredicate = NSPredicate(format: "syncTarget == %@", syncTarget)
        predicates.append(syncTargetPredicate)
        
        let finalPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        request.predicate = finalPredicate
        
        return request
    }
}

//extension EventEntity {
//    func initEvent(syncTarget: String, requestID: UUID, payload: ) {
//        self.id = UUID()
//        self.makerDate = Date()
//        self.requestID = requestID
//        self.syncTarget = syncTarget
//        switch syncTarget {
//        case EventEntity.SYNC_TARGET_NEW_MESSAGE
//            eventEntity.setPayload(payload: messageEntity.asPostMessage())
//        default:
//           break
//        }
//    }
//}
