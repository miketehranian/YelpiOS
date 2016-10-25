//
//  MapViewController.swift
//  Yelp
//
//  Created by Mike Tehranian on 10/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager : CLLocationManager!
    var businesses: [Business]!
    
    @IBAction func onDoneTap(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
        goToLocation(location: centerLocation)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        
        navigationController?.navigationBar.barTintColor = UIColor.red;
        navigationController?.navigationBar.tintColor = UIColor.white;
        navigationController?.navigationBar.isTranslucent = false;
        
        for business in businesses {
            let location2D = CLLocationCoordinate2D(latitude: business.latitiude!, longitude: business.longitude!)
            addAnnotationAtCoordinate(coordinate: location2D, withTitle: business.name)
        }
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    private func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, withTitle title: String?) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
}


extension MapViewController: CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            mapView.setRegion(region, animated: false)
        }
    }
}
