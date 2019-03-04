//
//  ProfileVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
	
	@IBOutlet weak var ThisButton: UIButton!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
	@IBAction func chooseProfesssion(_ sender: Any) {
		performSegue(withIdentifier: "toPicker", sender: self)
	}
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? CategoryPicker {
			destination.SetupPicker(originalCategory: nil) { (cat) in
				self.ThisButton.setTitle(cat?.rawValue, for: .normal)
			}
		}
    }

}
