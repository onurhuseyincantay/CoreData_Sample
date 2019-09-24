//
//  NSManagedObjectModel+Additions.swift
//  CoreDataSample
//
//  Created by Beta Catalina on 9/20/19.
//  Copyright © 2019 Andrei Popilian. All rights reserved.
//

import CoreData

extension NSManagedObjectModel {
  
  static func managedObjectModel(forResource resource: String) -> NSManagedObjectModel {
    let mainBundle = Bundle.main
    let subdirectory = "CoreDataSample.momd"
    
    var omoURL: URL?
    if #available(iOS 11, *) {
      omoURL = mainBundle.url(forResource: resource, withExtension: "omo", subdirectory: subdirectory) // optimized model file
    }
    let momURL = mainBundle.url(forResource: resource, withExtension: "mom", subdirectory: subdirectory)
    
    guard let url = omoURL ?? momURL else {
      fatalError("unable to find model in bundle")
    }
    
    guard let model = NSManagedObjectModel(contentsOf: url) else {
      fatalError("unable to load model in bundle")
    }
    
    return model
  }
  
  static func compatibleModelForStoreMetadata(_ metadata: [String : Any]) -> NSManagedObjectModel? {
    let mainBundle = Bundle.main
    return NSManagedObjectModel.mergedModel(from: [mainBundle], forStoreMetadata: metadata)
  }
}
