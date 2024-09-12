//  Created by Dylan  on 2/27/20.
//  Copyright © 2020 Dylan . All rights reserved.

import UIKit
import CoreData
import XCTest
import TasksFramework
@testable import Tasks
@testable import TasksFramework

class CoreDataTests: XCTestCase, CanWriteToDatabase {

    var listViewController: ListsViewController?
    var itemsViewController: AddItemsToListViewController?
    
    
    /// Setup Code
    override func setUp() {
        listViewController = ListsViewController()
        itemsViewController = AddItemsToListViewController()
    }

    
    ///Testing that the managedObjectContext is not Nil
    func testManagedObjectContextNotNil() {
        let context = managedObjectContext
        XCTAssertNotNil(context)
    }
    
    ///Testing that the saveContext in CanWriteToDatabase doesn't throw an error
    func testSaveContextNoThrow() {
        XCTAssertNoThrow(saveContext)
    }
    
    
    ///Test fetching
    func testFetch() {
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        
        do {
            let results = try managedObjectContext.fetch(fetchReq)
            XCTAssertNoThrow(results)
        }
        catch let error as NSError {
            XCTAssertNil(error, "Error is Not Nil; Fetch failed")
        }
    }
    
    ///Testing that the mock list value I've created has valid data. This value will not be saved to the MOC.
    func testListValue() {
        let listOneTitle = "My First List"
        let listTwoTitle = "Second List"
        let firstList = mockListValue(title: listOneTitle)
        let secondList = mockListValue(title: listTwoTitle)
        
        //Check that both are not nil first
        XCTAssertNotNil(firstList, "Uh oh, lists are nil?")
        XCTAssertNotNil(secondList, "Uh oh, lists are nil?")
        
        //List 1
        XCTAssertEqual(firstList.title, listOneTitle, "Mock list titles are not behaving as expected")
        XCTAssertNotNil(firstList.dateAdded, "Mock list date added attribute not set properly")
        
        //List 2
        XCTAssertEqual(secondList.title, listTwoTitle, "Mock list titles are not behaving as expected")
        XCTAssertNotNil(secondList.lastUpdateDate, "Mock list last updated date is nil, and shouldn't be")
    }
    
    ///Testing that the mock item value I've created has valid data. This value will not be saved to the MOC.
    func testItemValue() {
        let itemOneName = "Item 1"
        let itemTwoName = "Item 2"
        let itemOne = mockItemsValue(itemName: itemOneName, isFlagged: true, isComplete: false)
        let itemTwo = mockItemsValue(itemName: itemTwoName, isFlagged: false, isComplete: true)
        
        //Check that both are not nil
        XCTAssertNotNil(itemOne, "Uh oh, items are nil")
        XCTAssertNotNil(itemTwo, "Uh oh, items are nil")
        
        //Item 1
        XCTAssertEqual(itemOne.isFlagged, true, "Something's Wrong")
        XCTAssertEqual(itemOne.item, itemOneName, "Something went wrong, Mock item Name Not Saved Correctly")
        XCTAssertNotNil(itemOne.isFlagged, "Mock item flagged value not being set properly")
        XCTAssertNil(itemOne.dueDate, "Mock item due date is not nil, and should be")
        
        
        //Item 2
        XCTAssertEqual(itemTwo.isFlagged, false, "isFlagged value not performing as expected")
        XCTAssertTrue(itemTwo.isComplete)
        XCTAssertNotNil(itemTwo.isFlagged, "Mock item flagged value not being set properly")
        XCTAssertNil(itemTwo.reminderDate, "Mock item reminder date is not nil, and should be")
    }
    
    
    
    // Tear Down Code
    override func tearDown() {
        listViewController = nil
        itemsViewController = nil
    }
    
    
    //MARK: - Mock Core Data Values
    ///These are not saved to the context so they will not affect Core Data values. Mocking a list and item to test that they are being created properly.
    
    func mockListValue(title: String) -> List {
        let list = NSEntityDescription.insertNewObject(forEntityName: "List", into: managedObjectContext) as! List
        let listIDString = UUID().uuidString
        let listID = listIDString.data(using: .utf8)!
        
        list.title = title
        list.recordID = listID
        list.dateAdded = Date()
        list.lastUpdateDate = Date()
        list.isCompleted = false
        return list
    }
    
    func mockItemsValue(itemName: String, isFlagged: Bool, isComplete: Bool) -> Items {
        let item = NSEntityDescription.insertNewObject(forEntityName: "Items", into: managedObjectContext) as! Items
        let itemIDString = UUID().uuidString
        let itemID = itemIDString.data(using: .utf8)!
        
        let list = mockListValue(title: "Title")
        let titleID = String(data: list.recordID!, encoding: .utf8)
        
        item.item = itemName
        item.list = list
        item.recordID = itemID
        item.titleID = titleID
        item.dateAdded = Date()
        item.lastUpdatedDate = Date()
        item.reminderDate = nil
        item.dueDate = nil
        item.isFlagged = isFlagged
        item.isComplete = isComplete
        
        return item
    }
}

