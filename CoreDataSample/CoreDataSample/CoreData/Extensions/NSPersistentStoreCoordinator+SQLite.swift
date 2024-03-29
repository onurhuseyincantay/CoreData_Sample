//
//  NSPersistentStoreCoordinator+SQLite.swift
//  CoreDataSample
//
//  Created by Beta Catalina on 9/20/19.
//  Copyright © 2019 Andrei Popilian. All rights reserved.
//

import CoreData

extension NSPersistentStoreCoordinator {
  
  static func destroyStore(at storeURL: URL) {
    do {
      let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
      try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
    } catch let error {
      fatalError("failed to destroy persistent store at \(storeURL), error: \(error)")
    }
  }
  
  static func replaceStore(at targetURL: URL, withStoreAt sourceURL: URL) {
    do {
      let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
      try persistentStoreCoordinator.replacePersistentStore(at: targetURL, destinationOptions: nil, withPersistentStoreFrom: sourceURL, sourceOptions: nil, ofType: NSSQLiteStoreType)
    } catch let error {
      fatalError("failed to replace persistent store at \(targetURL) with \(sourceURL), error: \(error)")
    }
  }
  
  static func metadata(at storeURL: URL) -> [String : Any]?  {
    return try? NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
  }
  
  func addPersistentStore(at storeURL: URL, options: [AnyHashable : Any]) -> NSPersistentStore {
    do {
      return try addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
    } catch let error {
      fatalError("failed to add persistent store to coordinator, error: \(error)")
    }
  }
}
