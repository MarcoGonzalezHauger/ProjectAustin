//
//  redeemNC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/27/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class redeemNC: UINavigationController {

	let survey = RedeemSurvey.init()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
    }
	
	func dismissMe() {
		dismiss(animated: true, completion: nil)
	}

}

class redeemPage1: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	@IBAction func YesNoPressed(_ sender: Any) {
		(navigationController as! redeemNC).survey.spentMoney = (sender as! UIButton).title(for: .normal) == "Yes"
		performSegue(withIdentifier: "toNext", sender: self)
	}
	
}

class redeemPage2: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	@IBAction func backPressed(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func pressedAButton(_ sender: Any) {
		(navigationController as! redeemNC).survey.friends = (sender as! UIButton).tag
		performSegue(withIdentifier: "toNext", sender: self)
	}
	
}

class redeemPage3: UIViewController {
	
	@IBOutlet weak var moneyTextField: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		moneyTextField.addDoneCancelToolbar(onDone: nil, onCancel: nil)
	}
	
	
	
	@IBAction func backPressed(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func donePressed(_ sender: Any) {
		(navigationController as! redeemNC).survey.totalSpent = Double.init(moneyTextField.text!)
		performSegue(withIdentifier: "toNext", sender: self)
	}
	
}

class redeemPage4: UIViewController {
	
	@IBOutlet weak var influencerEmail: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//First, checks that offer exists and is Paid.
		
		let xoPost = Myself.inProgressPosts.filter{$0.checkFlag("xo case study")}[0]
		if xoPost.checkFlag("redeemed") {
			self.showStandardAlertDialog(title: "Failed", msg: "You have already redeemed your gift card.", handler: nil)
			return
		}
		if xoPost.status != "Paid" {
			self.showStandardAlertDialog(title: "Failed", msg: "You have not completed the offer yet.", handler: nil)
			return
		}
		
		influencerEmail.text = Myself.email
		
		//Then, uploads survey data to firebase.
		
		let ref = Database.database().reference().child("XOCaseStudy").child(Myself.basic.username)
		ref.updateChildValues((navigationController as! redeemNC).survey.toDictionary())
		
		//subtracts the $20 payout.
		if Myself.finance.balance >= 20 {
			Myself.finance.balance -= 20
		}
		
		//Sets post to reedeemed status and finished.
		
		xoPost.AddFlag("redeemed")
		Myself.UpdateToFirebase(alsoUpdateToPublic: false, completed: nil)
		
	}
	
	@IBAction func closeButtonPressed(_ sender: Any) {
		(navigationController as! redeemNC).dismissMe()
	}
	
}

class RedeemSurvey {
	var spentMoney: Bool?
	var friends: Int?
	var totalSpent: Double?
	
	func toDictionary() -> [String: Any] {
		var newDict: [String: Any] = [:]
		
		newDict["username"] = Myself.basic.username
		newDict["spent"] = spentMoney ?? 0
		newDict["bringAlongs"] = friends ?? 0
		newDict["totalSpent"] = totalSpent ?? 0
		newDict["userId"] = Myself.userId
		newDict["date"] = Date().toUString()
		newDict["email"] = Myself.email
		
		
		return newDict
		
	}
	
}
