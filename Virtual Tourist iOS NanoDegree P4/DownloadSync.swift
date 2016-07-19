//
//  DownloadSync.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 15/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation
import CoreData

// 2 contexts connected to the same PSC. When the syncManagedObjectContext saves data (in this case downloaded data only) the mainManagedObjectContext will recieve a message from a notification and in turn will merge changes from the save.

class DownloadSync {
	
	let mainManagedObjectContext: NSManagedObjectContext!
	let syncManagedObjectContext: NSManagedObjectContext!
	
	init(mainManagedObjectContext mainMOC: NSManagedObjectContext) {
		self.mainManagedObjectContext = mainMOC
		self.syncManagedObjectContext = mainManagedObjectContext.createBackgroundContext()
		setUpNotificationForPrivateContext()
		
	}
	
	func downloadImagesFromNetwork(latFromPin lat: Double, longFromPin long: Double) {
		// load pin into background context
		let backgroundPin = findPinInContextfrom(latFromPin: lat, longFromPin: long)
		// download images based on coordinates
		syncManagedObjectContext.performBlock {
			print("1")
			self.getJSONAndParseURLs(backgroundPin) { result in
				print("2")
				print(result)
				let photoArray = self.saveTemplatePhoto(result!, backgroundPin: backgroundPin)
				self.downloadPhoto(photoArray) { _ in
					print("3")
				}
			}
		}
	}
	
	private func setUpNotificationForPrivateContext() {
		let notificationCentre = NSNotificationCenter.defaultCenter()
		notificationCentre.addObserverForName(NSManagedObjectContextDidSaveNotification, object: syncManagedObjectContext, queue: nil) { notification in
			self.mainManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
		}
	}
}

extension DownloadSync {
	
	// Networking Code
	
	func getJSONAndParseURLs(pin: Pin, completion: [String]? -> ()) {
		
		let parseAll = Resource<[String]>(url: FlickrConvenience.buildURL(pin), parseJSON: { jsonData in
			guard let json = jsonData as? JSONDictionary, photos = json["photos"] as? JSONDictionary, photo = photos["photo"] as? [JSONDictionary] else { return nil }
			return photo.flatMap(Photo.parseURLs)
		})
		WebService().load(parseAll) { result in
			completion(result)
		}
	}
	
	func downloadPhoto(photoArray: [Photo], completion: Bool -> ()) {
		
		
		var counter = 0
		for photo in photoArray {
			let getImage = Resource<NSData>(url: photo.nsURL, parse: { data in
				return data
			})
			WebService().load(getImage) { result in
				counter += 1
				if let image = result {
					print("image downloaded")
					self.sendToBackgroundContextWithImage(image, photoToAddImage: photo)
					if counter == photoArray.count {
						completion(true)
					}
				}
			}
		}
	}
	
	func findPinInContextfrom(latFromPin lat: Double, longFromPin long: Double) -> Pin {
		return Pin.findOrFetchSingleInstanceInContext(syncManagedObjectContext, matchingPredicate: Pin.constructFindPinPredicate(lat, long: long))!
	}
	
	func saveTemplatePhoto(urls: [String], backgroundPin: Pin) -> [Photo] {
		
		let urlsForDownload = Photo.randomiseURLs(urls)
		var pinsInContext: [Photo] = []
		for photoURL in urlsForDownload {
			let obj: Photo = syncManagedObjectContext.insertObject()
			obj.owner = backgroundPin
			obj.url = photoURL
			obj.dateOfDownload = NSDate()
			pinsInContext.append(obj)
		}
		syncManagedObjectContext.trySave()
		return pinsInContext
	}
	
	func sendToBackgroundContextWithImage(image: NSData, photoToAddImage: Photo) {
		print("save")
		photoToAddImage.photoImage = image
		syncManagedObjectContext.trySave()
	}
}


