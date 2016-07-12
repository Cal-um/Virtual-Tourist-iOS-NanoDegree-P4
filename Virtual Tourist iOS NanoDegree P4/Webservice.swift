//
//  Webservice.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 05/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation

final class WebService {
	func load<A>(resource: Resource<A>, completion: (A?) -> ()) {
		NSURLSession.sharedSession().dataTaskWithURL(resource.url) { data, _, _ in
			let result = data.flatMap(resource.parse)
			completion(result)
			}.resume()
	}
}
	
	
