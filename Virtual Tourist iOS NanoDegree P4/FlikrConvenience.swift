//
//  FlikrConvenience.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 12/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

struct FlickrConvenience {
	
	static func buildURL(with: Pin) -> NSURL {
		let lat: Double = with.latitude
		let long: Double = with.longitude
		return NSURL(string:"https://api.flickr.com/services/rest/?extras=url_m&api_key=33a9a4b20a7dde72e98e1ded1afcf586&method=flickr.photos.search&lon=\(long)&lat=\(lat)&format=json&radius=1&nojsoncallback=1")!
	}
	
}

extension Photo {
	
	static func parseURLs(dictionary: JSONDictionary) -> String? {
		guard let urlString = dictionary["url_m"] as? String else { return nil }
		return urlString
	}
	
	static func randomiseURLs(urls: [String]) -> [String] {
		var count = urls.count
		var urlsForDownload = [String]()
		if urls.count >= 15 {
			while urlsForDownload.count != 15 {
				urlsForDownload.append(urls[Int(arc4random_uniform(UInt32(count)))])
				count -= 1
			}
		} else {
			urlsForDownload = urls
		}
		return urlsForDownload
	}
}


	
	
	
	
	




