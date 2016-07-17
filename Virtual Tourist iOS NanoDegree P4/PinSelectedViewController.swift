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
	var mainContext: NSManagedObjectContext! 
	
	
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
		let pin = selectedPin
		let pred = NSPredicate(format: "owner = %@", argumentArray: [pin])
		request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
		request.predicate = pred
		let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
		let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
		guard let cv = collectionView else { fatalError("must have collection view") }
		dataSource = CollectionViewDataSource(collectionView: cv, dataProvider: dataProvider, delegate: self)
	}
	
	private func deletePhotosFromContext() {
		
		let numberOfPhotosInCollectionView = collectionView.numberOfItemsInSection(0)
		let pred = NSPredicate(format: "owner = %@", argumentArray: [selectedPin])
		let comp = NSCompoundPredicate(andPredicateWithSubpredicates: [pred])
		let photosInAlbum = Photo.findAllInContext(mainContext, matchingPredicate: comp, numberInAlbum: numberOfPhotosInCollectionView)
		print(photosInAlbum?.count)
	//	guard numberOfPhotosInCollectionView == photosInAlbum!.count else { fatalError("Photos were not in context") }
		for delete in photosInAlbum! {
			mainContext.deleteObject(delete)
		}
		mainContext.trySave()
		downloadSyncAndMOC.downloadImagesFromNetwork(latFromPin: selectedPin.latitude, longFromPin: selectedPin.longitude)
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
	
	
}



	func sendToBackgroundContext(images:[NSData], backgroundPin: Pin, completion: Bool -> ()) {
		
		for image in images {
			print("save")
			let obj: Photo = self.managedObjectContexts.backgroundContext.insertObject()
			obj.photoImage = image
			obj.owner = backgroundPin
			obj.date = NSDate()
		}
		completion(true)
	}
}

