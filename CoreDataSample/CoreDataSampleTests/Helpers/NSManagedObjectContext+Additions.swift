//
//  NSManagedObjectContext+Additions.swift
//  CoreDataSampleTests
//
//  Created by Beta Catalina on 9/23/19.
//  Copyright © 2019 Andrei Popilian. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {

  convenience init(model: NSManagedObjectModel, storeURL: URL) {
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    try! persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)

    self.init(concurrencyType: .mainQueueConcurrencyType)

    self.persistentStoreCoordinator = persistentStoreCoordinator
  }

  func destroyStore() {
    persistentStoreCoordinator?.persistentStores.forEach {
      try? persistentStoreCoordinator?.remove($0)
      try? persistentStoreCoordinator?.destroyPersistentStore(at: $0.url!, ofType: $0.type, options: nil)
    }
  }
}
