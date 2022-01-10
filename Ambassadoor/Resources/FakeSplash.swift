//
//  FakeSplash.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 10/24/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol DismissNow {
	func dismissNow()
}

class FakeSplash: UIViewController, DismissNow {
    
    
    /// Dismiss current viewcontroller
	func dismissNow() {
		self.dismiss(animated: false, completion: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
