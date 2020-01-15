//
//  ViewController.swift
//  C0763588 assignment1
//
//  Created by Vivek Madishetty on 2020-01-14.
//  Copyright © 2020 Vivek Madishetty. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapButtonClick: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var LocationManager = CLLocationManager()
    var startCoordinate = CLLocationCoordinate2D()
    var destCoordinate = CLLocationCoordinate2D()
    
    var travelType: String = "Automobile"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // add long press gesture
        let uilpgr = UITapGestureRecognizer(target: self, action: #selector(tappress))
        mapView.addGestureRecognizer(uilpgr)
        uilpgr.numberOfTapsRequired = 2
        
        // Verifying from the user
        self.LocationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            LocationManager.delegate = self
            LocationManager.desiredAccuracy = kCLLocationAccuracyBest
            LocationManager.startUpdatingLocation()
        }
        
        setRegion()
    }
    
    func setRegion() {
        
        
        
        // define latitude and longitude
        let latitude: CLLocationDegrees = 42.9758
        let longitude: CLLocationDegrees = -82.3475
        
        // define delta latitude and longitude
        let latDelta: CLLocationDegrees = 0.5
        let longDelta: CLLocationDegrees = 0.5
        
        // define span
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        // define location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // set the region on the map
        mapView.setRegion(region, animated: true)
        
         mapView.delegate = self
        // mapView.userLocation = true
        
    }
    
    @objc func tappress(gestureRecognizer: UIGestureRecognizer){
        //
        mapView.removeAnnotations(mapView.annotations)
        
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        //
        let touchPoint = gestureRecognizer.location(in: mapView)
        destCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.title = "Destination"
        annotation.coordinate = destCoordinate
        mapView.addAnnotation(annotation)
        
    }
    
    
    // adding annotation for the map
    
    @IBAction func routeBtnClicked(_ sender: Any) {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        // draw route
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destCoordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        if(travelType == "A"){
            request.transportType = .automobile
        }
        else{
            
            request.transportType = .walking
        }
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            let route = unwrappedResponse.routes[0]
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    @IBAction func zoomOutBtn(_ sender: Any) {
        let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta*2, longitudeDelta: mapView.region.span.longitudeDelta*2)
        let region = MKCoordinateRegion(center: mapView.region.center, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func zoomInBtn(_ sender: Any) {
        let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta/2, longitudeDelta: mapView.region.span.longitudeDelta/2)
        let region = MKCoordinateRegion(center: mapView.region.center, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        if sender.selectedSegmentIndex == 0 {
            travelType = "A"
        }
        else{
            travelType = "Wb"
        }
        
        
    }
    
}
extension ViewController: MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        startCoordinate = locValue
    }
        
        //Function used for adding overlays
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.green
            renderer.lineWidth = 2.0
            return renderer
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3.0
            return renderer
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 2.0
            return renderer
        }
        
        return MKOverlayRenderer()
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Welcome to \(title)", message: "Have a good time in \(title)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
}

