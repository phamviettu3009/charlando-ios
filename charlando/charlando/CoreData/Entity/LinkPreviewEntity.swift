//
//  LinkPreviewEntity.swift
//  2lab
//
//  Created by Phạm Việt Tú on 20/05/2024.
//

import Foundation
import CoreData

@objc(LinkPreview)
final class LinkPreviewEntity: NSManagedObject, Identifiable {
    @NSManaged public var url: String
    @NSManaged public var title: String
    
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "LinkPreview", in: context)!
        self.init(entity: entity, insertInto: context)
    }
}

extension LinkPreviewEntity {
    private static var linkPreviewFetchRequest: NSFetchRequest<LinkPreviewEntity> {
        NSFetchRequest(entityName: "LinkPreview")
    }
    
    static func findByURL(url: String) -> NSFetchRequest<LinkPreviewEntity> {
        let request: NSFetchRequest<LinkPreviewEntity> = linkPreviewFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \LinkPreviewEntity.title,
                ascending: false
            )
        ]
        
        let urlPredicate = NSPredicate(format: "url == %@", url as CVarArg)
        request.predicate = urlPredicate
        
        return request
    }
}
