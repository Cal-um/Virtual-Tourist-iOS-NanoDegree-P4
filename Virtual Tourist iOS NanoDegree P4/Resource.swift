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
	let parse: NSData -> Result<A>
}

extension Resource {
	
	init(url: NSURL, parseJSON: AnyObject -> Result<A>) {
		self.url = url
		self.parse = { data in
			do {
				let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: [])
				return parseJSON(jsonData)
			} catch {
				return .Failure(.ParseError)
			}
		}
	}
}
