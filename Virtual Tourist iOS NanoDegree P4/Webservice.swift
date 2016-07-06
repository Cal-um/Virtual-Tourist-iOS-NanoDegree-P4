//
//  Webservice.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 05/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import Foundation

final class WebService {
	func load<A>(resource: Resource<A>, completion: (Result<A>) -> ()) {
		NSURLSession.sharedSession().dataTaskWithURL(resource.url) { data, response, error in
			let result = self.checkForErrors(data, response: response, error: error) ?? data.map(resource.parse)
			completion(result!)
			}.resume()
	}
	
	func checkForErrors<A>(data: NSData?, response: NSURLResponse?, error: NSError?) -> Result<A>? {
		guard (error == nil) else { return .Failure(.NetworkError(error!)) }
		guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else { return .Failure(.StatusCode) }
		guard (data != nil) else { return .Failure(.DataNil) }
		return nil
	}
}

enum Result<T> {
	case Success(DataReceived<T>)
	case Failure(Errors)
}

enum Errors: ErrorType {
	case NetworkError(NSError)
	case StatusCode
	case ParseError
	case DataNil
}

enum DataReceived<T> {
	case DataExpected(T)
	case NoDataAvailable
}