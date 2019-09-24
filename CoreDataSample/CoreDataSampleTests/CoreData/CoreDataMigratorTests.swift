//
//  CoreDataMigratorTests.swift
//  CoreDataSampleTests
//
//  Created by Beta Catalina on 9/23/19.
//  Copyright © 2019 Andrei Popilian. All rights reserved.
//

import CoreData
import XCTest

@testable import CoreDataSample

class CoreDataMigratorTests: XCTestCase {

  var migrator: CoreDataMigrator!

  override class func setUp() {
    super.setUp()

    FileManager.clearTempDirectoryContents()
  }

  override func setUp() {
    super.setUp()

    migrator = CoreDataMigrator()
  }

  override func tearDown() {
    migrator = nil

    super.tearDown()
  }

  func tearDownCoreDataStack(context: NSManagedObjectContext) {
    context.destroyStore()
  }

  func test_individualStepMigration_1to2() {
    let sourceURL = FileManager.moveFileFromBundleToTempDirectory(filename: "CoreDataSample_v1.sqlite")
    let toVersion = CoreDataMigrationVersion.version2

    migrator.migrateStore(at: sourceURL, toVersion: toVersion)

    XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path))

    let model = NSManagedObjectModel.managedObjectModel(forResource: toVersion.rawValue)
    let context = NSManagedObjectContext(model: model, storeURL: sourceURL)
    let request = NSFetchRequest<NSManagedObject>(entityName: "DataAttachment")
    let sort = NSSortDescriptor(key: "data", ascending: true)
    request.sortDescriptors = [sort]

    let migratedEvents = try? context.fetch(request)

    XCTAssertEqual(migratedEvents!.count, 5)

    let firstMigratedEvent = migratedEvents?.first

    let migratedData = firstMigratedEvent!.value(forKey: "data") as? String
    XCTAssertEqual(migratedData, "RXZlbnQgMTg3")


    let migratedEvent = firstMigratedEvent?.value(forKey: "Event") as? NSManagedObject
    let migratedEventName = migratedEvent?.value(forKey: "name") as? String

    XCTAssertEqual(migratedEventName, "Event 187")
    tearDownCoreDataStack(context: context)
  }

}
