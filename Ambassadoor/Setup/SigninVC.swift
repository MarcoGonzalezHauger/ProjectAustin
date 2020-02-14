//
//  SigninVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/7/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

enum LoginProblem {
	case noEmail //no email.
	case noPassword //no password.
	case noConnection //no connection.
	case userDoesNotExist //the email entered doesn't exist
	case passwordInvalid //password invalid, but account with email DOES exist.
	case badEmailFormat //email wasn't valid.
}

class SigninVC: UIViewController {
	
	var delegate: AutoDimiss?
	
	@IBOutlet weak var emailText: UITextField!
	@IBOutlet weak var passwordText: UITextField!
	@IBOutlet weak var signinButton: BoldButton!
	@IBOutlet weak var authLabel: UILabel!
	@IBOutlet weak var ForgotPasswordButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	@IBAction func closeSignUp(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func nextField(_ sender: Any) {
		passwordText.becomeFirstResponder()
	}
	
	@IBAction func tappedOut(_ sender: Any) {
		self.view.endEditing(true)
	}
	
	@IBAction func SignInFromKeyboard(_ sender: Any) {
		passwordText.resignFirstResponder()
		if signinButton.isEnabled {
			DisableSignIn()
			SignInNow()
		}
	}
	
	@IBAction func SignInFrombutton(_ sender: Any) {
		DisableSignIn()
		SignInNow()
	}
	
	func SignInNow() {
		LoginFailed(reason: .passwordInvalid) //[RAM] THIS IS FOR TESTING PURPOSES, REMOVE THIS.
		
		if false {
			//[RAM]
			
			
			LoginSuccessful() //If the login is valid, use this function to go to HomeVC.
			LoginFailed(reason: .badEmailFormat) //If login failed, use this function which will tell the user why their login failed
			//Please program cases for all possible problems found in "LoginProblem"
			//For example, if the user didn't have an email use:
			LoginFailed(reason: .noEmail)
		}
		
	}
	
	
	
	
	
	
	
	
	//ANIMATIONS BELOW
	
	
	
	
	func DisableSignIn() {
		signinButton.isEnabled = false
		signinButton.Text = "Signing In..."
	}
	
	func LoginSuccessful() {
		signinButton.Text = "Signed In"
		self.authLabel.text = "Welcome Back"
		self.authLabel.textColor = .systemGreen
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			self.delegate?.DismissNow()
		}
	}
	
	@IBAction func textChanged(_ sender: Any) {
		if let sender = sender as? UITextField {
			if sender.text!.contains(" ") {
				sender.text = sender.text?.replacingOccurrences(of: " ", with: "")
			}
		}
	}
	
	func LoginFailed(reason: LoginProblem) {
		signinButton.Text = "Sign In"
		MakeShake(viewToShake: signinButton)
		
		if reason == .passwordInvalid {
			ForgotPasswordButton.isHidden = false
		}
		
		SetLabelText(text: GetLabelTextFromIssue(reason: reason), animated: false)
		authLabel.textColor = .red
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			UIView.transition(with: self.authLabel, duration: 2, options: .transitionCrossDissolve, animations: {
				self.authLabel.textColor = GetForeColor()
			}, completion: nil)
			DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
				self.SetLabelText(text: "Authentication Required", animated: true)
				self.signinButton.isEnabled = true
			}
		}
	}
	
	func SetLabelText(text textstring: String, animated: Bool) {
		if animated {
			let animation: CATransition = CATransition()
			animation.timingFunction = CAMediaTimingFunction(name:
				CAMediaTimingFunctionName.easeInEaseOut)
			animation.type = CATransitionType.push
			animation.subtype = CATransitionSubtype.fromTop
			self.authLabel.text = textstring
			animation.duration = 0.25
			self.authLabel.layer.add(animation, forKey: CATransitionType.push.rawValue)
		} else {
			authLabel.text = textstring
		}
	}
	
	func GetLabelTextFromIssue(reason: LoginProblem?) -> String {
		switch reason {
		case .noEmail:
			return "Failed: No Email"
		case .noPassword:
			return "Failed: No Password"
		case .noConnection:
			return "No Internet Connection"
		case .userDoesNotExist:
			return "No Account For Email"
		case .passwordInvalid:
			return "Password Incorrect"
		case .badEmailFormat:
			return "Invalid Email"
		default:
			return "Authentication Failed"
		}
	}
}
