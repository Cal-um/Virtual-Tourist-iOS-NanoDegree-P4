//
//  FetchedResultsDataProvider.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 06/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import CoreData
import UIKit

class FetchedResultsDataProvider<Delegate: DataProviderDelegate>: NSObject, DataProvider, NSFetchedResultsControllerDelegate, SelectedPinSettable {
	
	typealias Object = Delegate.Object
	
	init(fetchedResultsController: NSFetchedResultsController, delegate: Delegate) {
		self.fetchedResultsController = fetchedResultsController
		self.delegate = delegate
		self.selectedPin = delegate.callBackSelectedPin()
		self.managedObjectContexts = delegate.managedObjectContexts
		super.init()
		try! fetchedResultsController.performFetch()
		//self.fetchedResultsController.delegate = self
	}
		
	func objectAtIndexPath(indexPath: NSIndexPath) -> Object {
		guard let result = fetchedResultsController.objectAtIndexPath(indexPath) as? Object else { fatalError("Unexpected object at \(indexPath)") }
		return result
	}
	
	func numberOfItemsInSection(section: Int) -> Int {
		if let sec = fetchedResultsController.sections?[section].numberOfObjects {
		return sec
		} else {
			return 0
		}
	}
	
	// MARK: Private
	
	private var fetchedResultsController: NSFetchedResultsController
	private weak var delegate: Delegate!
	private var updates: [DataProviderUpdate<Object>] = []
	var selectedPin: Pin!
	var managedObjectContexts: CoreDataStack!
	
	// MARK: NSFetchedResultsControllerDelegate
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		updates = []
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
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
	}
}