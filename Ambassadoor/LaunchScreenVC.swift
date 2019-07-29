//
//  LaunchScreenVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/12/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class LaunchScreenVC: UIViewController {

	@IBOutlet var thisView: UIView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		let colorTop = UIColor(red: 1, green: 108 / 255, blue: 30 / 255, alpha: 1.0).cgColor
		let colorBottom = UIColor(red: 1, green: 79 / 255, blue: 30 / 255, alpha: 1.0).cgColor
		
		let gl : CAGradientLayer = CAGradientLayer()
		gl.colors = [colorTop, colorBottom]
		gl.locations = [0.0, 1.0]
		thisView.layer.addSublayer(gl)
		
    }
	
}
