//
//  PinSelectedViewController.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 24/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import MapKit

class PinSelectedViewController: UIViewController, ManagedObjectContextSettable {
	
	var managedObjectContexts: CoreDataStack!
	var selectedpin: Pin?
	
	@IBOutlet weak var newCollectionButton: UIBarButtonItem!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var mapView: MKMapView!
	
	@IBAction func buttonPressed(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func viewDidLoad() {
		 
	}
	
	func setUpCollectionView() {
	
		guard let cv = collectionView else { fatalError("must have collection view") }
		dataSource = CollectionViewDataSource(collectionView: cv, dataProvider: dataProvider, delegate: self)
		
	}
}

extension PinSelectedViewController: DataSourceDelegate {
		
	func cellIdentifierForObject(object: Photo) -> String {
		return "photoCell"
	}
}
	
