//
//  NotBusinessVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/16/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NotBusinessVC: UIViewController {
	
	//[RAM] I can not get the scroll view to work, can you take a look at it?
	
	var delegate: VerificationReturned?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		delegate?.ThatsNotMe()
		
    }
	@IBAction func closeButtonPressed(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
}
