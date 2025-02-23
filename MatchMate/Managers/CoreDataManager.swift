//
//  CoreDataManager.swift
//  MatchMate
//
//  Created by Nivrutti Kokane on 23/02/25.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MatchMate")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // Create a new managed object of the given type
    func create<T: NSManagedObject>(objectType: T.Type) -> T? {
        let entityName = String(describing: objectType)
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return nil }
        return T(entity: entity, insertInto: context)
    }

    // Fetch objects of the given type with an optional predicate
    func fetch<T: NSManagedObject>(objectType: T.Type, predicate: NSPredicate? = nil) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: objectType))
        request.predicate = predicate
        do {
            return try context.fetch(request)
        } catch {
            debugPrint("Failed to fetch \(objectType): \(error)")
            return []
        }
    }

    func checkExistence<T: NSManagedObject>(objectType: T.Type, id: String, key: String) -> (exists: Bool, objects: [T]) {
        let predicate = NSPredicate(format: "%K == %@", key, id as CVarArg)
        let results = fetch(objectType: objectType, predicate: predicate)
        return (!results.isEmpty, results)
    }


    // Save the context if there are changes
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            debugPrint("Failed to save context: \(error)")
        }
    }

    // Delete an object from Core Data
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        saveContext()
    }
}
