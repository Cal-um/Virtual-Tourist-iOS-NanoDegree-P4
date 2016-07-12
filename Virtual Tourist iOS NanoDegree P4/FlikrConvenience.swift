//
//  FlikrConvenience.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 12/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class FlickrConvenience {
	
	init(selectedPin: Pin) {
		self.selectedPin = selectedPin
	}
	
	// properties and helpers
	
	let selectedPin: Pin!
	
	func buildURL(with: Pin) -> NSURL {
		let lat: Double = with.latitude
		let long: Double = with.longitude
		return NSURL(string:"https://api.flickr.com/services/rest/?extras=url_m&api_key=33a9a4b20a7dde72e98e1ded1afcf586&method=flickr.photos.search&lon=\(long)&lat=\(lat)&format=json&radius=1&nojsoncallback=1")!
	}
	
	let getURLFrom = { (dictionary: JSONDictionary) -> NSURL? in
		guard let url = dictionary["url_m"] as? String else { return nil }
		return NSURL(string: url)!
	}
	
//	let getImage = Resource<UIImage>(url: photoURL, parse: { data in
//		let imageData = data, image = UIImage(data: imageData)
//		return image
//	})
	
	let url = buildURL(selectedPin)
	
	let parseAll = Resource<[Photo]>(url: buildURL(selectedPin), parseJSON: { jsonData in
		guard let json = jsonData as? JSONDictionary, photos = json["photos"] as? JSONDictionary, photo = photos["photo"] as? [JSONDictionary] else { return nil }
		return photo.flatMap(Photo.init)
	})

}

