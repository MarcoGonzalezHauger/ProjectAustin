//
//  NewPoolOfferPostViewer.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/1/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import CoreLocation

class NewPoolOfferPostViewer: UIViewController, CLLocationManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
		updateContents()
    }
	
	@IBOutlet weak var foreImage: UIImageView!
	@IBOutlet weak var backImage: UIImageView!
	
	@IBOutlet weak var indexLabel: UILabel!
	
	@IBOutlet weak var locationsView: ShadowView!
	@IBOutlet weak var instructions: UILabel!
	@IBOutlet weak var captionLabel: UILabel!
    
    var locationManager: CLLocationManager?
	
	var thisPoolOffer: PoolOffer!
	var index: Int = 0
	
	@IBAction func backPressed(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	} 
	
	func updateContents() {
        let loc = thisPoolOffer.BasicBusiness()
        print(loc!.locations)
		locationsView.isHidden = loc!.locations.count == 0
		foreImage.downloadAndSetImage(thisPoolOffer.BasicBusiness()!.logoUrl)
		backImage.downloadAndSetImage(thisPoolOffer.BasicBusiness()!.logoUrl)
		indexLabel.text = "\(index + 1)"
		instructions.text = thisPoolOffer.draftPosts[index].instructions
		var allItems: [String] = []
		for i in thisPoolOffer.draftPosts[index].requiredKeywords {
			allItems.append(" - " + i)
		}
        if !thisPoolOffer.draftPosts[index].requiredHastags.contains("ad") && !thisPoolOffer.draftPosts[index].requiredHastags.contains("#ad") {
            thisPoolOffer.draftPosts[index].requiredHastags.append("ad")
        }
		for i in thisPoolOffer.draftPosts[index].requiredHastags {
			allItems.append(" - #" + i)
		}
		captionLabel.text = allItems.joined(separator: "\n")
	}
    
    @IBAction func viewLocation(sender: UIButton){
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.requestAlwaysAuthorization()
        
        
        //
    }
    
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
                
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            if let viewNav = self.presentedViewController as? StandardNC{
                if let view = viewNav.viewControllers.first as? MapVC{
                    view.viewDidLoad()
                }
                
            }else{
                self.performSegue(withIdentifier: "fromPosttoMap", sender: true)
            }
            
        case .denied:
            
//            self.showStandardAlertDialog(title: "Alert", msg: "Please enable your location permission") { (alert) in
//                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
//            }
            
            if let viewNav = self.presentedViewController as? StandardNC{
                if let view = viewNav.viewControllers.first as? MapVC{
                    view.viewDidLoad()
                }
            }else{
                self.performSegue(withIdentifier: "fromPosttoMap", sender: true)
            }
                        
        default:
            print("no one")
        }
                
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewNav = segue.destination as? StandardNC{
            
            if let view = viewNav.viewControllers.first as? MapVC{
                if let locations = thisPoolOffer.BasicBusiness()?.locations{
                    view.locations = locations
                    view.isCurrentLocation = sender as! Bool
                }
            }
            
        }
    }

}
