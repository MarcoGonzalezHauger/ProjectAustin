//
//  WithdrawVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/28/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import UIKit

class WithdrawVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		for x : ShadowView in options {
			x.ShadowOpacity = 0.2
			x.ShadowRadius = 3.5
		}
    }
    
	@IBOutlet var options: [ShadowView]!
	
	@IBAction func dismiss(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
}
