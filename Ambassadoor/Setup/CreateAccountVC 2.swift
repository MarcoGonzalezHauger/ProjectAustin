//
//  CreateAccountVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/7/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import UserNotifications
import NotificationCenter

class CreateStep: UITableViewCell {
	@IBOutlet weak var checkImage: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descLabel: UILabel!
	@IBOutlet weak var centerGuide: NSLayoutConstraint!
	func SetSubtitle(string: String) {
		descLabel.text = string
		centerGuide.constant = string == "" ? 0 : -8
	}
}

class CreateAccountVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NewAccountListener {
	
	func AccountUpdated(NewAccount: NewAccountInfo) {
		stepShelf.reloadData()
	}
	
	@IBOutlet weak var stepShelf: UITableView!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = stepShelf.dequeueReusableCell(withIdentifier: "nextStep") as! CreateStep
		switch indexPath.row {
		case 0:
			cell.titleLabel.text = "Create Login"
			cell.SetSubtitle(string: NewAccount.email)
		case 1:
			cell.titleLabel.text = "Connect Instagram"
			cell.SetSubtitle(string: NewAccount.instagramUsername)
		case 2:
			cell.titleLabel.text = "Enter Basic Information"
			cell.SetSubtitle(string: "")
		default:
			break
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		stepShelf.deselectRow(at: indexPath, animated: true)
		switch indexPath.row {
		case 0:
			performSegue(withIdentifier: "toCreateLogin", sender: self)
		default:
			break
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		NewAccountListeners.append(self)
		stepShelf.delegate = self
		stepShelf.dataSource = self
		//nextStep
    }

	@IBAction func cancelled(_ sender: Any) {
		self.navigationController?.dismiss(animated: true, completion: nil)
	}

	@IBAction func YesImABusiness(_ sender: Any) {
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.getNotificationSettings { (settings) in
			DispatchQueue.main.async {
				if settings.authorizationStatus != .authorized {
					let alert = UIAlertController(title: "Business? Wrong App", message: "Download Ambassadoor Business here", preferredStyle: UIAlertController.Style.alert)
					alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
					alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { (_) in
					OpenAppStoreID(id: "amassadoorbusiness/id1483207154")
					}))
					DispatchQueue.main.async {
						self.present(alert, animated: true, completion: nil)
					}
				} else {
					OpenAppStoreID(id: "amassadoorbusiness/id1483207154")
					self.wrongAppNotification()
				}
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
