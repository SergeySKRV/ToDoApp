//
//  CoreDataStack.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 01.04.2026.
//

import CoreData

/// Manages the Core Data stack used in the app.
final class CoreDataStack {

    // MARK: - Shared Instance

    static let shared = CoreDataStack()

    // MARK: - Properties

    let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Init

    init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "ToDoApp")

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            persistentContainer.persistentStoreDescriptions = [description]
        }

        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error), \(error.userInfo)")
            }
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Saving

    /// Saves the main view context if it has changes.
    func saveViewContext() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }

    // MARK: - Background Work

    /// Performs Core Data work on a background context.
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            block(context)
        }
    }

    /// Creates and returns a new background context.
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
