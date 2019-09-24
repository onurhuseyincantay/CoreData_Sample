//
//  PersistentContainer.swift
//  CoreDataSample
//
//  Created by Beta Catalina on 9/16/19.
//  Copyright © 2019 Andrei Popilian. All rights reserved.
//

import CoreData

enum SaveContextSuccess {
  case success
  case noChanges
}

enum SaveContextFailure: Error {
  case error(Error)
}

final class PersistentContainer: NSPersistentContainer {
  
  override class func defaultDirectoryURL() -> URL {
    return super.defaultDirectoryURL().appendingPathComponent("CoreDataSampleModel")
  }
  
  func addSupportForQueryGeneration() -> Self {
    try? self.viewContext.setQueryGenerationFrom(.current)
    return self
  }
  
  /// Saves the context provided and returns .success if there are no changes or if succeded otherwise returns .failure with the error provided
  /// - Parameter context: represents the context to be saved
  @discardableResult
  func saveContext(_ context: NSManagedObjectContext) -> Result<SaveContextSuccess, SaveContextFailure> {
    guard context.hasChanges else {
      return .success(.noChanges)
    }
    
    do {
      try context.save()
    } catch let error {
      print("error: \(error.localizedDescription)")
      return .failure(.error(error))
    }
    
    return .success(.success)
  }
}
