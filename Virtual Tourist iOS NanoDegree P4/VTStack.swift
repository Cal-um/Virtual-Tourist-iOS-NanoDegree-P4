//
//  VTStack.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 17/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import CoreData

private let StoreURL = NSURL.documentsURL.URLByAppendingPathComponent("VTDB.virtualTourist")

public func createVTMainContext() -> NSManagedObjectContext? {
	
	let bundles = [NSBundle(forClass: Pin.self), NSBundle(forClass: Photo.self)]
	guard let model = NSManagedObjectModel.mergedModelFromBundles(bundles) else { fatalError("Model not found") }
	
	let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
	try! psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: StoreURL, options: nil)

	
	let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
	context.persistentStoreCoordinator = psc
	
	return context
}