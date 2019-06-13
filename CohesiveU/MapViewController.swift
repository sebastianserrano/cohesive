//
//  MapViewController.swift
//  Cohesive
//
//  Created by Sebastian Serrano on 2016-07-20.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocation!
    
    override func viewWillDisappear(_ animated: Bool) {
        //fromRecent = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var region = MKCoordinateRegion()
        
        region.center.latitude = location.coordinate.latitude
        region.center.longitude = location.coordinate.longitude
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        
        mapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        mapView.addAnnotation(annotation)
        annotation.coordinate = location.coordinate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelTap(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    
}
