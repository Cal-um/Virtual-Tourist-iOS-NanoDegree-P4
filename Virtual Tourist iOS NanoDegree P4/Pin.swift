//
//  Pin.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 17/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation
import CoreData

public final class Pin: ManagedObject {
	@NSManaged public private(set) var longitude: Double
	@NSManaged public private(set) var latutude: Double
	@NSManaged private(set) var locationPhotos: Set<Photo>?
}