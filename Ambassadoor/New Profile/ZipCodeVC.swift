//
//  ZipCodeVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/4/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import MapKit

protocol EnterZipCode {
	func ZipCodeEntered(zipCode: String?)
}

class ZipCodeVC: UIViewController, MKMapViewDelegate {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var zipField: UITextField!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var cancelButtonView: ShadowView!
	
	var delegate: EnterZipCode?
	var currentquery: String?
	
	var noCancel = false
    
    var zipCode: String = ""
	
	override func viewDidLoad() {
        super.viewDidLoad()
		cancelButtonView.isHidden = noCancel
		zipField.text = zipToPass
		updateZip()
    }
	
	var zipToPass = ""
    
    /// Fetch zipcode information from third party service
    /// - Parameter code: Send Zipcode Value
	func TownToZip(code: String) {
		GetTownName(zipCode: code) { (zipCodeInfo, zipCode) in
			DispatchQueue.main.async {
				if self.currentquery == zipCode {
					guard let zipCodeInfo = zipCodeInfo else { return }
					self.nameLabel.text = zipCodeInfo.CityAndStateName
					let noLocation = CLLocationCoordinate2DMake(CLLocationDegrees(exactly: zipCodeInfo.geo_latitude) ?? 0, CLLocationDegrees(exactly: zipCodeInfo.geo_longitude) ?? 0)
					let viewRegion = MKCoordinateRegion(center: noLocation, latitudinalMeters: 2500, longitudinalMeters: 2500)
					self.mapView.setRegion(viewRegion, animated: true)
					self.zipField.resignFirstResponder()
				}
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
        defaultRegion = mapView.region
	}
	
    var defaultRegion: MKCoordinateRegion?
	
	func showDefaultMapArea() {
        if let region = defaultRegion {
            mapView.setRegion(region, animated: true)
        }
    }
	
	@IBAction func textChanged(_ sender: Any) {
		
		zipField.text = zipField.text!.replacingOccurrences(of: " ", with: "")
		updateZip()
		
	}
	
	func updateZip() {
		enterbutton.isEnabled = 7 > zipField.text!.count && zipField.text!.count > 4
		
		//if zip length = 4 then get all possible results = 10001, 10002, 10003, etc. and put them in RAM.
		if zipField.text!.count == 4 {
			for x: Int in 0...9 {
				GetTownName(zipCode: zipField.text! + String(x)) { (data, str) in
					
				}
			}
		}
			//if zip length is 5 or 6, display city&state on label depending on the ZIP code inputted by the user.
			
		if zipField.text?.count == 5 || zipField.text?.count == 6 {
			currentquery = zipField.text!
			TownToZip(code: zipField.text!)
		} else {
			if nameLabel.text != "" {
				nameLabel.text = ""
				showDefaultMapArea()
			}
		}
	}
	
	@IBOutlet weak var enterbutton: UIButton!
	
	func done() {
		delegate?.ZipCodeEntered(zipCode: zipField.text!)
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func DoneClicked(_ sender: Any) {
		done()
	}
	
	@IBAction func entered(_ sender: Any) {
		done()
	}
	
	@IBAction func cancel(_ sender: Any) {
		delegate?.ZipCodeEntered(zipCode: nil)
		dismiss(animated: true, completion: nil)
	}
	
}
