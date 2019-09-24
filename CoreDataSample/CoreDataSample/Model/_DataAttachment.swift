// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to DataAttachment.swift instead.

import Foundation
import CoreData

public enum DataAttachmentAttributes: String {
    case createdDate = "createdDate"
    case data = "data"
    case type = "type"
}

public enum DataAttachmentRelationships: String {
    case event = "event"
}

open class _DataAttachment: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "DataAttachment"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<DataAttachment> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _DataAttachment.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var createdDate: Date?

    @NSManaged open
    var data: String?

    @NSManaged open
    var type: DataAttachmentType // Optional scalars not supported

    // MARK: - Relationships

    @NSManaged open
    var event: Event?

}

