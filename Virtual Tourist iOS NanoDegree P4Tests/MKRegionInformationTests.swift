//
//  MKRegionInformationTests.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 21/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import XCTest
import MapKit
@testable import Virtual_Tourist_iOS_NanoDegree_P4

class MKRegionInformationTests: XCTestCase {

	override func setUp() {
			super.setUp()
	}
	
	override func tearDown() {
			super.tearDown()
	}

	func testThatItInitializesWithInputs() {
	
		let sut = MKRegionInformation(longitude: 100.0, latitude: 120.4, latDelta: 10, longDelta: 15)
		XCTAssertNotNil(sut)
	}
	
	func testThatItInitializesWithRegionInput() {
		
		// Given
		let coordinate = CLLocationCoordinate2D(latitude: 20.50, longitude: 100.45)
		let span = MKCoordinateSpan(latitudeDelta: 39, longitudeDelta: 10)
		let region = MKCoordinateRegion(center: coordinate, span: span)
		// When
		let sut = MKRegionInformation(region: region)
		//Then
		XCTAssertNotNil(sut)
		
	}
	
	func testThatItReturnsRegion() {
		
		// Given
		let sut = MKRegionInformation(longitude: 130.0, latitude: 120.1, latDelta: 40, longDelta: 1)
		// When
		let region = sut.returnMKCoordinateRegion()
		// Then
		XCTAssertTrue(region is MKCoordinateRegion)
	}

}






