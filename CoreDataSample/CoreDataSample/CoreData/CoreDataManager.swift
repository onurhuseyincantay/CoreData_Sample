//
//  CoreDataStack.swift
//  CoreDataSample
//
//  Created by Beta Catalina on 9/16/19.
//  Copyright © 2019 Andrei Popilian. All rights reserved.
//

import CoreData

final class CoreDataManager {
  
  static let shared: CoreDataManager = CoreDataManager(modelName: "CoreDataSample", storeType: NSSQLiteStoreType, migrator: CoreDataMigrator())
  
  private let modelName: String
  private let migrator: CoreDataMigratorProtocol
  private let storeType: String
  private var persistentContainer: PersistentContainer!

  init(modelName: String, storeType: String, migrator: CoreDataMigratorProtocol) {
    self.modelName = modelName
    self.storeType = storeType
    self.migrator = migrator
  }

  func setup(completion: @escaping () -> Void) {
    loadPersistentStore {
      completion()
    }
  }
  
  /// Context used only on the main queue for UI data fetches purpose
  var mainContext: NSManagedObjectContext { return self.persistentContainer.viewContext }
  
  /// Returns a new background context, which has the mainContext as parent, used for non UI data manipulation purpose
  func newBackgroundContext() -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    context.parent = mainContext
    return context
  }
  
  /// Performs an asynchronous task on the mainContext
  /// - Parameter block: The block that will be used asynchronous on the Main Queue
  func performOnMainAsync(_ block: @escaping (NSManagedObjectContext) -> Void) {
    performAsync(block, on: mainContext)
  }
  
  /// Performs a synchronous task on the mainContext
  /// - Parameter block: The block that will be used synchronous on the Main Queue
  func performOnMainSync(_ block: (NSManagedObjectContext) -> Void) {
    performSync(block, on: mainContext)
  }
  
  /// Performs an asynchronous task on the Background Queue
  /// - Parameter block: The block that will be used asynchronous on a random Background Queue
  func performOnBackgroundAsync(_ block: @escaping (NSManagedObjectContext) -> Void) {
    performAsync(block, on: newBackgroundContext())
  }
  
  /// Performs a synchronous task on the Background Queue
  /// - Parameter block: The block that will be used synchronous on a random Background Queue
  func performOnBackgroundSync(_ block: (NSManagedObjectContext) -> Void) {
    performSync(block, on: newBackgroundContext())
  }
  
  /// Saves the mainContext, backgroundContext, or both
  /// - Parameter backgroundContext: the backgroundContext which will be saved, also the mainContext will be saved after, if not provided only the mainContext is saved
  func saveContext(_ context: NSManagedObjectContext) {
    persistentContainer.saveContext(context)
    
    guard context != mainContext else {
      return
    }
    
    mainContext.performAndWait {
      persistentContainer.saveContext(mainContext)
    }
  }
  
  //MARK: - Private Zone
  private func performAsync(_ block: @escaping (NSManagedObjectContext) -> Void, on context: NSManagedObjectContext) {
    context.perform {
      block(context)
    }
  }
  
  private func performSync(_ block: (NSManagedObjectContext) -> Void, on context: NSManagedObjectContext) {
    context.performAndWait {
      block(context)
    }
  }
  
  private func loadPersistentStore(completion: @escaping () -> Void) {
    persistentContainer = createPersistentContainer(modelName: modelName, storeType: storeType)
    migrateStoreIfNeeded {
      self.persistentContainer.loadPersistentStores { description, error in
        guard error == nil else {
          fatalError("was unable to load store \(error!)")
        }
        completion()
      }
    }
  }

  private func createPersistentContainer(modelName: String, storeType: String) -> PersistentContainer {
    let persistentContainer = PersistentContainer(name: modelName)
    let description = persistentContainer.persistentStoreDescriptions.first
    description?.shouldInferMappingModelAutomatically = false //inferred mapping will be handled else where
    description?.shouldMigrateStoreAutomatically = false
    description?.type = storeType

    return persistentContainer
  }

  private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
    guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
      fatalError("persistentContainer was not set up properly")
    }

    guard migrator.requiresMigration(at: storeURL, toVersion: CoreDataMigrationVersion.current) else {
      completion()
      return
    }

    DispatchQueue.global(qos: .userInitiated).async {
      self.migrator.migrateStore(at: storeURL, toVersion: CoreDataMigrationVersion.current)

      DispatchQueue.main.async {
        completion()
        return
      }
    }
  }
}

//MARK: - For Testing
internal extension CoreDataManager {
  
  func getPersistentStores() -> [NSPersistentStore] {
    return persistentContainer.persistentStoreCoordinator.persistentStores
  }
}
