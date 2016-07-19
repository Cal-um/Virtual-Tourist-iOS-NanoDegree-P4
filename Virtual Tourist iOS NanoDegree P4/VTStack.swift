//
//  VTStack.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 17/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import CoreData

	private let StoreURL = NSURL.documentsURL.URLByAppendingPathComponent("VTDB.virtualTourist")
	
	public func getMainContext() -> NSManagedObjectContext? {
	
		let bundles = [NSBundle(forClass: Pin.self), NSBundle(forClass: Photo.self)]
		guard let model = NSManagedObjectModel.mergedModelFromBundles(bundles) else { fatalError("Model not found") }
	
		let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
		try! psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: StoreURL, options: nil)
		let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		moc.persistentStoreCoordinator = psc
		moc.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyStoreTrumpMergePolicyType)
		return moc
	}
	
extension NSManagedObjectContext {
	
	public func insertObject<A: ManagedObject where A: ManagedObjectType>() -> A {
		
		guard let obj = NSEntityDescription.insertNewObjectForEntityForName(A.entityName, inManagedObjectContext: self) as? A else { fatalError("Wrong object type") }
		return obj
	}
	
	public func createBackgroundContext() -> NSManagedObjectContext {
		let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
		context.persistentStoreCoordinator = persistentStoreCoordinator
		context.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyStoreTrumpMergePolicyType)
		return context
	}
	
	// returns saved pins if any.
	func fetchPins() -> [AnyObject]? {
		let fr = NSFetchRequest(entityName: "Pin")
		let pins = try? self.executeFetchRequest(fr)
		return pins
	}
	
	// This saves the context called from
	
	func trySave() {
	
		self.performBlockAndWait() {
	
			if self.hasChanges {
				do {
					try self.save()
				} catch {
					fatalError("Error while saving main context \(error)")
				}
			}
		}
	}
}



