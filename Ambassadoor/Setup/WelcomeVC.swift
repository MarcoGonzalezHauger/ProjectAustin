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
	func DismissNow()
}

class WelcomeVC: UIViewController, AutoDimiss {
	
	func DismissNow() {
		presentingViewController?.dismiss(animated: true, completion: nil)
	}

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
	
	@IBAction func signInClicked(_ sender: Any) {
		performSegue(withIdentifier: "toSignIn", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? SigninVC {
			destination.delegate = self
		}
	}
	
}
