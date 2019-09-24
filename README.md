#  Core Data good practices

## Table of Contents
 * [Debugging](#debugging)
 * [Theading](#theading)
 * [Mogenerator](#mogenerator)
 * [Migrations](#migrations)
 * [Tools](#tools)
 * [Good practices or TLDR](#good-practices-in-few-words-or-tldr)
 * [References](#references)

## Debugging

While debugging please use runtime arguments: *(EditScheme -> Run Tab -> Arguments)

Argument | Description
------------ | -------------
-com.apple.CoreData.ConcurrencyDebug 1 | Throws an exception whenever your app access a managed object context or managed object from a wrong dispatch queue
-com.apple.CoreData.SQLDebug 1 | 1,2 or 3 for a more verbose output, logs in console how CoreData manages SQL fetches, details about queries, etc.
-com.apple.CoreData.MigrationDebug | Gives you insights in the console about exceptional cases as it migrates data

## Theading

 Keep  **"viewContext"**  read-only, only for fetches 
 Never ever use an **"NSManagedObject"** outside its context’s queue
 
 Core Data tries to be efficient; it typically doesn’t like to load up more data than you need, which means there are times when you ask it for data (like an object property) and it doesn’t have it handy. When this happens, it has to go load the data from its store (which might not even be a local file on disk!) before it can respond to you.

 This is called “faulting”. The marker value internal kept by a managed object is a “fault”, and the process of “fulfilling” (ie, retrieving the data) the fault is “faulting”.

 Here’s the thing: Core Data has to be safe. It has to synchronize these faulting calls with other accesses of the persistent store, and it has to do it in a way that isn’t going to interfere with other calls to fault in data. The way it does that is by expecting that all calls to fault in data happen safely inside one of its queues.

 Every managed object “belongs” to a particular MOC (more on this in a minute), and every MOC has a DispatchQueue that it uses to synchronize its internal logic about loading data from its persistentStoreCoordinator.

 If you use an NSManagedObject from outside the MOC’s queue, then the calls to fault in data are not properly synchronized and protected, which means you’re susceptible to race conditions.

 So, if you have an NSManagedObject, the only safe place to use it is from inside a call to perform or performAndWait
 
 The only managed object property that is safe to use outside of a queue or pass between queues/threads is the object’s **objectID**: this is a Core Data-provided identifier unique for that particular object. You can access this property from anywhere, and it is the only way to “transfer” a managed object from one context to another.
 
 
 ## Mogenerator
 
 Mogenerator is a command-line tool that, given an .xcdatamodel file, will generate two classes per entity. The first class, **_MyEntity**, is intended solely for machine consumption and will be continuously overwritten to stay in sync with your data model. 
 The second class, **MyEntity**, subclasses **_MyEntity**, won't ever be overwritten and is a great place to put your custom logic.
 It supports generating Swift classes and other custom typed entities or properties, e.g enums instead of Scalar or non-scalar type.
 
 How to use it:
 1. Create anothe **Target** as "Aggregate" to your project
 1. Setup an run script action on it's **Build Phases** as e.g >>> mogenerator -m YourProjectName/YourModelName.xcdatamodeld/YourModelVersions_v2.xcdatamodel -O PathWhere/ToBeExported --swift --template-var arc=true
 1. Build this "Mogenerator" **Target** everytime you change your current Core Data model
 
 [How to Install Mogenerator](http://rentzsch.github.io/mogenerator)
 You can check this tutorial [Mogenerator Usage](https://raptureinvenice.com/getting-started-with-mogenerator)
 Also [Mogenerator Documentation](https://github.com/rentzsch/mogenerator/wiki)
 

 
 ## Migrations
 
 Core Data does lightweight migration for free, like adding new properties (with default values), renaming old ones, etc *(You will have to add a new version of your model file, it doesn't work in place)
 Lightweight migration can perform:
 * Adding an attribute.
 * Removing an attribute.
 * Changing a non-optional attribute to be optional.
 * Changing an optional attribute to non-optional (by defining a default value).
 * Renaming an entity, attribute or relationship (by providing a Renaming ID).
 * Adding a relationship.
 * Removing a relationship.
 * Changing the entity hierarchy.
 
 The default Core Data model migration approach is to go from earlier version to all possible future versions.

 So, if we have 4 model versions (1, 2, 3, 4), you would need to create the following mappings 1 to 4, 2 to 4 and 3 to 4.
 Then when we create model version 5, we would create mappings 1 to 5, 2 to 5, 3 to 5 and 4 to 5. You can see that for each
 new version we must create new mappings from all previous versions to the current version. This does not scale well, in the
 above example 4 new mappings have been created. For each new version you must add n-1 new mappings.

 Instead the solution below uses an iterative approach where we migrate mutliple times through a chain of model versions.

 So, if we have 4 model versions (1, 2, 3, 4), you would need to create the following mappings 1 to 2, 2 to 3 and 3 to 4.
 Then when we create model version 5, we only need to create one additional mapping 4 to 5. This greatly reduces the work
 required when adding a new version.
 
 - Inside the Policy class use the objects as NSManagedObject (using KVC) instead of the current model type, later those will be changed/removed and you will have to rewrite your code
 - In case of heavyweight migration don't remove any entity from the mapperModel .xcmappingmodel, it will missmatch your models and the policy is never executed
 
 Steps for a new xcdataModel version and migration:
 1. Create a new model, modify/add/remove/change names of some entitie
 1. Create a new model version and add it to the CoreDataMigrationVersion as well to "nextVersion" function inside it
 1. Migrate
    1. If the migration is lightweight you don't have to do anything else, the current Sample setup will do that automatically
    1. If the migration is heavyweight you will have to create a new model Mapping file (**.xcmappingmodel**) and if needed a policy for each custom new Model or for the  nextVersion of an existing model
 1. If you are doing unit tests, check our Sample UnitTest Target and add a test for the next migration + sqlite to be tested(note: keep them light in terms of memory, you want to run them fast and keep your Version Control cloud, light as well)


## Tools

- [**DB Browser for SQLite**](https://sqlitebrowser.org) used to manipulate or check the data base and do queries

## Good practices in few words or TLDR

* Make the model as small as you can, add only entities that are ment to be persisted other computed can later be crafted

* Try to avoid performing multiple writes in parallel, use a serial synchron queue in background instead

* Use fetchBatchSize (to save memory, instead of fetching the entire data at once)

* Use NSExpressions for not sorting things in memory, Core Data does it better.

* While using Predicates put the number comparison first _e.g if we want to get objects that have a specific name and a specific age, use the age first as the computer will do it faster using numbers_.

* Predicate Costs, see "**Predicate Costs.png**" from "**Assets**" folder

* Allow external storage for a Binary Data _e.g if you are using photos, the system might decide where is better to store them, in memory or on disk, depending on their size and your usage *(toggle that in the attribute inspector of that field)_

* Large blobs as separate entity _e.g a large photo and you just want to use as a tumbnail, you add the photo in a separate entity with relationship and keep only the tumbnail in the main entity_.

* Work in batches to keep the memory low _e.g you have to import a large data set_.

* Use as much the variables (insertedObjects, updatedObject, removedObject) from the context

* Architecture approach to CoreDataStack, you can choose between **InheritanceContext** and **SharePSC** (see images in **Assets**), those 2 have the best pros than other current stacks, use the one that fits for you and your data Set

* Use **NSCompoundPredicate** instead of creating a large predicate with AND, OR, (it's convenient and ca be used with computed predicates)

* **NSManagedObjectContext** is not thread safe, must pe used on the queue it was created on

* Set the **Inverse** when using relationship, as it's helps Core Data to maintain data integrity




## References


 [Progressive CoreData Migration](https://williamboles.me/progressive-core-data-migration)

 [Laws Of CoreData](https://davedelong.com/blog/2018/05/09/the-laws-of-core-data)

 [Effective Core Data with Swift](https://www.youtube.com/watch?v=w7tFF7IfKVk)
