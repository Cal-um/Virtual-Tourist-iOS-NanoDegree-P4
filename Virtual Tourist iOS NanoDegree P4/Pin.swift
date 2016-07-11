//
//  Pin.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 17/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation
import CoreData
import MapKit

public final class Pin: ManagedObject {
	@NSManaged public var longitude: Double
	@NSManaged public var latitude: Double
	@NSManaged public private(set) var locationPhotos: Set<Photo>?
	
	static func insertPinIntoContext(from: MKAnnotation, context: CoreDataStack)  {
		
		let lat = from.coordinate.latitude
		let long = from.coordinate.longitude
		let obj: Pin = context.mainContext.insertObject()
		obj.latitude = lat
		obj.longitude = long
		context.save()
	}
}

extension Pin: ManagedObjectType {
	
	public static var entityName: String {
		return "Pin"
	}
}