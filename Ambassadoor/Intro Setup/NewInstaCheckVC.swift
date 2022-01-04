//
//  NewInstaCheckVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 28/07/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewInstaCheckVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /// Segue to business type page if user has a instagram account.
    /// - Parameter sender: UIButton referrance
    @IBAction func toSegueAction(sender: UIButton){
        self.performSegue(withIdentifier: "toInstatypeSegue", sender: self)
    }
    
    /// Show allert if user does not have an instagram account
    /// - Parameter sender: UIButton referrance
	@IBAction func doesntHaveInsta(_ sender: Any) {
		showStandardAlertDialog(title: "Instagram Required", msg: "To continue, setup an Instagram account.", handler: nil)
	}

}

