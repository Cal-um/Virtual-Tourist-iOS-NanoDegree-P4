//
//  WebserviceResource.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 05/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String:AnyObject]

struct Resource<A> {
	let url: NSURL
	let parse: NSData -> A?
}

extension Resource {
	init(url: NSURL, parseJSON: AnyObject -> A?) {
		self.url = url
		self.parse = { data in
			let jsonData = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
			return jsonData.flatMap(parseJSON)
		}
	}
}

