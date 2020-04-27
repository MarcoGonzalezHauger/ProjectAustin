//
//  AccountInUseVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/12/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class AccountInUseVC: UIViewController {
	
	var delegate: VerificationReturned?
	@IBOutlet weak var emailLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		delegate?.ThatsNotMe()
		emailLabel.text = emailToPresent
    }
    
	var emailToPresent: String!
	
	func SetEmail(email: String) {
		emailToPresent = email
	}
	
	@IBAction func TryDiffLogin(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
}
