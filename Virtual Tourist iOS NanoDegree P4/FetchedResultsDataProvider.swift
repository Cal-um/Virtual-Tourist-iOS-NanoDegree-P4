//
//  FetchedResultsDataProvider.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 06/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import CoreData
import UIKit

class FetchedResultsDataProvider<Delegate: DataProviderDelegate>: NSObject, DataProvider, NSFetchedResultsControllerDelegate {
	
	typealias Object = Delegate.Object
	
	init(fetchedResultsController: NSFetchedResultsController, delegate: Delegate) {
		self.fetchedResultsController = fetchedResultsController
		self.delegate = delegate
		super.init()
		fetchedResultsController.delegate = self
		try! fetchedResultsController.performFetch()
		
	}
		
	func objectAtIndexPath(indexPath: NSIndexPath) -> Object {
		guard let result = fetchedResultsController.objectAtIndexPath(indexPath) as? Object else { fatalError("Unexpected object at \(indexPath)") }
		return result
	}
	
	func numberOfItemsInSection(section: Int) -> Int {
		guard let sec = fetchedResultsController.sections?[section] else { return 0 }
		return sec.numberOfObjects
	}
	
	// MARK: Private
	
	private var fetchedResultsController: NSFetchedResultsController
	private weak var delegate: Delegate!
	private var updates: [DataProviderUpdate<Object>] = []
	
	// MARK: NSFetchedResultsControllerDelegate
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		print("hi")
		updates = []
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		print(123)
		switch type {
		case .Insert:
			guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
			updates.append(.Insert(indexPath))
		case .Update:
			guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
			let object = objectAtIndexPath(indexPath)
			updates.append(.Update(indexPath, object))
		case .Move:
			guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
			guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
			updates.append(.Move(indexPath, newIndexPath))
		case .Delete:
			guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
			updates.append(.Delete(indexPath))
		}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		delegate.dataProviderDidUpdate(updates)
		print("changed")
	}
}