//
//  SelectLocationWithPinViewControllerTests.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 21/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//
import CoreData
import XCTest
import MapKit

@testable import Virtual_Tourist_iOS_NanoDegree_P4

class SelectLocationWithPinViewControllerTests: XCTestCase {

	var managedObjectContext: NSManagedObjectContext!
	var sut: SelectLocationWithPinViewController!

	
	
	override func setUp() {
			super.setUp()
		managedObjectContext = setUpInMemoryMainManagedObjectContext()
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		sut = storyboard.instantiateViewControllerWithIdentifier("SelectLocationWithPinViewController") as! SelectLocationWithPinViewController

		
	}
    
	override func tearDown() {
			super.tearDown()
		managedObjectContext = nil
	}

	
	func testThatMOCCanBePassedToMOCProperty() {
		// Given in setUp()
		// When
		sut.managedObjectContext = managedObjectContext
		// Then
		XCTAssertNotNil(sut.managedObjectContext)
	}
	
	func testThatMapViewNotNilAfterViewDidLoad() {
		// Given in setUp()
		// When
		_ = sut.view
		// Then
		XCTAssertNotNil(sut.mapView)
	}
	

	func setUpInMemoryMainManagedObjectContext() -> NSManagedObjectContext  {
		
		let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])
		let psc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
		
		do {
			try psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
			} catch { print("add in memory store failed")
		}
		
		let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = psc
		
		return managedObjectContext
	}
	
	

}

class MockMapView: MKMapView {
	
	var regionWasSet = false
	
	override func setRegion(region: MKCoordinateRegion, animated: Bool) {
		regionWasSet = true
	}
}
