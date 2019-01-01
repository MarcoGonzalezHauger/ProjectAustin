//
//  ViewController.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/18/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelnace, LLC.
//

import UIKit

class AmbassadoorTopLabel: UILabel {
	
	override func awakeFromNib() {
		self.textColor = UIColor(red: 255/255, green: 121/255, blue: 8/255, alpha: 1)
		self.text = "Project nil?"
	}
	
}

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
	}


}

