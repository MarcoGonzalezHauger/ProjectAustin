//
//  SignUpConfirmationVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/31/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelnace, LLC.
//

import UIKit

class SignUpConfirmationVC: UIViewController {

	var delegate: ConfirmationReturned?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
	}
	
	@IBAction func proceed(_ sender: Any) {
		dismiss(animated: false, completion: delegate?.dismissed)
	}
	
}
