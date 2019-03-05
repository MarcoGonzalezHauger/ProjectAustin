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
		zipppi.setTitle(zipCode, for: .normal)
	}
	
	
	@IBOutlet weak var zipppi: UIButton!
	@IBOutlet weak var ThisButton: UIButton!
	
	@IBAction func Blablabla(_ sender: Any) {
		performSegue(withIdentifier: "toZip", sender: self)
	}
	
	var curcat: Category?
	
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
	@IBAction func chooseProfesssion(_ sender: Any) {
		performSegue(withIdentifier: "toPicker", sender: self)
	}
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? CategoryPicker {
			destination.SetupPicker(originalCategory: curcat) { (cat) in
				self.ThisButton.setTitle(cat.rawValue, for: .normal)
				self.curcat = cat
			}
		}
		if let destination = segue.destination as? ZipCodeVC {
			destination.delegate = self
		}
    }

}
