//
//  DataProvider.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 06/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

protocol DataProvider: class {
	
	associatedtype Object
	func objectAtIndexPath(indexPath: NSIndexPath) -> Object
	func numberOfItemsInSection(section: Int) -> Int
}
