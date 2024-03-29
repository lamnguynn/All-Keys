//
//  PersistenceManager.swift
//  All Pass
//
//  Created by Lam Nguyen on 6/21/21.
//

import Foundation
import UIKit
import CoreData

public extension URL{
    static func storeURL(for appGroup: String, databaseName: String) -> URL{
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else{
            fatalError("Shared file container could not be created")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}


final class PersistenceManager{
    init(){}
    
    static var context: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    //MARK: core data stack

    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "All_Keys")
        let storeURL = URL.storeURL(for: "group.All_Keys", databaseName: "All_Keys")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentStoreFileProtectionKey)         //Adds data protection to sql file
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support

    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
