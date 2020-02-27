//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
import CoreData
/*
    Core Data Stack:
        * Using the NSPersistentCloudKitContainer to take advantage of CK Syncing.
 */
final class CoreDataManager {
    
    /// 'Tasks' PersistentCloudKitContainer.
    private static var persistentCloudKitContainer: NSPersistentCloudKitContainer = {
        /// NSPersistentCKContainer 'name' needs to be the same name as the .xcdatamodeld file in Xcode!
        let cloudKitContainer = NSPersistentCloudKitContainer(name: "Tasks")
        let storeURL = URL.storeURL(for: .appGroup, databaseName: .databaseName)
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = true
        
        cloudKitContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("CoreDataAndCloudKit Error \(error)")
            }
        }
        return cloudKitContainer
    }()
    /// Managed Object Context used by both the main bundle and the Today Widget,
    private static var mainThreadManagedObjectContext: NSManagedObjectContext = {
        let context = persistentCloudKitContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    
    //MARK - Core Data Methods
    //Saving in the Today Widget
    
    /// The saveContext method used in the TodayWidget. API is not accessable in the Framework so this method is used within the Today Widget when updating any view changes.
    func saveContext() {
        if CoreDataManager.mainThreadManagedObjectContext.hasChanges {
            CoreDataManager.mainThreadManagedObjectContext.performAndWait {
                do {
                    try CoreDataManager.mainThreadManagedObjectContext.save()
                }
                catch let error as NSError {
                    fatalError("WriteToDatabaseProtocol - Save MOC Failed \(error.localizedDescription)")
                }
            }
        }
    }
    
}

extension CoreDataManager {
    /// NSPersistentCloudKitContainer.viewContext; This context is used in the Main Bundle and the Today Widget.
    static var context: NSManagedObjectContext {
        get {
            return self.mainThreadManagedObjectContext
        }
    }
}

//MARK -
/// URL Extension only used in this class.
extension URL {
    static func storeURL(for appGroup: AppGroup, databaseName: AppGroup) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup.tasksAppGroupDescription) else {
            fatalError("Shared File Can Not Be Created")
        }
        return fileContainer.appendingPathComponent("\(databaseName.tasksDatabaseName).sqlite")
    }
}

enum AppGroup {
    case appGroup
    case databaseName
    
    var tasksDatabaseName: String {
        switch self {
        case .appGroup:         return "group.Tasks.Extensions"
        case .databaseName:      return "Tasks"
        }
    }
    
    var tasksAppGroupDescription: String {
        switch self {
        case .appGroup:         return "group.Tasks.Extensions"
        case .databaseName:      return "Tasks"
        }
    }
}

extension NSPersistentCloudKitContainer {
    // Configure change event handling from external processes.
    func observeAppExtensionDataChanges() {
        DarwinNotificationCenter.shared.addObserver(self, for: .didSaveManagedObjectContextExternally) { [weak self] (_) in
            // Since viewContext is our root context that's directly connected to the persistent store we need to update our viewContext.
            self?.viewContext.perform {
                self?.viewContextDidSaveExternally()
            }
        }
    }
    
    ///Called when a certain managed object context has been saved from an external process. It should also be called on the context's queue.
    func viewContextDidSaveExternally() {
        //'refreshAllObjects' only refreshes objects from which the cache is invalid. With a stainless intervall of -1 the cache never invalidates.
        //We set the 'stainlessInterval' to 0 to make sure that changes in the app extension get processed correctly.
        viewContext.stalenessInterval = 0
        viewContext.refreshAllObjects()
        viewContext.stalenessInterval = -1
    }
}
