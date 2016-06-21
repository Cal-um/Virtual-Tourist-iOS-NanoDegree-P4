//
//  SelectLocationWIthPinViewController.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 19/05/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class SelectLocationWithPinViewController: UIViewController, ManagedObjectContextSettable {
	
	var managedObjectContext: NSManagedObjectContext!

  @IBOutlet weak var mapView: MKMapView!
	
	override func viewDidLoad() {
		if let hasRegion = MKRegionInformation.checkIfThereAreSavedCoordinatesAndDecode() {
			mapView.setRegion(hasRegion, animated: true)
		}
	}

	override func viewWillDisappear(animated: Bool) {
		let currentRegion = MKRegionInformation(region: mapView.region)
		currentRegion.saveMapCoordinateRegionToUserDefualts()
	}

}