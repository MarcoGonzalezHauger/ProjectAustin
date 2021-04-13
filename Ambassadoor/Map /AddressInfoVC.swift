//
//  AddressInfoVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 04/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import MapKit

class AddressInfoVC: UIViewController {
    
    @IBOutlet weak var addressInfo: UILabel!
    @IBOutlet weak var estimatedTime: UILabel!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var routeInfo: RouteInfo!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        // Do any additional setup after loading the view.
    }
    
    func loadData() {
        
        if routeInfo != nil {
            self.addressInfo.text = "\(routeInfo.address)"
            getDirectionEstimatedTime()
        }
        
    }
    
    func getDirectionEstimatedTime() {
        //41.571430
        //-70.587570
        self.activity.isHidden = false
        self.activity.startAnimating()
        self.estimatedTime.text = ""
        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: routeInfo.source.latitude, longitude: routeInfo.source.longitude), addressDictionary: nil))
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 41.571430, longitude: -70.587570), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: routeInfo.destination.latitude, longitude: routeInfo.destination.longitude), addressDictionary: nil))
        request.requestsAlternateRoutes = true // if you want multiple possible routes
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate {(response, error) -> Void in

            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }

          // Lets Get the first suggested route and its travel time

           if response.routes.count > 0 {
                let route = response.routes[0]
                print(route.expectedTravelTime) // it will be in seconds
            DispatchQueue.main.async {
                self.activity.isHidden = true
                self.activity.stopAnimating()
                self.estimatedTime.text = self.secondsToHoursMinutesSeconds(seconds: Int(route.expectedTravelTime))
            }
            
                // you can show this time in any of your UILabel or whatever you want.
            }
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
    
        var formatTime = ""
        
        if (seconds / 3600) > 0 {
            formatTime = "\((seconds / 3600))h "
        }
        
        if ((seconds % 3600) / 60) > 0 {
            formatTime += "\(((seconds % 3600) / 60))m"
        }
//        if ((seconds % 3600) % 60) > 0 {
//            formatTime += "\(((seconds % 3600) % 60)) S"
//        }
        
        return formatTime
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        UIView.animate(withDuration: 0.2) {
//            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//        }
    }
    
    @IBAction func closeAction(sender: UIButton){
        if let map = self.parent as? MapVC{
            
                UIView.animate(withDuration: 0.6, animations: {
                    
                    map.heightLayOut.constant = -276
                    map.view .layoutIfNeeded()
                    
                    map.mapView.deselectAnnotation(self.routeInfo.annotation, animated: true)
                    
                }, completion: { (status) in
                    
                })
        }
        
    }
    
    @IBAction func directionAction(sender: UIButton){
        
        if UIApplication.shared.canOpenURL(URL.init(string: "comgooglemaps://")!) {
            
            let directionURL = URL.init(string: "comgooglemaps://?saddr=&daddr=\(routeInfo.destination.latitude),\(routeInfo.destination.latitude)&directionsmode=driving")!
            
            UIApplication.shared.open(directionURL)
        }else{
            self.openMapsAppWithDirections(to: routeInfo.destination, destinationName: routeInfo.address)
        }
        
    }
    
    func openMapsAppWithDirections(to coordinate: CLLocationCoordinate2D, destinationName name: String) {
      let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
      let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
      let mapItem = MKMapItem(placemark: placemark)
      mapItem.name = name // Provide the name of the destination in the To: field
        mapItem.openInMaps(launchOptions: options)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
