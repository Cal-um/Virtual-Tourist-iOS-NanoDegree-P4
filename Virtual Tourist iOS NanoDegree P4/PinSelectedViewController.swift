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
	var selectedPin: Pin!
	
	
	@IBOutlet weak var newCollectionButton: UIBarButtonItem!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var mapView: MKMapView!
	
	@IBAction func buttonPressed(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func viewDidLoad() {
		collectionView.backgroundView?.backgroundColor = UIColor.whiteColor()
		setUpCollectionView()
		// load pin into background context
		let backgroundPin = findPinInContextfrom(selectedPin)
		// if the collection view is empty, download images.
		if collectionView.numberOfItemsInSection(0) == 0 {
			managedObjectContexts.backgroundContext.performBlock {
				print("1")
				self.getJSONAndParseURLs(self.selectedPin) { result in
					print("2")
					print(result)
					self.downloadPhoto(result!) { images in
						print("3")
						self.sendToBackgroundContext(images, backgroundPin: backgroundPin) { complete in
							print(complete)
							do {
								try self.managedObjectContexts.backgroundContext.save()
								print("success")
								} catch {
								fatalError("Error while saving background context \(error)")
								}
							}
						}
					}
				}
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
		let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContexts.mainContext, sectionNameKeyPath: nil, cacheName: nil)
		let dataProvider = FetchedResultsDataProvider(fetchedResultsController: frc, delegate: self)
		guard let cv = collectionView else { fatalError("must have collection view") }
		dataSource = CollectionViewDataSource(collectionView: cv, dataProvider: dataProvider, delegate: self)
	}
}

extension PinSelectedViewController: DataSourceDelegate {
		
	func cellIdentifierForObject(object: Photo) -> String {
		return "PhotoCell"
	}
}

extension PinSelectedViewController: DataProviderDelegate {
	func dataProviderDidUpdate(updates: [DataProviderUpdate<Photo>]?) {
		dataSource.processUpdates(updates)
	}
	
	func callBackSelectedPin() -> Pin {
		return selectedPin
	}
}


extension PinSelectedViewController {

	// Networking Code

	func getJSONAndParseURLs(pin: Pin, completion: [NSURL]? -> ()) {
		
		let parseAll = Resource<[NSURL]>(url: FlickrConvenience.buildURL(pin), parseJSON: { jsonData in
			guard let json = jsonData as? JSONDictionary, photos = json["photos"] as? JSONDictionary, photo = photos["photo"] as? [JSONDictionary] else { return nil }
			return photo.flatMap(Photo.parseURLs)
		})
		WebService().load(parseAll) { result in
			completion(result)
		}
	}

	func downloadPhoto(urls: [NSURL], completion: [NSData] -> ()) {
		
		let urlsForDownload = Photo.randomiseURLs(urls)
		
		var images = [NSData]()
		var counter = 0
		for url in urlsForDownload {
			let getImage = Resource<NSData>(url: url, parse: { data in
				return data
			})
			WebService().load(getImage) { result in
				counter += 1
				if let image = result {
					print("image downloaded")
					images.append(image)
					if counter == urlsForDownload.count {
						completion(images)
					}
				}
			}
		}
	}
	
	func findPinInContextfrom(pin: Pin) -> Pin {
		return Pin.findOrFetchInContext(managedObjectContexts.backgroundContext, matchingPredicate: Pin.constructFindPinPredicate(pin.latitude, long: pin.longitude))!
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

