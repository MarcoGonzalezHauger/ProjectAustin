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
    //naveen added
    func goBankList()
}

class IncomingMoneyCell: UITableViewCell, SyncTimerDelegate {
	
	func Tick() {
        if self.ThisOffer.allConfirmed {
			if let date = ThisOffer.allPostsConfrimedSince {
				//User can only collect money after 2 days, or 172800 seconds.
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
    
    
    var selectedIndex:Int!
    
	var ThisOffer: Offer! {
		didSet {
            if  ThisOffer.offer_ID == "XXXDefault"{
                moneyLabel.text = ""
            }else{
                moneyLabel.text = NumberToPrice(Value: ThisOffer.money)
            }
			companyName.text = ThisOffer.company.name
			globalTimer.delegates.append(self)
		}
	}
	
	var delegate: IncomingMoneyDelegate?
	
	@IBAction func GoToOfferPage(_ sender: Any) {
		delegate?.viewOffer(IncomingMoneyOffer: ThisOffer)
	}

	
	override func awakeFromNib() {
//		shadowview.cornerRadius = 15
//		shadowview.ShadowOpacity = 0.2
//		shadowview.ShadowRadius = 3
	}
	
}

class YourMoneyCell: UITableViewCell {
	
	@IBOutlet weak var shadowview: ShadowView!
    @IBOutlet weak var yourMoneyLabel: UILabel!

	override func awakeFromNib() {
//		shadowview.cornerRadius = 15
//		shadowview.ShadowOpacity = 0.2
//		shadowview.ShadowRadius = 3
	}
    var delegate: IncomingMoneyDelegate?

    
    @IBAction func GoToBankList(_ sender: Any) {
        delegate?.goBankList()
    }
}

class MoneyVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GlobalListener, IncomingMoneyDelegate {
	
	//offer to be sent to segue (Preparation)
	var SegueViewOffer: Offer?
	
	func viewOffer(IncomingMoneyOffer: Offer) {
		SegueViewOffer = IncomingMoneyOffer
		self.performSegue(withIdentifier: "showOfferFromMoney", sender: self)
        
	}
    func goBankList() {
        self.performSegue(withIdentifier: "SegueBankList", sender: self)
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let newviewoffer = SegueViewOffer
		let destination = segue.destination
		if segue.identifier == "showOfferFromMoney" {
			if let destination = (destination as! UINavigationController).topViewController as? OfferVC {
				destination.isCloseButton = true
				destination.ThisOffer = newviewoffer
//                destination.selectedIndex = selectedIndex
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
		return global.AcceptedOffers.filter({ $0.offer_ID != "XXXDefault"}).count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = shelf.dequeueReusableCell(withIdentifier: "yourMoney") as! YourMoneyCell
            cell.yourMoneyLabel.text = NumberToPrice(Value: Yourself!.yourMoney)
            cell.delegate = self
            return cell      
		} else {
			let cell = shelf.dequeueReusableCell(withIdentifier: "incomingMoney") as! IncomingMoneyCell
			cell.ThisOffer = global.AcceptedOffers.filter({ $0.offer_ID != "XXXDefault"})[indexPath.row - 1]
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
    
    override func viewWillAppear(_ animated: Bool) {
        shelf.reloadData()
    }
}
