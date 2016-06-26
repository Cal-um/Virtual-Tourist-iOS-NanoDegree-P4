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
	
	var shortTapOnPin: Bool = false
	var managedObjectContext: NSManagedObjectContext!
	var annotations: [MKAnnotation] {
		let coord = CLLocationCoordinate2D(latitude: 57.70, longitude: -2.74)
		let anno1 = MKPointAnnotation()
		anno1.coordinate = coord
		let anno2 = MKPointAnnotation()
		anno2.coordinate = CLLocationCoordinate2D(latitude: 57.68, longitude: -2.72)
		var temp: [MKAnnotation] = []
		temp.append(anno1)
		temp.append(anno2)
		return temp
	}

  @IBOutlet weak var mapView: MKMapView!
	
	override func viewDidLoad() {

		
		loadCoordinatesIfSavedOnLastSession()
		
		// Configure map press
		mapView.delegate = self
		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction))
		longPress.minimumPressDuration = 1.0
		mapView.addGestureRecognizer(longPress)
		
		let shortPress = UITapGestureRecognizer(target: self, action: #selector(self.shortPressAction))
		mapView.addGestureRecognizer(shortPress)
		
		print(mapView.gestureRecognizers)
		mapView.addAnnotations(annotations)
	}

	override func viewWillDisappear(animated: Bool) {
		
		let currentRegion = MKRegionInformation(region: mapView.region)
		currentRegion.saveMapCoordinateRegionToUserDefualts()
	}
	
	func loadCoordinatesIfSavedOnLastSession() {
		
		guard let hasRegion = MKRegionInformation.checkIfThereAreSavedCoordinatesAndDecode() else { return }
			mapView.setRegion(hasRegion, animated: true)
	}
	
	func longPressAction(gesture: UIGestureRecognizer) {
		
		//if gesture.state != .Began { return }
		
		print("longPressAction state of shortTapOnPin = \(shortTapOnPin)")
		let touchLocation = gesture.locationInView(self.mapView)
		let touchMapCoord = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)
		
		let annotation = MKPointAnnotation()
		annotation.coordinate = touchMapCoord
		
		mapView.addAnnotation(annotation)
	}
	
	func shortPressAction(gesture: UIGestureRecognizer) {
		//if gesture.state != .Began { return }
			print("shortPressAction state of shortTapOnPin = \(shortTapOnPin)")
			shortTapOnPin = true
		
	}
}



extension SelectLocationWithPinViewController: MKMapViewDelegate {
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
	
		let reuseId = "pin"
		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView?.draggable = true
			pinView?.selected = true
			pinView?.animatesDrop = true
			pinView?.pinTintColor = UIColor.greenColor()
		} else {
			pinView?.annotation = annotation
		}
		return pinView
	}
	
	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
		if newState != MKAnnotationViewDragState.Ending {
			// TODO: this is where to delete the old pin from core data and save the new one.
			let droppedAt = view.annotation?.coordinate
			print(droppedAt)
			shortTapOnPin = false
		}
	}

	func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
		if shortTapOnPin == true {
			print("didSelectAnnotationView state of shortTapOnPin = \(shortTapOnPin)")
		performSegueWithIdentifier("ShowPhotos", sender: nil)
		}
	}
}