//
//  PinSelectedViewController.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 24/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PinSelectedViewController: UIViewController, ManagedObjectContextSettable, SelectedPinSettable {
	
	var managedObjectContexts: CoreDataStack!
	var selectedpin: Pin!
	
	
	@IBOutlet weak var newCollectionButton: UIBarButtonItem!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var mapView: MKMapView!
	
	@IBAction func buttonPressed(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func viewDidLoad() {
		
		 
	}
	
	private typealias PhotosDataProvider = FetchedResultsDataProvider<PinSelectedViewController>
	private var dataSource: CollectionViewDataSource<PinSelectedViewController, PhotosDataProvider, PhotoCollectionViewCell>!
	
	private func setUpCollectionView() {
	  let request = NSFetchRequest(entityName: "Photo")
		let pin = selectedpin
		let pred = NSPredicate(format: "owner = %@", argumentArray: [pin])
		request.predicate = pred
		let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContexts.mainContext, sectionNameKeyPath: nil, cacheName: nil)
		let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
		guard let cv = collectionView else { fatalError("must have collection view") }
		dataSource = CollectionViewDataSource(collectionView: cv, dataProvider: dataProvider, delegate: self)
		
	}
}

extension PinSelectedViewController: DataSourceDelegate {
		
	func cellIdentifierForObject(object: Photo) -> String {
		return "photoCell"
	}
}

extension PinSelectedViewController: DataProviderDelegate {
	func dataProviderDidUpdate(updates: [DataProviderUpdate<Photo>]?) {
		dataSource.processUpdates(updates)
	}
}
	
