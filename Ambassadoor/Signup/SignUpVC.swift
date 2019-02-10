//
//  SignUpVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/28/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

protocol ConfirmationReturned {
	func dismissed() -> ()
}

import UIKit

class SignUpVC: UIViewController, UITextFieldDelegate, ConfirmationReturned {
	
	func dismissed() {
		self.dismiss(animated: true, completion: nil)
		debugPrint("SignUpVC has been dismissed.")
	}

	@IBOutlet weak var heyLabel: UILabel!
	@IBOutlet weak var signupButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	@IBAction func signUp(_ sender: Any) {
		debugPrint("going to sign up")
		//Brings you to a sign up VC
		SigningUp()
	}
	
	func SigningUp() {
		debugPrint("going to preform segue.")
        performSegue(withIdentifier: "InstagramSegue", sender: self)
		debugPrint("preformed Segue.")
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? InstagramVC {
            dest.delegate = self
        }
		debugPrint((segue.identifier ?? "a segue") + " has been prepared for.")
	}
	
}
