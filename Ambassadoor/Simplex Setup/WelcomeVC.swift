//
//  WelcomeVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/7/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import UserNotifications
import NotificationCenter

protocol AutoDimiss {
    func DismissNow(sender: String)
}

class WelcomeVC: UIViewController, AutoDimiss {
    
    
    
    /// Dismiss current view controller
    /// - Parameter sender: identify controller to dismiss. pass welcome idetifier to AutoDimiss delegate method
    func DismissNow(sender: String) {
        
        if sender == "CreateAccount"{
           presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
           
           presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        self.delegate?.DismissNow(sender: "welcome")
	}
    
    var delegate: AutoDimiss?

    override func viewDidLoad() {
        super.viewDidLoad()
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
    }
	
	override func viewDidAppear(_ animated: Bool) {
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.requestAuthorization(options: [.alert, .badge]) { (_, _) in
			
		}
	}
    
    /// segue to sign in page.
    /// - Parameter sender: UIButton referrance.
	@IBAction func signInClicked(_ sender: Any) {
		performSegue(withIdentifier: "toSignIn", sender: self)
	}
    
    
    /// Segue to create account page.
    /// - Parameter sender: UIButton page.
    @IBAction func createAccountAction(_ sender: Any){
        performSegue(withIdentifier: "toNewCreateAccountStoryboard", sender: self)
    }
    
    /// Initialize NewAccount class
    /// - Parameters:
    ///   - segue: Storyboard segue
    ///   - sender: Any referrance
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? SigninVC {
			destination.delegate = self
		}
		if let destination = segue.destination as? CreateAccountVC {
            NewAccount = NewAccountInfo.init(email: "", password: "", categories: [], gender: "", zipCode: "", instagramAccountId: "", instagramUsername: "", authenticationToken: "", averageLikes: 0, followerCount: 0, id: "", instagramName: "", profilePicture: "", referralCode: "", dob: "", isForTesting: false, referredBy: "")
			destination.delegate = self
		}
        if let view = segue.destination as? WebViewVC {
            view.urlString = API.termsUrl
        }
	}
	
}
