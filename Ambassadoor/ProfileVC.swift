//
//  ProfileVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController, EnterZipCode {
	
	func ZipCodeEntered(zipCode: String?) {
		//zipppi.setTitle(zipCode, for: .normal)
	}
	
	//performSegue(withIdentifier: "toZip", sender: self)
	
    override func viewDidLoad() {
        super.viewDidLoad()
		if let profilepic = Yourself.profilePicURL {
			ProfilePicture.downloadAndSetImage(profilepic, isCircle: true)
		} else {
			ProfilePicture.image = defaultImage
		}
		tierBox.layer.cornerRadius = tierBox.bounds.height / 2
		tierLabel.text = String(GetTierFromFollowerCount(FollowerCount: Yourself.followerCount) ?? 0)
		
		followerCount.text = CompressNumber(number: Yourself.followerCount)
		averageLikes.text = Yourself.averageLikes == nil ? "N/A" : CompressNumber(number: Yourself.averageLikes!)
		
		tierBox.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "tiergrad")!)
		
    }
    
	@IBOutlet weak var followerCount: UILabel!
	@IBOutlet weak var tierBox: UIView!
	@IBOutlet weak var ProfilePicture: UIImageView!
	@IBOutlet weak var averageLikes: UILabel!
	@IBOutlet weak var tierLabel: UILabel!
	
	@IBAction func chooseProfesssion(_ sender: Any) {
		//performSegue(withIdentifier: "toPicker", sender: self)
	}
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		if let destination = segue.destination as? CategoryPicker {
//			destination.SetupPicker(originalCategory: curcat) { (cat) in
//				self.ThisButton.setTitle(cat.rawValue, for: .normal)
//				self.curcat = cat
//			}
//		}
//		if let destination = segue.destination as? ZipCodeVC {
//			//destination.delegate = self
//		}
    }

}
