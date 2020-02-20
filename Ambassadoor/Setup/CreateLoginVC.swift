//
//  CreateLoginVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/10/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

enum AccountNameProblem {
	case emailExists //already an account using that email
	case noEmail //user didn't enter email
	case noPassword //user didn't enter a password
	case noConnection //the iPhone doesn't have internet connection
	case badEmailFormat //invalid email format
	case weakPassword //insecure password was used.
}

class CreateLoginVC: UIViewController {

	@IBOutlet weak var emailText: UITextField!
	@IBOutlet weak var passwordText: UITextField!
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var proceedButton: UIButton!
	@IBOutlet weak var proceedView: UIView!
	@IBOutlet weak var backButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
		infoLabel.text = defaultText
    }
	@IBAction func Next(_ sender: Any) {
		passwordText.becomeFirstResponder()
	}
	@IBAction func PasswordNext(_ sender: Any) {
		if proceedButton.isEnabled {
			passwordText.resignFirstResponder()
			CheckAccountAvaliability()
		}
	}
	
	let defaultText: String = "Choose an Email and Password"
	
	@IBAction func proceedButtonPressed(_ sender: Any) {
        CheckAccountAvaliability()
	}
	
	func CheckAccountAvaliability() {
        proceedButton.setTitle("Checking...", for: .normal)
        self.proceedButton.isEnabled = false
        
        if emailText.text?.count != 0{
            
            if isValidEmail(emailStr: emailText.text!){
                
                if passwordText.text?.count != 0 {
                    
                    checkIfEmailExist(email: emailText.text!) { (isExist) in
                        
                        if isExist{
                            self.AvaliabilityFailed(reason: .emailExists)
                        }else{
                            self.AvaliabilitySuccess()
                        }
                        
                    }
                    
                }else{
                    AvaliabilityFailed(reason: .noPassword)
                }
            }else{
                AvaliabilityFailed(reason: .badEmailFormat)
            }
        }else{
            AvaliabilityFailed(reason: .noEmail)
        }
		
		//[RAM] same as signinVC, code in all possible problems (found in the enum for AccountNameProblem)
		//If Failed, call AvaliabilityFailed with the error parameter
		//If success, call AvaliabilitySuccess
		//REMEMBER: ON THIS VC, You are only checking for AVALIABILITY, you are NOT actually making the account.
	}
	
	@IBAction func cancelTap(_ sender: Any) {
		self.view.endEditing(true)
	}
	
	func AvaliabilitySuccess() {
		UIView.animate(withDuration: 0.25) {
			self.proceedView.alpha = 0
			self.emailText.alpha = 0
			self.passwordText.alpha = 0
			self.backButton.alpha = 0
		}
		
		infoLabel.textColor = .systemGreen
		infoLabel.font = UIFont.systemFont(ofSize: 19, weight: .heavy)
		SetLabelText(text: "Login Avaliable", animated: true)
		NewAccount.email = emailText.text!
        NewAccount.password = passwordText.text!.md5()
		accInfoUpdate()
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
			UIView.animate(withDuration: 0.25) {
				self.infoLabel.alpha = 0
			}
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			self.navigationController?.popViewController(animated: true)
		}
	}
	
	@IBAction func textChanged(_ sender: Any) {
		if let sender = sender as? UITextField {
			if sender.text!.contains(" ") {
				sender.text = sender.text?.replacingOccurrences(of: " ", with: "")
			}
		}
	}
	
	func AvaliabilityFailed(reason: AccountNameProblem) {
		proceedButton.setTitle("Proceed", for: .normal)
		MakeShake(viewToShake: proceedButton)
		
		SetLabelText(text: GetLabelTextFromIssue(reason: reason), animated: false)
		infoLabel.textColor = .red
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			UIView.transition(with: self.infoLabel, duration: 2, options: .transitionCrossDissolve, animations: {
				self.infoLabel.textColor = GetForeColor()
			}, completion: nil)
			DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
				self.SetLabelText(text: self.defaultText, animated: true)
				self.proceedButton.isEnabled = true
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
			self.infoLabel.text = textstring
			animation.duration = 0.25
			self.infoLabel.layer.add(animation, forKey: CATransitionType.push.rawValue)
		} else {
			infoLabel.text = textstring
		}
	}
	
	func GetLabelTextFromIssue(reason: AccountNameProblem?) -> String {
		switch reason {
		case .noEmail:
			return "Failed: No Email"
		case .noPassword:
			return "Failed: No Password"
		case .noConnection:
			return "No Internet Connection"
		case .emailExists:
			return "Email Already in Use"
		case .badEmailFormat:
			return "Invalid Email"
		case .weakPassword:
			return "Password is Too Weak"
		default:
			return "Failed"
		}
	}
	
	@IBAction func backButtonPressed(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
}
