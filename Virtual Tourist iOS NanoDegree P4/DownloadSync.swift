//
//  DownloadSync.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 15/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation
import CoreData

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
				self.downloadPhoto(result!) { images in
					print("3")
					self.sendToBackgroundContext(images, backgroundPin: backgroundPin) { complete in
						print(complete)
						self.syncManagedObjectContext.trySave()
					}
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
	
	func findPinInContextfrom(latFromPin lat: Double, longFromPin long: Double) -> Pin {
		return Pin.findOrFetchSingleInstanceInContext(syncManagedObjectContext, matchingPredicate: Pin.constructFindPinPredicate(lat, long: long))!
	}
	
	func sendToBackgroundContext(images:[NSData], backgroundPin: Pin, completion: Bool -> ()) {
		
		for image in images {
			print("save")
			let obj: Photo = syncManagedObjectContext.insertObject()
			obj.photoImage = image
			obj.owner = backgroundPin
			obj.dateOfDownload = NSDate()
		}
		completion(true)
	}
}


