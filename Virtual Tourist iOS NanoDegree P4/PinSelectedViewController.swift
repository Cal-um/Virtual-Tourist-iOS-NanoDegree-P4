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

// The collectionView and fetchedResultsController have been moved into their own classes for easy resuse and to declutter the viewController. Download of images are initiated when there are no cells in the collectionView or the user taps the "new album" button.

class PinSelectedViewController: UIViewController, ManagedObjectContextSettable, SelectedPinSettable {
	
	var downloadSyncAndMOC: DownloadSync!
	var selectedPin: Pin!
	var mainContext: NSManagedObjectContext! 
	
	@IBOutlet weak var newCollectionButton: UIBarButtonItem!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var animateView: UIView!
	
	@IBAction func newCollectionPressed(sender: AnyObject) {
		deletePhotosFromContext()
	}
	
	@IBAction func buttonPressed(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func viewDidLoad() {
		setMapView()
		mainContext = downloadSyncAndMOC.mainManagedObjectContext
		setUpCollectionView()
		if collectionView.numberOfItemsInSection(0) == 0 {
			print(downloadSyncAndMOC.downloadImagesFromNetwork(latFromPin: selectedPin.latitude, longFromPin: selectedPin.longitude))
		}
	}
	
	private typealias PhotosDataProvider = FetchedResultsDataProvider<PinSelectedViewController>
	private var dataSource: CollectionViewDataSource<PinSelectedViewController, PhotosDataProvider, PhotoCollectionViewCell>!
	
	private func setUpCollectionView() {
		collectionView.delegate = self
	  let request = NSFetchRequest(entityName: "Photo")
		let pin = selectedPin
		let pred = NSPredicate(format: "owner = %@", argumentArray: [pin])
		request.sortDescriptors = [NSSortDescriptor(key: "dateOfDownload", ascending: true)]
		request.predicate = pred
		let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
		let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
		guard let cv = collectionView else { fatalError("must have collection view") }
		dataSource = CollectionViewDataSource(collectionView: cv, dataProvider: dataProvider, delegate: self)
	}
	
	private func setMapView() {
		mapView.scrollEnabled = false
		mapView.zoomEnabled = false
		let span = MKCoordinateSpanMake(0.030, 0.030)
		let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: selectedPin.latitude, longitude: selectedPin.longitude), span: span)
		mapView.setRegion(region, animated: true)
		let annotation = MKPointAnnotation()
		annotation.coordinate = CLLocationCoordinate2D(latitude: selectedPin.latitude, longitude: selectedPin.longitude)
		mapView.addAnnotation(annotation)
	}
	
	private func deletePhotosFromContext() {
		
		let numberOfPhotosInCollectionView = collectionView.numberOfItemsInSection(0)
		let pred = NSPredicate(format: "owner = %@", argumentArray: [selectedPin])
		let comp = NSCompoundPredicate(andPredicateWithSubpredicates: [pred])
		let photosInAlbum = Photo.findAllInContext(mainContext, matchingPredicate: comp, numberInAlbum: numberOfPhotosInCollectionView)
		print(photosInAlbum?.count)
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

extension PinSelectedViewController: UICollectionViewDelegate {
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		mainContext.deleteObject(dataSource.selectedObjectAtIndexPath(indexPath))
		mainContext.trySave()
	}
}


