//
//  MockCoreDataMigrator.swift
//  CoreDataSampleTests
//
//  Created by Beta Catalina on 9/23/19.
//  Copyright © 2019 Andrei Popilian. All rights reserved.
//

import CoreData

@testable import CoreDataSample

class MockCoreDataMigrator: CoreDataMigratorProtocol {

  var requiresMigrationWasCalled = false
  var migrateStoreWasCalled = false

  var requiresMigrationToBeReturned = false

  func requiresMigration(at: URL, toVersion: CoreDataMigrationVersion) -> Bool {
    requiresMigrationWasCalled = true

    return requiresMigrationToBeReturned
  }

  func migrateStore(at storeURL: URL, toVersion version: CoreDataMigrationVersion) {
    migrateStoreWasCalled = true
  }
}
