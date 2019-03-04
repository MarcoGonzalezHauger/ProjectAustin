//
//  VerifedVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/5/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class VerifedVC: UIViewController {

	var delegate: ConfirmationReturned?
	@IBOutlet weak var receedButton: UIButton!
	@IBOutlet weak var usernameLabel: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		usernameLabel.text = "@" + Yourself!.username
	}
	
	@IBAction func proceed(_ sender: Any) {
		self.dismiss(animated: false) {
			self.delegate?.dismissed(success: true)
		}
	}
	
	@IBAction func notme(_ sender: Any) {
		self.dismiss(animated: false) {
			self.delegate?.dismissed(success: false)
		}
	}
	
}
