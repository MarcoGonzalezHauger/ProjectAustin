//
//  MoneyVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/28/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

protocol IncomingMoneyDelegate {
	func viewOffer(IncomingMoneyOffer: Offer) -> ()
}

class IncomingMoneyCell: UITableViewCell, SyncTimerDelegate {
	
	func Tick() {
		if ThisOffer.allConfirmed {
			if let date = ThisOffer.allPostsConfrimedSince {
				TimeLeft.text = DateToCountdown(date: date.addingTimeInterval(172800))
			} else {
				TimeLeft.text = "completed"
			}
		} else {
			TimeLeft.text = "not complete"
		}
	}
	
	@IBOutlet weak var shadowview: ShadowView!
	@IBOutlet weak var moneyLabel: UILabel!
	@IBOutlet weak var companyName: UILabel!
	@IBOutlet weak var TimeLeft: UILabel!
	
	var ThisOffer: Offer! {
		didSet {
			moneyLabel.text = NumberToPrice(Value: ThisOffer.money)
			companyName.text = ThisOffer.company.name
			globalTimer.delegates.append(self)
		}
	}
	
	var delegate: IncomingMoneyDelegate?
	
	@IBAction func GoToOfferPage(_ sender: Any) {
		delegate?.viewOffer(IncomingMoneyOffer: ThisOffer)
	}
	
	override func awakeFromNib() {
		shadowview.cornerRadius = 15
		shadowview.ShadowOpacity = 0.2
		shadowview.ShadowRadius = 3
	}
	
}

class YourMoneyCell: UITableViewCell {
	
	@IBOutlet weak var shadowview: ShadowView!
	
	override func awakeFromNib() {
		shadowview.cornerRadius = 15
		shadowview.ShadowOpacity = 0.2
		shadowview.ShadowRadius = 3
	}
}

class MoneyVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GlobalListener, IncomingMoneyDelegate {
	
	//offer to be sent to segue (Preparation)
	var SegueViewOffer: Offer?
	
	func viewOffer(IncomingMoneyOffer: Offer) {
		SegueViewOffer = IncomingMoneyOffer
		self.performSegue(withIdentifier: "showOfferFromMoney", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let newviewoffer = SegueViewOffer
		let destination = segue.destination
		if segue.identifier == "showOfferFromMoney" {
			if let destination = (destination as! UINavigationController).topViewController as? OfferVC {
				destination.isCloseButton = true
				destination.ThisOffer = newviewoffer
			}
		}
	}
	
	func AcceptedOffersChanged() {
		shelf.reloadData()
	}
	
	@IBOutlet weak var shelf: UITableView!
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return shelf.bounds.height * 0.4
		} else {
			return 100
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return global.AcceptedOffers.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = shelf.dequeueReusableCell(withIdentifier: "yourMoney")
			return cell!
		} else {
			let cell = shelf.dequeueReusableCell(withIdentifier: "incomingMoney") as! IncomingMoneyCell
			cell.ThisOffer = global.AcceptedOffers[indexPath.row - 1]
			cell.delegate = self
			return cell
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		shelf.dataSource = self
		shelf.delegate = self
		global.delegates.append(self)
	}
}
