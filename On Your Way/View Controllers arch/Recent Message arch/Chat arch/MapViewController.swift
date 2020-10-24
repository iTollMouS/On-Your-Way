//
//  MapViewController.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/23/20.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        return mapView
    }()
    
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        
    }
    
    fileprivate func configureMapView(){
        guard let location = location else { return }
        view.addSubview(mapView)
        mapView.fillSuperview()
        mapView.setCenter(location.coordinate, animated: true)
        mapView.addAnnotation(MapAnnotation.init(title: nil, coordinate: location.coordinate))
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200), animated: true)
        title = "Map View"
        
    }
    
    
}
