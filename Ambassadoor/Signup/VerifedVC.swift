//
//  VerifedVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/5/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import UIKit

class VerifedVC: UIViewController, ConfirmationReturned {

	var delegate: ConfirmationReturned?
    var user: User?
	@IBOutlet weak var receedButton: UIButton!
	@IBOutlet weak var usernameLabel: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		usernameLabel.text = "@" + Yourself!.username
	}
	
	@IBAction func proceed(_ sender: Any) {
//		self.dismiss(animated: false) {
//			self.delegate?.dismissed(success: true)
//		}
        
        self.performSegue(withIdentifier: "verifyToOtherVCSegue", sender: user)
        
	}
	
	@IBAction func notme(_ sender: Any) {
		self.dismiss(animated: false) {
			attemptedLogOut = true
			self.delegate?.dismissed(success: false)
		}
	}
	
    func dismissed(success: Bool!) {
        self.dismiss(animated: false) {
            self.delegate?.dismissed(success: true)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? OtherInfoVC {
            if segue.identifier == "verifyToOtherVCSegue" {
                destination.delegate = self
                destination.userfinal = sender as? User
            }
        }
    }
}
