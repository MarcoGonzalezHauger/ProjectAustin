//
//  SignUpVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/28/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

protocol ConfirmationReturned {
	func dismissed(success: Bool!) -> ()
}

import UIKit
import Firebase

class SignUpVC: UIViewController, UITextFieldDelegate, ConfirmationReturned {
	
	func dismissed(success: Bool!) {
		self.dismiss(animated: true, completion: nil)
		debugPrint("SignUpVC has been dismissed.")
	}
	
	@IBOutlet weak var heyLabel: UILabel!
	
	var code: String?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		let ref = Database.database().reference().child("LatestAppVersion").child("BetaCode")
		 ref.observeSingleEvent(of: .value, with: { (snapshot) in
			
			if let thisCode = snapshot.value as? String {
				self.code = thisCode
			}
			
		})
    }
	
	@IBAction func signUp(_ sender: Any) {
		debugPrint("going to sign up")
		//Brings you to a sign up VC
        API.instaLogout()

		SigningUp()
	}
    
    @IBAction func goToBusinessApp(_ sender: Any) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app"),
            UIApplication.shared.canOpenURL(url){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
	
	func SigningUp() {
		if let code = code {
			if code != "" {
				let alert = UIAlertController(title: "Beta code required", message: "A Beta code is required to sign up at this time.", preferredStyle: .alert)
				alert.addTextField { (textField) in
					textField.text = ""
				}
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
					let codec = alert?.textFields![0].text ?? ""
					if codec == code {
						self.performSegue(withIdentifier: "InstagramSegue", sender: self)
					} else {
						let alert = UIAlertController(title: "Incorrect Code", message: "The beta code you entered was not correct.", preferredStyle: .alert)
						alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
						self.present(alert, animated: true)
					}
				}))
				self.present(alert, animated: true, completion: nil)
			} else {
				performSegue(withIdentifier: "InstagramSegue", sender: self)
			}
			
		}
	}
    
    
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? InstagramVC {
            dest.delegate = self
        }
		debugPrint((segue.identifier ?? "a segue") + " has been prepared for.")
	}
	
}
