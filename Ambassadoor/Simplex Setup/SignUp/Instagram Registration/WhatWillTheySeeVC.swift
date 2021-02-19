//
//  WhatWillTheySeeVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 9/8/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class WhatWillTheySeeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        connectICPageIndex = 1
    }
    
	@IBAction func CloseVC(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
}
