//
//  SignUpVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/28/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelnace, LLC.
//

import UIKit

class SignUpVC: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var heyLabel: UILabel!
	@IBOutlet weak var usernameField: UITextField!
	@IBOutlet weak var signupButton: UIButton!
	@IBOutlet weak var loginButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()

    }
	
	@IBAction func signUp(_ sender: Any) {
		debugPrint("going to sign up")
		//Brings you to a sign up VC
	}
	
	@IBAction func LogIn(_ sender: Any) {
		debugPrint("going to log in")
		//Log in will take you to a login VC.
	}
	
	@IBAction func DoneTypingUsername(_ sender: Any) {
		self.view.endEditing(true)
	}
	
	@IBAction func EditingDidBegin(_ sender: Any) {
		if usernameField.text?.hasPrefix("@") == false {
			usernameField.text = "@"
		}
	}
	
	@IBAction func usernameChanged(_ sender: Any) {
		if usernameField.text?.hasPrefix("@") == false {
			usernameField.text = "@" + (usernameField.text ?? "").replacingOccurrences(of: "@", with: "", options: .literal, range: nil)
		}
		
		usernameField.text = (usernameField.text ?? "").replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
	}
	
}
