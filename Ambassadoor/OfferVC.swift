//
//  OfferVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/23/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit
import UserNotifications
//Preview post when on offerVC.

class PreviewPostCell: UITableViewCell {
	
	//simple outlets.
	@IBOutlet weak var PostTypeLabel: UILabel!
	@IBOutlet weak var isCompleted: UIImageView!
	
}

class OfferVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SyncTimerDelegate {
	
	func Tick() {
		CheckExperation()
	}
	
	func CheckExperation() {
		if ThisOffer.isAccepted == false {
			expirationView.isHidden = false
			if ThisOffer.isExpired {
				expirationLabel.text = "Expired"
				if !acceptButtonView.isHidden {
					acceptButtonView.isHidden = true
				}
				//dismiss(animated: true, completion: nil)
			} else {
				var desiredText: String = ""
				let i : Double = ThisOffer.expiredate.timeIntervalSinceNow
				if i >= 604800 {
					desiredText = "Expires on "
				} else {
					desiredText = "Expires in "
				}
				let answer: String? = DateToLetterCountdown(date: ThisOffer.expiredate)
				if let answer = answer {
					desiredText += answer
				} else {
					desiredText = "Expired"
					acceptButtonView.isHidden = true
				}
				expirationLabel.text = desiredText
				
				if i <= 3600 {
					expirationView.layer.borderColor = UIColor.init(red: 255/255, green: 59/255, blue: 48/255, alpha: 1).cgColor
					expirationLabel.textColor = UIColor.init(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
				} else {
					expirationView.layer.borderColor = UIColor.black.cgColor
					expirationLabel.textColor = UIColor.black
				}
			}
		} else {
			expirationView.isHidden = true
		}
	}
	
	//Big green accept button at the bottom of the screen.
	@IBOutlet weak var acceptButton: UIButton!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//Simple tableView stuff.
		return ThisOffer.posts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell : PreviewPostCell = shelf.dequeueReusableCell(withIdentifier: "PostPreviewCell") as! PreviewPostCell
		
		//Set label for cell to type of post (Function from Savvy.swift)
		cell.PostTypeLabel.text = PostTypeToText(posttype: ThisOffer.posts[indexPath.row].PostType)
		
		//Making sure the check mark only appears if the offer is accepted, and later shows different checks depedning on if it's set or not.
		if ThisOffer.isAccepted == false {
			cell.isCompleted.isHidden = true
		} else {
			
			//if post is confirmed, show corresponding check mark.
			cell.isCompleted.image = ThisOffer.posts[indexPath.row].isConfirmed ? UIImage(named: "check_fill") : UIImage(named: "check")
		}
		return cell
	}
	
	@IBOutlet weak var shelfheight: NSLayoutConstraint!
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 45
	}
	
	
	//Post that the View Post VC will give you. Used in prepare for segue.
	var posttosend : Post!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case "toPost":
			if let destination = segue.destination as? ViewPostVC {
				destination.ThisPost = posttosend
				destination.companystring = ThisOffer.company.name
			}
		case "toCompany":
			if let destination = segue.destination as? CompanyVC {
				destination.thisCompany = ThisOffer.company
			}
		default: break
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		posttosend = ThisOffer.posts[indexPath.row]
		performSegue(withIdentifier: "toPost", sender: self)
		tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
	}
	
	//This VC makes a nice panel that pops up to give you details about an offer BEFORE you accept it.
	
	@IBOutlet weak var MoneyLabel: UILabel!
	@IBOutlet weak var expirationView: UIView!
	@IBOutlet weak var expirationLabel: UILabel!
	@IBOutlet weak var logo: UIImageView!
	//@IBOutlet weak var companyname: UILabel!
	@IBOutlet weak var shelf: UITableView!
	@IBOutlet weak var ShelfView: ShadowView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		shelf.dataSource = self
		shelf.delegate = self
		UpdateOfferInformation()
		//If offer is already accepted, the accepted button will disappear.
		if isCloseButton {
			acceptButtonView.isHidden = true
		}
		//59 48
		expirationView.layer.cornerRadius = 5
		expirationView.layer.borderWidth = 1
		globalTimer.delegates.append(self)
		CheckExperation()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
            (granted, error) in
            if granted {
                print("yes")
            } else {
                print("No")
            }
        }
	}
	
	@IBOutlet weak var smallDone: UIButton!
	var delegate: OfferResponse?
	@IBOutlet weak var acceptButtonView: ShadowView!
	
	func UpdateOfferInformation() {
		
		//Make sure that if there is no company logo a default image is displayed. A building with a dish on it.
		
		if let picUrl  = ThisOffer.company.logo {
			logo.downloadAndSetImage(picUrl, isCircle: false)
		} else {
			logo.image = UIImage(named: "defaultcompany")
		}
		
		//companyname.text = ThisOffer.company.name
		
		MoneyLabel.text = NumberToPrice(Value: ThisOffer.money)
		
		//Make sure list of posts in offer is reflected.
		shelf.reloadData()
		
		//Make height of the tableView respond to the data is holds.
		if Int(shelfheight.constant) != (45 * ThisOffer.posts.count - 1) {
			shelfheight.constant = CGFloat(45 * ThisOffer.posts.count - 1)
		}
		
		shelf.layer.cornerRadius = 10
		
	}
	
	//ensures when the view is loaded to check if button is to close the VC. If so, it will change the button text because changing it before loading will lead to nil unwrapping problem.
	var isCloseButton: Bool = false

	
	@IBAction func dismissVC(_ sender: Any) {
		
		//Done is clicked or swipe down to dismiss the VC
		
		dismiss(animated: true, completion: nil)
		
	}
	
	var ThisOffer: Offer!

	@IBAction func OfferAccepted(_ sender: Any) {
		dismiss(animated: true) { self.delegate?.OfferAccepted(offer: self.ThisOffer) }
	}
	
	
}
