//
//  MKRegionInformationTests.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 21/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import XCTest
import MapKit
import Foundation
@testable import Virtual_Tourist_iOS_NanoDegree_P4

class MKRegionInformationTests: XCTestCase {

	var commonSpan: MKCoordinateSpan!
	var commonCoord: CLLocationCoordinate2D!
	var mockUserDefaults: MockUserDefaults!
	
	override func setUp() {
			super.setUp()
		
		commonCoord = CLLocationCoordinate2D(latitude: 20.50, longitude: 100.45)
		commonSpan = MKCoordinateSpan(latitudeDelta: 39, longitudeDelta: 10)
		mockUserDefaults = MockUserDefaults(suiteName: "testing")!
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
		let region = MKCoordinateRegion(center: commonCoord, span: commonSpan)
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
	
	func testThatSaveCoordinateFunctionCanSave() {
		
		// Given 
		let region = MKCoordinateRegion(center: commonCoord, span: commonSpan)
		var sut = MKRegionInformation(region: region)
		sut.defaults = mockUserDefaults
		// When
		sut.saveMapCoordinateRegionToUserDefualts()
		// Then 
		XCTAssertTrue(mockUserDefaults.allTrue)
}
	
	class MockUserDefaults: NSUserDefaults {
		var didSaveLatitudeValue = false
		var didSaveLongitudeValue = false
		var didSaveLatDeltaValue = false
		var didSaveLongDeltaValue = false
		
		var didLoadLatitudeValue = false
		var didLoadLongitudeValue = false
		var didLoadLatDeltaValue = false
		var didLoadLongDeltaValue = false
		
		var allTrue: Bool {
			if didSaveLatDeltaValue == true && didSaveLongDeltaValue == true && didSaveLatitudeValue == true && didSaveLongitudeValue == true {
				return true
			} else {
				return false
			}
		}
		override func setDouble(value: Double, forKey defaultName: String) {
			
			switch defaultName {
				case "latitude": didSaveLatitudeValue = true
				case "longitude": didSaveLongitudeValue = true
				case "longDelta" : didSaveLongDeltaValue = true
				case "latDelta": didSaveLatDeltaValue = true
				default: break
			}
		}
		
		override func doubleForKey(defaultName: String) -> Double {
			switch defaultName {
			case "latitude": didLoadLatitudeValue = true
			case "longitude": didLoadLongitudeValue = true
			case "longDelta" : didLoadLongDeltaValue = true
			case "latDelta": didLoadLatDeltaValue = true
			default: break
			}
		return 0
		}
	}
}