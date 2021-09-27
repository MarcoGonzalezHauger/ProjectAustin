//
//  NewWelcomeVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 28/07/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewWelcomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func openAppStore(sender: UIButton){
        businessInstead()
    }
	
    
    @IBAction func toSegueAction(sender: UIButton){
        self.performSegue(withIdentifier: "toInstaCheckSegue", sender: self)
    }

	func businessInstead() {
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.getNotificationSettings { (settings) in
			DispatchQueue.main.async {
				if settings.authorizationStatus == .authorized {
					self.wrongAppNotification()
				}
				OpenAppStoreID(id: "amassadoorbusiness/id1483207154")
			}
		}
	}
	func wrongAppNotification() {
		
		let notificationCenter = UNUserNotificationCenter.current()
		let content = UNMutableNotificationContent()
		
		content.title = "Business? Wrong App"
		content.body = "Download Ambassadoor Business Here"
		content.sound = nil
		content.badge = nil
		
	
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.2, repeats: false)
		let identifier = "AMB_wrongApp"
		if let attachment = UNNotificationAttachment.make(identifier: "businessLogo", image: UIImage.init(named: "BusinessIcon")!, options: nil) {
			content.attachments = [attachment]
		}
		
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
	
		notificationCenter.add(request) { (error) in
			if let error = error {
				print("Error \(error.localizedDescription)")
			}
		}
	}

}
