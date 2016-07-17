//
//  Photo.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 17/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import CoreData

public final class Photo: ManagedObject {
	@NSManaged public var date: NSDate
	@NSManaged public var photoImage: NSData
	@NSManaged public var owner: Pin
}

extension Photo: ManagedObjectType {
	public static var entityName: String {
		return "Photo"
	}
}

