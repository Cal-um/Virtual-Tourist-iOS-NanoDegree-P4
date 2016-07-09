//
//  VTStack.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 17/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import CoreData

struct CoreDataStack {
	
	// This stack consists of 1 parent and  2 child contexts. The persitingContext is the parent and is used to make background saves. THe main context us used for all UI and is where data is fetched to. The background context is utilized for asynchrounous downloading from the network.
	
	let mainContext: NSManagedObjectContext
	private let persistingContext: NSManagedObjectContext
	private let backgroundContext: NSManagedObjectContext
	
	
	private let StoreURL = NSURL.documentsURL.URLByAppendingPathComponent("VTDB.virtualTourist")
	
	init?() {
	
		let bundles = [NSBundle(forClass: Pin.self), NSBundle(forClass: Photo.self)]
		guard let model = NSManagedObjectModel.mergedModelFromBundles(bundles) else { fatalError("Model not found") }
	
		let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
		try! psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: StoreURL, options: nil)
	
	
		persistingContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
		persistingContext.persistentStoreCoordinator = psc
		
		mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		mainContext.parentContext = persistingContext
		
		backgroundContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
		backgroundContext.parentContext = mainContext
	}
}

extension CoreDataStack {
	
	// This save will push the network data to the main context.
	func performBackgroundSave() {
		backgroundContext.performBlock() {
			
			do {
				try self.backgroundContext.save()
				} catch {
					fatalError("Error while saving background context \(error)")
				}
		}
	}
	
	// This save pushes the changes from the main context to the persisting context. From there it saves in the background.
	
	func save() {
		
		mainContext.performBlockAndWait() {
			
			if self.mainContext.hasChanges {
				do {
					try self.mainContext.save()
				} catch {
					fatalError("Error while saving main context \(error)")
				}
				
				self.persistingContext.performBlock() {
					do {
						try self.persistingContext.save()
					} catch {
						fatalError("Error while saving persistingContext \(error)")
					}
				}
			}
		}
	}
}
	


