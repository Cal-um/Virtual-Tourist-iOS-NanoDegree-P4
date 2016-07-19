//
//  ManagedObject.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 17/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import CoreData

public class ManagedObject: NSManagedObject {
}

public protocol ManagedObjectType: class {
		static var entityName: String { get }
}

extension ManagedObjectType where Self: ManagedObject  {
	
	static public func findOrFetchSingleInstanceInContext(moc: NSManagedObjectContext, matchingPredicate predicate: NSCompoundPredicate) -> Self? {
		guard let obj = findInContext(moc, matchingPredicate: predicate) else {
			return fetchInContext(moc) { request in
				request.predicate = predicate
				request.returnsObjectsAsFaults = false
				request.fetchLimit = 1
			}.first
		}
		return obj
	}
	
	static public func findAllInContext(moc: NSManagedObjectContext, matchingPredicate predicate: NSCompoundPredicate, numberInAlbum: Int) -> [Self]? {
		var holder = [Self]()
		for _ in 1...numberInAlbum {
			for obj in moc.registeredObjects where !obj.fault {
				print("checking")
				print(obj)
				guard let res = obj as? Self where predicate.evaluateWithObject(res) && holder.contains(res) == false else		{ continue }
				print(res)
				holder.append(res)
			}
		}
		return holder
	}
	
	static public func findInContext(moc: NSManagedObjectContext, matchingPredicate predicate: NSCompoundPredicate) -> Self? {

		for obj in moc.registeredObjects where !obj.fault {
			print("checking")
			print(obj)
			guard let res = obj as? Self where predicate.evaluateWithObject(res) else { continue }
			print(res)
			return res
			}
		return nil
		}

	public static func fetchInContext(context: NSManagedObjectContext, @noescape configurationBlock: NSFetchRequest -> () = { _ in }) -> [Self] {
		let request = NSFetchRequest(entityName: Self.entityName)
		configurationBlock(request)
		guard let result = try! context.executeFetchRequest(request) as? [Self] else { fatalError("Fetched objects have wrong type") }
		return result
	}
}
