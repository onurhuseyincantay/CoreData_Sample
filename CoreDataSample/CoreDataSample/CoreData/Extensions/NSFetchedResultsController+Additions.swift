//
//  NSFetchedResultsController+Additions.swift
//  CoreDataSample
//
//  Created by Beta Catalina on 9/18/19.
//  Copyright © 2019 Andrei Popilian. All rights reserved.
//

import CoreData

extension NSFetchedResultsController {

  @objc func performSafeFetch(completionHandler: (Error?) -> Void) {
    do {
      try performFetch()
    } catch let error {
      print("NSFetchedResultsController performFetch failed with error:\(error.localizedDescription)")
      completionHandler(error)
    }

    completionHandler(nil)
  }
}
