//
//  CoreDataProvider.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 18/02/2024.
//

import Foundation
import CoreData

final class CoreDataProvider {
    static let shared = CoreDataProvider()
    
    private let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var newContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        return context
    }
    
    private init(){
        persistentContainer = NSPersistentContainer(name: "ModelManager")
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load store with error: \(error)")
            }
        }
    }
    
    func exists<T: NSManagedObject>(_ value: T, in context: NSManagedObjectContext) -> T? {
        do {
            return try context.existingObject(with: value.objectID) as? T
        } catch {
            return nil
        }
    }
    
    func delete<T: NSManagedObject>(_ value: T, in context: NSManagedObjectContext) throws {
        if let existing = exists(value, in: context) {
            context.delete(existing)
            Task(priority: .background) {
                try await context.perform {
                    try context.save()
                }
            }
        }
    }
    
    func deleteAll(entityName: String, in context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            Task(priority: .background) {
                try await context.perform {
                    try context.save()
                }
            }
        } catch let error as NSError {
            print("Could not delete all data. \(error), \(error.userInfo)")
        }
    }
    
    func persist(in context: NSManagedObjectContext) throws {
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        if context.hasChanges {
            do {
                try context.save()
            } catch {}
        }
    }
}
