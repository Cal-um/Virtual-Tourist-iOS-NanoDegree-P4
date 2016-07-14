//
//  FetchedResultsDataProvider.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 06/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import CoreData
import UIKit

class FetchedResultsDataProvider<Delegate: DataProviderDelegate>: NSObject, DataProvider, NSFetchedResultsControllerDelegate, SelectedPinSettable {
	
	typealias Object = Delegate.Object
	
	init(fetchedResultsController: NSFetchedResultsController, delegate: Delegate) {
		self.fetchedResultsController = fetchedResultsController
		self.delegate = delegate
		self.selectedPin = delegate.callBackSelectedPin()
		self.managedObjectContexts = delegate.managedObjectContexts
		super.init()
		try! fetchedResultsController.performFetch()
	}
		
	func objectAtIndexPath(indexPath: NSIndexPath) -> Object {
		guard let result = fetchedResultsController.objectAtIndexPath(indexPath) as? Object else { fatalError("Unexpected object at \(indexPath)") }
		return result
	}
	
	func numberOfItemsInSection(section: Int) -> Int {
		if let sec = fetchedResultsController.sections?[section].numberOfObjects {
			switch sec {
			case 0:
				let backgroundPin = self.findPinInContextfrom(selectedPin)
				print("0")
				managedObjectContexts.performBackgroundSave { _ in
					print("1")
					self.getJSONAndParseURLs(self.selectedPin) { result in
						print("2")
						print(result)
						self.downloadPhoto(result!) { images in
							print("3")
							self.sendToBackgroundContext(images, backgroundPin: backgroundPin) { complete in
								print(complete)
							}
						}
					}
				}
				return 0
			default:
				return sec
			}
		} else {
			return 0
		}
	}
	
	// MARK: Private
	
	private var fetchedResultsController: NSFetchedResultsController {
		didSet {
			fetchedResultsController.delegate = self
		}
	}
	private weak var delegate: Delegate!
	private var updates: [DataProviderUpdate<Object>] = []
	var selectedPin: Pin!
	var managedObjectContexts: CoreDataStack!
	
	// MARK: NSFetchedResultsControllerDelegate
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		updates = []
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		switch type {
		case .Insert:
			print("inserted")
			guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
			updates.append(.Insert(indexPath))
		case .Update:
			guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
			let object = objectAtIndexPath(indexPath)
			updates.append(.Update(indexPath, object))
		case .Move:
			guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
			guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
			updates.append(.Move(indexPath, newIndexPath))
		case .Delete:
			guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
			updates.append(.Delete(indexPath))
		}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		delegate.dataProviderDidUpdate(updates)
	}
	
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
		}
		completion(true)
	}
}