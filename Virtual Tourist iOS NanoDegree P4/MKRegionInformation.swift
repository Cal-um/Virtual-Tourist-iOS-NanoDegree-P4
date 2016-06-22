//
//  MKRegionInformation.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 21/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import MapKit
import Foundation

class MKRegionInformation {
	
	let latitude: Double
	let longitude: Double
	let latDelta: Double
	let longDelta: Double
	var defaults = NSUserDefaults.standardUserDefaults()
	
	init(region: MKCoordinateRegion) {
		
		latitude = region.center.latitude
		longitude = region.center.longitude
		latDelta = region.span.latitudeDelta
		longDelta = region.span.longitudeDelta
	}
	
	init(longitude: Double, latitude: Double, latDelta: Double, longDelta: Double) {
		
		self.latitude = latitude
		self.longitude = longitude
		self.latDelta = latDelta
		self.longDelta = longDelta
	}
	
	func returnMKCoordinateRegion() -> MKCoordinateRegion {
		
		let coordinate2d = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		let coordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
		let region = MKCoordinateRegion(center: coordinate2d, span: coordinateSpan)
		return region
	}
	
	func saveMapCoordinateRegionToUserDefualts() {
		

		defaults.setDouble(latitude, forKey: "latitude")
		defaults.setDouble(longitude, forKey: "longitude")
		defaults.setDouble(latDelta, forKey: "latDelta")
		defaults.setDouble(longDelta, forKey: "longDelta")
	}
	
	static func checkIfThereAreSavedCoordinatesAndDecode() -> MKCoordinateRegion? {
		
		let defaults = NSUserDefaults.standardUserDefaults()
		
		let lat = defaults.doubleForKey("latitude")
		let long = defaults.doubleForKey("longitude")
		let latDelta = defaults.doubleForKey("latDelta")
		let longDelta = defaults.doubleForKey("longDelta")
		
		if (lat + long + latDelta + longDelta) == 0 {
			return nil
		} else {
			let createValues = MKRegionInformation(longitude: long, latitude: lat, latDelta: latDelta, longDelta: longDelta)
			return createValues.returnMKCoordinateRegion()
		}
	}
}