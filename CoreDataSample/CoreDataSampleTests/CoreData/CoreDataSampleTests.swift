//
//  CoreDataSampleTests.swift
//  CoreDataSampleTests
//
//  Created by Beta Catalina on 9/23/19.
//  Copyright © 2019 Andrei Popilian. All rights reserved.
//


import XCTest
import CoreData

@testable import CoreDataSample

class CoreDataSampleTests: XCTestCase {

  var migrator: MockCoreDataMigrator!
  var manager: CoreDataManager!

  // MARK: - Lifecycle

  override func setUp() {
    super.setUp()

    migrator = MockCoreDataMigrator()
    manager = CoreDataManager(modelName: "CoreDataSample", storeType: NSInMemoryStoreType, migrator: migrator)
  }

  override func tearDown() {
    migrator = nil
    manager = nil

    super.tearDown()
  }

  func test_setup_loadsStore() {
    let promise = expectation(description: "calls back")
    manager.setup {
      XCTAssertFalse(self.manager.getPersistentStores().isEmpty)

      promise.fulfill()
    }

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Timed out: \(String(describing: error))")
      }
    }
  }

  func test_setup_checksIfMigrationRequired() {
    let promise = expectation(description: "calls back")
    manager.setup {
      XCTAssertTrue(self.migrator.requiresMigrationWasCalled)
      XCTAssertFalse(self.migrator.migrateStoreWasCalled)

      promise.fulfill()
    }

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Timed out: \(String(describing: error))")
      }
    }
  }

  func test_setup_migrate() {
    migrator.requiresMigrationToBeReturned = true

    let promise = expectation(description: "calls back")
    manager.setup {
      XCTAssertTrue(self.migrator.migrateStoreWasCalled)

      promise.fulfill()
    }

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Timed out: \(String(describing: error))")
      }
    }
  }
}
