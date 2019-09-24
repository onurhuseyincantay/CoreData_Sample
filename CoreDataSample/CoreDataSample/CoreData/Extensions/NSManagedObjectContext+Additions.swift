//
//  NSManagedObjectContext+Additions.swift
//  CoreDataSample
//
//  Created by Beta Catalina on 9/18/19.
//  Copyright © 2019 Andrei Popilian. All rights reserved.
//

import CoreData

enum FetchResultType {
  case success
  case failed(Error)
}

extension NSManagedObjectContext {
  
  func safeFetch(_ request: NSFetchRequest<NSFetchRequestResult>, completionHandler:([Any]?, Error?) -> Void) {
    do {
      let result = try fetch(request)
      completionHandler(result, nil)
    } catch let error {
      print("NSManagedObjectContext fetch failed with error:\(error)")
      completionHandler(nil, error)
    }
  }
}
