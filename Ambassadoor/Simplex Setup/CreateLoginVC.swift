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
	case passwordContainsAmbassadoor //Password contains the phrase Ambassadoor.
	case passNoMatch //Password didn't match.
}

class CreateLoginVC: UIViewController {

	@IBOutlet weak var emailText: UITextField!
	@IBOutlet weak var passwordText: UITextField!
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var proceedButton: UIButton!
	@IBOutlet weak var proceedView: UIView!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var confirmPass: UITextField!
	
    var userEmail: String = ""
	
	override func viewDidLoad() {
        super.viewDidLoad()
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
		infoLabel.text = defaultText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.proceedButton.isEnabled = true
        self.proceedButton.setTitle("Proceed", for: .normal)
    }
    
	@IBAction func confirmNext(_ sender: Any) {
		confirmPass.becomeFirstResponder()
	}
	@IBAction func Next(_ sender: Any) {
		passwordText.becomeFirstResponder()
	}
	@IBAction func PasswordNext(_ sender: Any) {
		if proceedButton.isEnabled {
            emailText.resignFirstResponder()
			passwordText.resignFirstResponder()
            confirmPass.resignFirstResponder()
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
		
		if passwordText.text == confirmPass.text {
			
			if emailText.text?.count != 0{
				
				print("emailLowercase=",emailText.text!.lowercased())
				
				if isValidEmail(emailStr: emailText.text!){
					
					if passwordText.text?.count != 0 {
						
						let complexity = isMeetingComplexity(password: passwordText.text!)
						
						if complexity == 0 {
							
							checkIfEmailExist(email: emailText.text!.lowercased()) { (isExist) in
								
								if isExist{
									self.AvaliabilityFailed(reason: .emailExists)
								}else{
									self.AvaliabilitySuccess()
								}
                                
							}
						}
						else if complexity == 1 {
							AvaliabilityFailed(reason: .weakPassword)
						}
							
						else if complexity == 2 {
							AvaliabilityFailed(reason: .passwordContainsAmbassadoor)
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
			
		} else {
			AvaliabilityFailed(reason: .passNoMatch)
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
//		UIView.animate(withDuration: 0.25) {
//			self.proceedView.alpha = 0
//			self.emailText.alpha = 0
//			self.passwordText.alpha = 0
//			self.backButton.alpha = 0
//			self.confirmPass.alpha = 0
//		}
//
//		infoLabel.textColor = .systemGreen
//		infoLabel.font = UIFont.systemFont(ofSize: 19, weight: .heavy)
//		self.view.endEditing(true)
//		SetLabelText(text: "Login Avaliable", animated: true)
        NewAccount.email = emailText.text!.lowercased()
        NewAccount.password = passwordText.text!.md5()
//		DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
//			UIView.animate(withDuration: 0.25) {
//				self.infoLabel.alpha = 0
//			}
//		}
//		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//			//self.navigationController?.popViewController(animated: true)
//            self.resentOTPtoMail(email: NewAccount.email)
//		}
        
        self.resentOTPtoMail(email: NewAccount.email)
        
	}
    
    func resentOTPtoMail(email: String) {
        
        let params = ["email":email,"username":"rammmm"] as [String: AnyObject]
        APIManager.shared.sendOTPtoUserServiceForConfirmEmail(params: params) { (status, error, data) in
            
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print("dataString=",dataString as Any)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                
                _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if let code = json!["code"] as? Int {
                    
                    if code == 200 {
                    let otpCode = json!["otp"] as! Int
                        
                        self.userEmail = email
                        
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "fromCreateLogin", sender: otpCode)
                        }
                        
                    }else{
                        
                    }
                }
                
            }catch _ {
                
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
	
	func AvaliabilityFailed(reason: AccountNameProblem) {
		proceedButton.setTitle("Proceed", for: .normal)
		MakeShake(viewToShake: proceedButton)
		
		SetLabelText(text: GetLabelTextFromIssue(reason: reason), animated: false)
		infoLabel.textColor = .red
		
		if reason == .passwordContainsAmbassadoor {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				self.performSegue(withIdentifier: "toOops", sender: self)
			}
		}
		
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
		case .passwordContainsAmbassadoor:
			return "Password Very Insecure!"
		case .passNoMatch:
			return "Passwords Don't Match"
		default:
			return "Failed"
		}
	}
	
	@IBAction func backButtonPressed(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromCreateLogin"{
            let viewController = segue.destination as! VerifyEmailVC
            viewController.otp = sender as! Int
            viewController.email = NewAccount.email
        }
    }
    
}
