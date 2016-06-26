//
//  PinSelectedViewController.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 24/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import MapKit

class PinSelectedViewController: UIViewController {
	
	@IBOutlet weak var mapView: MKMapView!
	
	@IBAction func buttonPressed(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	
}