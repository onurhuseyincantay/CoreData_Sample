//
//  ViewController.swift
//  CoreDataSample
//
//  Created by Beta Catalina on 9/16/19.
//  Copyright © 2019 Andrei Popilian. All rights reserved.
//

import UIKit
import CoreData

final class ViewController: UIViewController {


  @IBOutlet weak var myTableView: UITableView!
  
  private var items: [Person] = [Person]()
  var coreDataStack: CoreDataManager = CoreDataManager.shared

  lazy var fetchedResultsController: NSFetchedResultsController<Person> = {

    var fetchedResultsController: NSFetchedResultsController<Person>!

    coreDataStack.performOnMainSync { (context) in
      let request = Person.fetchCustomRequest()
      request.fetchLimit = 100
      request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

      // Initialize Fetched Results Controller
      fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }

    fetchedResultsController.delegate = self
    return fetchedResultsController
  }()

  @IBAction func addMore(_ sender: Any) {

    coreDataStack.performOnBackgroundAsync { (context) in
      let randomNo = Int16.random(in: 0...1000)
      let person = Person(context: context)
      person.name = self.randomString(length: 5)
      person.age = randomNo
      
      let event = Event(context: context)
      event.addPersonsObject(person)
      event.name = "Event \(randomNo)"
      //before migration
      //  event.data = Data(event.name!.utf8).base64EncodedString()
      person.event = event

      //dataAttachment - after migration
      let dataAttachment = DataAttachment(context: context)
      dataAttachment.data = Data(event.name!.utf8).base64EncodedString()
      event.dataAttachment = dataAttachment

      self.coreDataStack.saveContext(context)
    }
  }

  @IBAction func deleteItem(_ sender: Any) {

    coreDataStack.performOnBackgroundAsync { (backgroundContext) in
      let person = self.fetchedResultsController.fetchedObjects?.first

      guard let rPerson = person else {
        return
      }
      let item = backgroundContext.object(with: rPerson.objectID)
      backgroundContext.delete(item)
      self.coreDataStack.saveContext(backgroundContext)
    }
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    CoreDataManager.shared.setup(completion: {
      self.fetchedResultsController.performSafeFetch { (error) in
        if let _ = error {
          //do something without being forced to use try catch
        }
      }
    })
  }
}

extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    fetchedResultsController.sections?.first?.numberOfObjects ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    var cell = tableView.dequeueReusableCell(withIdentifier: "cell")

    if cell == nil {
      cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
    }
    let object = fetchedResultsController.object(at: indexPath)
    //cell?.textLabel?.text = object.name
    cell?.textLabel?.text = object.event?.dataAttachment?.data

    return cell!
  }
}


extension ViewController: NSFetchedResultsControllerDelegate {

  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    myTableView.beginUpdates()
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    myTableView.endUpdates()
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

    switch (type) {
    case .insert:
      if let indexPath = newIndexPath {
        myTableView.insertRows(at: [indexPath], with: .right)
      }

    case .delete:
      if let indexPath = indexPath {
        myTableView.deleteRows(at: [indexPath], with: .fade)
      }

    case .update:
      if let indexPath = indexPath {
        let cell = myTableView.cellForRow(at: indexPath)
        cell?.textLabel?.text = "ZZZZZZZZZZZZZZ!!!!!!!"
      }

    case .move:
      if let indexPath = indexPath {
        myTableView.deleteRows(at: [indexPath], with: .fade)
      }

      if let newIndexPath = newIndexPath {
        myTableView.insertRows(at: [newIndexPath], with: .fade)
      }
    @unknown default: break
    }
  }
}


//MARK: - Private Zone
private extension ViewController {

  func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
  }
}


