//
//  basicInfoVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/13/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import MapKit

class basicInfoVC: UIViewController {

	@IBOutlet weak var zipText: UITextField!
	@IBOutlet weak var zipCodeTitle: UILabel!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var blurView: UIVisualEffectView!
	@IBOutlet weak var finishbottom: NSLayoutConstraint!
	@IBOutlet weak var finishButton: UIButton!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var genderSegment: UISegmentedControl!
	
	//[RAM] you don't have to do any code work here
	
	var categories: [String] = [] {
		didSet {
			if categories.count > 0 {
				categoryLabel.textColor = GetForeColor()
			} else {
				categoryLabel.textColor = .systemGray
			}
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

		finishbottom.constant = -120
		
		blurView.alpha = 0.5
		
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
	}
	
	func SetBottom(constant: CGFloat) {
		
		finishButton.isEnabled = constant > 0
				
		finishbottom.constant = constant
		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
		}
	}
	
	func checkForFinish() {
		let zipGood = zipText.text!.count == 5
		let catsGood = categories.count > 0
		if zipGood && catsGood {
			SetBottom(constant: 16)
			let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
			scrollView.setContentOffset(bottomOffset, animated: true)
		} else {
			SetBottom(constant: -120)
		}
	}
	
	@IBAction func endEdits(_ sender: Any) {
		self.view.endEditing(true)
	}
	
	@IBAction func finishedPressed(_ sender: Any) {
		NewAccount.categories = categories
		NewAccount.gender = GenderIndexToString(index: genderSegment.selectedSegmentIndex)
		NewAccount.zipCode = zipText.text!
		accInfoUpdate()
		navigationController?.popViewController(animated: true)
	}
	
	func GenderIndexToString(index: Int) -> String {
		switch index {
		case 0:
			return "Male"
		case 1:
			return "Female"
		case 2:
			return "Other"
		default:
			return "Other"
		}
	}
	
	@IBAction func cancelPressed(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func pickCategories(_ sender: Any) {
		performSegue(withIdentifier: "toPicker", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? CategoryPicker {
			destination.SetupPicker(originalCategories: categories) { (cat) in
				self.categories = cat
				self.checkForFinish()
				var labeltext = ""
				for s in cat {
					labeltext += s + "\n"
				}
				self.categoryLabel.text = String(labeltext.dropLast())
				
			}
		}
	}
	
	@IBAction func zipCodeChanged(_ sender: Any) {
		let zipCode = zipText.text!
		if zipCode.count == 5 {
			GetTownName(zipCode: zipCode) { (zipCodeInfo, zip) in
				guard let zipCodeInfo = zipCodeInfo else { return }
                DispatchQueue.main.async {
					AnimateLabelText(label: self.zipCodeTitle, text: zipCodeInfo.CityAndStateName)
                    let noLocation = CLLocationCoordinate2DMake(CLLocationDegrees(exactly: zipCodeInfo.geo_latitude) ?? 0, CLLocationDegrees(exactly: zipCodeInfo.geo_longitude) ?? 0)
                    let viewRegion = MKCoordinateRegion(center: noLocation, latitudinalMeters: 1500, longitudinalMeters: 1500)
                    self.mapView.setRegion(viewRegion, animated: true)
                    self.zipText.resignFirstResponder()
                }
			}
		} else {
			self.zipCodeTitle.text = "Zip Code (USA)"
		}
		checkForFinish()
	}
	
}
