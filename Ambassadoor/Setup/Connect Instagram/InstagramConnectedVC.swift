//
//  InstagramConnectedVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/12/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class InstagramConnectedVC: UIViewController {

	var delegate: VerificationReturned?
	
	@IBOutlet weak var usernameText: UILabel!
	override func viewDidLoad() {
		super.viewDidLoad()
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
		usernameText.text = "@" + thisName
    }
	
	@IBAction func ThatsNotMe(_ sender: Any) {
		delegate?.ThatsNotMe()
		dismiss(animated: true, completion: nil)
	}
	
	var thisName: String!
	
	func SetName(name: String) {
		thisName = name
	}
	
	@IBAction func Proceed(_ sender: Any) {
		dismiss(animated: true) {
			self.delegate?.DonePressed()
		}
	}
	
}
