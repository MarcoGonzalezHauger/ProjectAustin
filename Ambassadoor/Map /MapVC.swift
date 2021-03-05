//
//  MapVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 04/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CustomPointAnnotation: MKPointAnnotation {
    var tag: Int!
}

class RouteInfo: NSObject {
    var address: String = ""
    var source = CLLocationCoordinate2D()
    var destination = CLLocationCoordinate2D()
    var annotation: MKAnnotation? = nil
}

class MapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var addressContainer: AddressInfoVC!
    
    @IBOutlet weak var heightLayOut: NSLayoutConstraint!
    
    @IBOutlet weak var addreContainer: UIView!
    
    var sampleAddress = ["1 Infinite Loop, Cupertino, CA 95014","777 Brockton Avenue, Abington MA 2351","25737 US Rt 11, Evans Mills NY 13637","2041 Douglas Avenue, Brewton AL 36426"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.heightLayOut.constant = -209
        self.view .layoutIfNeeded()
        self.setCurrentLocation { (status) in
            if status{
                mapView.showsUserLocation = true
            }
        }
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.mapView.delegate = self
        
        self.setAnnotations()
    }
    
    func setAnnotations() {
                
        for (index,address) in sampleAddress.enumerated() {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                    guard let placemark = placemarks else{
                        return
                    }
                    guard let loc = placemark.first?.location else{
                        return
                    }
                    let pin = CustomPointAnnotation()
                    pin.coordinate = CLLocationCoordinate2D(latitude:
                        loc.coordinate.latitude, longitude: loc.coordinate.longitude)
//                    pin.title = "Bus Stop"
//                    pin.subtitle = "City Stand D"
                    pin.tag = index
                    self.mapView.addAnnotation(pin)
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        if let annotation = view.annotation as? CustomPointAnnotation {
            print(annotation.tag!)
            //annotation.coordinate
            let routeInfo = RouteInfo()
            routeInfo.address = self.sampleAddress[annotation.tag!]
            routeInfo.destination = annotation.coordinate
            routeInfo.source = self.location
            routeInfo.annotation = annotation
            if self.heightLayOut.constant != 1 {
                UIView.animate(withDuration: 0.6, animations: {
                    
                    self.heightLayOut.constant = 1
                    self.view .layoutIfNeeded()
                    
                }, completion: { (status) in
                    
                })
            }
            self.addressContainer.routeInfo = routeInfo
            self.addressContainer.viewDidLoad()
            
            
//            DispatchQueue.main.async {
//                self.performSegue(withIdentifier: "toAddressInfo", sender: routeInfo)
//            }
        }

    }
    
    @IBAction func closeAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let view = segue.destination as? AddressInfoVC{
            addressContainer = view
        }
        
    }
    

}

extension MapVC: CLLocationManagerDelegate{
    
    func setCurrentLocation(completion: (Bool)->()) {
        
        if CLLocationManager.locationServicesEnabled(){
            
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                completion(true)
            case .notDetermined:
                print("Not Access")
            case .restricted:
                print("Not Access")
            case .denied:
                print("Not Access")
            @unknown default:
                print("Not Access")
            }
        }
    }
    
    //MARK: Location Delegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        //self.locationManager.stopUpdatingLocation()
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.location = locValue
    }
    
}
