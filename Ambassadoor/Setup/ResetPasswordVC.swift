//
//  ResetPasswordVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/11/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

enum passwordResetProblem {
	case noConnection //iPhone not connected to the internet
	case noAccount //account for that email does not exist
	case noEmail //user did not enter anything in the textfield
	case badEmailFormat //email format is invalid.
}

class ResetPasswordVC: UIViewController {

	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var EmailText: UITextField!
	@IBOutlet weak var resetPasswordButton: UIButton!
	@IBOutlet weak var resetPasswordView: ShadowView!
	@IBOutlet weak var closeButton: UIButton!
	
	var dontAnimate = false
	var passwordWasReset = false
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(_ animated: Bool) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			if !self.dontAnimate {
				self.SetLabelText(text: "Reset Password for Account", animated: true)
			}
		}
	}
	
	@IBAction func textChanged(_ sender: Any) {
		if let sender = sender as? UITextField {
			if sender.text!.contains(" ") {
				sender.text = sender.text?.replacingOccurrences(of: " ", with: "")
			}
		}
	}
	
	func ResetPasswordNow() {
		dontAnimate = true
		resetPasswordButton.isEnabled = false
		resetPasswordButton.setTitle("Resetting...", for: .normal)
		
		//[RAM] pretty much the same as the signinVC and CreateLoginVC.
		//Functions are: PasswordResetSuccess()
		//and: PasswordResetFailed(reason: passwordResetPorblem)
		PasswordResetSuccess()
	}
	
	@IBAction func closeButton(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func resetPassword(_ sender: Any) {
		if passwordWasReset {
			dismiss(animated: true, completion: nil)
		} else {
			ResetPasswordNow()
		}
	}
	
	@IBAction func GoButtonPressed(_ sender: Any) {
		self.view.endEditing(true)
		ResetPasswordNow()
	}
	
	let defaultText = "Reset Password for Account"
	
	func PasswordResetSuccess() {
		passwordWasReset = true
		UIView.animate(withDuration: 0.5) {
			self.EmailText.alpha = 0
			self.closeButton.alpha = 0
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
			self.EmailText.isHidden = true
			self.closeButton.isHidden = true
		}
		infoLabel.textColor = .systemGreen
		SetLabelText(text: "Reset Link Sent", animated: true)
		resetPasswordButton.setTitle("Close", for: .normal)
		resetPasswordButton.isEnabled = true
	}
	
	func PasswordResetFailed(reason: passwordResetProblem) {
		resetPasswordButton.setTitle("Reset Password", for: .normal)
		MakeShake(viewToShake: resetPasswordView)
		
		SetLabelText(text: GetLabelTextFromIssue(reason: reason), animated: false)
		infoLabel.textColor = .red
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			UIView.transition(with: self.infoLabel, duration: 2, options: .transitionCrossDissolve, animations: {
				self.infoLabel.textColor = GetForeColor()
			}, completion: nil)
			DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
				self.SetLabelText(text: self.defaultText, animated: true)
				self.resetPasswordButton.isEnabled = true
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
	
	func GetLabelTextFromIssue(reason: passwordResetProblem?) -> String {
		switch reason {
		case .noEmail:
			return "Failed: No Email"
		case .noConnection:
			return "No Internet Connection"
		case .badEmailFormat:
			return "Invalid Email"
		case .noAccount:
			return "No Account Uses That Email"
		default:
			return "Failed"
		}
	}
}
