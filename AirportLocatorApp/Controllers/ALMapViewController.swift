//
//  ALMapViewController.swift
//  AirportLocatorApp
//
//  Created by Bhagyashree Haresh Khatri on 24/10/2019.
//  Copyright © 2019 Bhagyashree Haresh Khatri. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ALMapViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let locationManager = CLLocationManager()
    let presenter = ALMapPresenter(alMapService: ALMapService())
    
    var latitude : String?
    var longitude : String?
    var from, to: CLLocation?
    
    //MARK: APPLICATION LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        uiConfig()
    }
    
    //MARK: INITIAL SETUP
    func uiConfig() {
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        dertermineLocation()
        mapView.delegate = self
        mapView.mapType = .hybrid
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        activityIndicator?.hidesWhenStopped = true
        presenter.attachView(view: self)
    }
    
    //MARK: ALLOW ACCESS FOR CURRENT LOCATION
    func dertermineLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.latitude = "0.0"
                self.longitude = "0.0"
            case .authorizedAlways, .authorizedWhenInUse:
                guard let currentLocation = locationManager.location else {
                    return
                }
                self.latitude = String(currentLocation.coordinate.latitude)
                self.longitude = String(currentLocation.coordinate.longitude)
                presenter.airportListAPI(latitude:latitude ?? "0.0",longitude:longitude ?? "0.0")
                
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075))
        mapView.setRegion(region, animated: true)
       
    }
    
    //MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
}

//MARK: - Protocols Implementation
extension ALMapViewController: MapControllerView {
    
    func onSuccess(list: AirportListModel){
        if list.isSuccess == true{
            let annotations = list.results.map { location -> MKAnnotation in
                let annotation = MKPointAnnotation()
                annotation.title = location.name
                if let currentLocation = locationManager.location {
                    let currentLocationCoordinate = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                   let coordinateDistance = CLLocation(latitude: location.latitude, longitude: location.longitude)
                   let distanceInMeters = coordinateDistance.distance(from: currentLocationCoordinate)
                    if distanceInMeters < 1000 {
                        let strDistance = String(format: "%.2f", distanceInMeters)
                                          annotation.subtitle = "Distance: " + strDistance + "M"
                    }
                    else {
                        let strDistance = String(format: "%.2f", (distanceInMeters/1000))
                        annotation.subtitle = "Distance: " + strDistance + "KM"
                    }
                }
                
                annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                return annotation
            }
            self.mapView.addAnnotations(annotations)
        }
    }
    
    func startLoading() {
        // Show your loader
        activityIndicator?.startAnimating()
    }
    
    func finishLoading() {
        // Dismiss your loader
        activityIndicator?.stopAnimating()
    }
    
    func showError(errorMessage: String){
        // show error loader
        ALHelper.showToast(controller: self, message: errorMessage)
    }
}
