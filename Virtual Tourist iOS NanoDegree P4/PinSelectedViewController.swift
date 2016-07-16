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

class PinSelectedViewController: UIViewController, ManagedObjectContextSettable, SelectedPinSettable, UICollectionViewDelegate {
	
	var downloadSyncAndMOC: DownloadSync!
	var selectedPin: Pin!
	var mainContext: NSManagedObjectContext! {
		didSet {
			collectionView.reloadData()
		}
	}
	
	
	@IBOutlet weak var newCollectionButton: UIBarButtonItem!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var mapView: MKMapView!
	
	@IBAction func newCollectionPressed(sender: AnyObject) {
		deletePhotosFromContext()
	}
	
	@IBAction func buttonPressed(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func viewDidLoad() {
		collectionView.delegate = self
		mainContext = downloadSyncAndMOC.mainManagedObjectContext
		collectionView.backgroundView?.backgroundColor = UIColor.whiteColor()
		setUpCollectionView()
		if collectionView.numberOfItemsInSection(0) == 0 {
			downloadSyncAndMOC.downloadImagesFromNetwork(latFromPin: selectedPin.latitude, longFromPin: selectedPin.longitude)
		}
	}
	
	private typealias PhotosDataProvider = FetchedResultsDataProvider<PinSelectedViewController>
	private var dataSource: CollectionViewDataSource<PinSelectedViewController, PhotosDataProvider, PhotoCollectionViewCell>!
	
	private func setUpCollectionView() {
	  let request = NSFetchRequest(entityName: "Photo")
		let pred = NSPredicate(format: "owner = %@", argumentArray: [selectedPin])
		request.sortDescriptors = [NSSortDescriptor(key: "photoImage", ascending: true)]
		request.predicate = pred
		let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: downloadSyncAndMOC.mainManagedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
		let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
		guard let cv = collectionView else { fatalError("must have collection view") }
		dataSource = CollectionViewDataSource(collectionView: cv, dataProvider: dataProvider, delegate: self)
	}
	
	private func deletePhotosFromContext() {
		
		let request = NSFetchRequest(entityName: "Photo")
		let pred = NSPredicate(format: "owner = %@", argumentArray: [selectedPin])
		request.predicate = pred
		let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
		try! downloadSyncAndMOC.mainManagedObjectContext.executeRequest(batchDelete)
		downloadSyncAndMOC.mainManagedObjectContext.trySave()
	}
	
}

extension PinSelectedViewController: DataSourceDelegate {
		
	func cellIdentifierForObject(object: Photo) -> String {
		return "PhotoCell"
	}
}

extension PinSelectedViewController: DataProviderDelegate {
	func dataProviderDidUpdate(updates: [DataProviderUpdate<Photo>]?) {
		print("updates")
		dataSource.processUpdates(updates)
	}
	
	func callBackSelectedPin() -> Pin {
		return selectedPin
	}
}




