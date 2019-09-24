import CoreData

@objc(Person)
open class Person: _Person {

  @nonobjc
  class func fetchCustomRequest() -> NSFetchRequest<Person> {
    return NSFetchRequest(entityName: self.entityName())
  }
}
