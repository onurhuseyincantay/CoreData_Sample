// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Event.swift instead.

import Foundation
import CoreData

public enum EventAttributes: String {
    case name = "name"
}

public enum EventRelationships: String {
    case dataAttachment = "dataAttachment"
    case persons = "persons"
}

open class _Event: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Event"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    @nonobjc
    open class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest(entityName: self.entityName())
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Event.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var name: String?

    // MARK: - Relationships

    @NSManaged open
    var dataAttachment: DataAttachment?

    @NSManaged open
    var persons: NSSet

    open func personsSet() -> NSMutableSet {
        return self.persons.mutableCopy() as! NSMutableSet
    }

}

extension _Event {

    open func addPersons(_ objects: NSSet) {
        let mutable = self.persons.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.persons = mutable.copy() as! NSSet
    }

    open func removePersons(_ objects: NSSet) {
        let mutable = self.persons.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.persons = mutable.copy() as! NSSet
    }

    open func addPersonsObject(_ value: Person) {
        let mutable = self.persons.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.persons = mutable.copy() as! NSSet
    }

    open func removePersonsObject(_ value: Person) {
        let mutable = self.persons.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.persons = mutable.copy() as! NSSet
    }

}

