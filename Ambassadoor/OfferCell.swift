//
//  OfferCell.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/22/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

//Protocol for interactions with indivisual Offer Cells
@objc protocol OfferCellDelegate {
	@objc optional func OfferRejected(sender: Any) -> ()
	func ViewOffer(sender: Any) -> ()
	func isQueued(isQue: Bool) -> ()
	@objc optional func OfferExpired(sender: Any) -> ()
}

class OfferCell: UITableViewCell, SyncTimerDelegate {
	
	
	func OfferExpired() {
		if let dlg = delegate {
			dlg.OfferExpired?(sender: self)
		}
		reject(self)
	}
	
	//Handles all offer experation display information.
	func Tick() {
		
		if let o : Offer = ThisOffer {
			
			//Ago label.
			agolabel.text = DateToAgo(date: o.offerdate)
			
			//If the reject button exists, it lets the program know if the offer is rejected or not.
			if rejectbutton != nil {
				
				//If the offer HASN'T been rejected yet, but is expired, it will reject the offer. When the user sees it, it will be expired there.
				if o.isExpired {
					OfferExpired()
					return
				}
				
				//If it will expire in the next hour, turn "ago" label red.
				if o.expiredate.timeIntervalSinceNow < 3600 {
					agolabel.textColor = UIColor.red
				} else {
					agolabel.textColor = UIColor.lightGray
				}
			} else {
				//Offers that have already been rejected will not show the view button, instead a countdown to when they're expired. Which is usually in 1 hour since rejection.
				//if experation date is more than "now" (which will return NIL), say "expired" in red.
				if self.isCellExpired != o.isExpired {
					self.isCellExpired = o.isExpired
					if o.isExpired == true { OfferExpired() }
				}
				if let expiresin = expiresInLabel {
					if isCellExpired == true {
						viewbutton.isHidden = true
						agolabel.isHidden = true
						expiresin.text = "Expired"
						expiresin.textColor = UIColor.red
					} else {
						if let leftstring : String = DateToCountdown(date: o.expiredate)  {
							viewbutton.isHidden = false
							agolabel.isHidden = false
							expiresin.text = "Expires " + leftstring
							expiresin.textColor = UIColor.black
						}
					}
				}
			}
		}
	}
	
	@IBOutlet weak var viewbutton: UIButton!
	@IBOutlet weak var rejectbutton: UIButton!
	@IBOutlet weak var View: UIView!
	@IBOutlet weak var moneylabel: UILabel!
	@IBOutlet weak var postsLabel: UILabel!
	@IBOutlet weak var companylabel: UILabel!
	@IBOutlet weak var agolabel: UILabel!
	@IBOutlet weak var expiresInLabel: UILabel!
	
	//Clicks view on offer
	@IBAction func view(_ sender: Any) {
		if let dlg = delegate {
			dlg.isQueued(isQue: true)
			dlg.ViewOffer(sender: self)
			dlg.isQueued(isQue: false)
		}
	}
	
	override func awakeFromNib() {
		globalTimer.delegates.append(self)
		Tick()
	}
	
	//User rejects offer
	@IBAction func reject(_ sender: Any) {
		if let dlg = delegate {
			dlg.isQueued(isQue: true)
			dlg.OfferRejected?(sender: self)
			dlg.isQueued(isQue: false)
		}
	}
	
	//delegate for offer
	var delegate: OfferCellDelegate?
	
	//Creates PageVC in order to interact with it (not yet used Dec 5)
	var Pager: PageVC!
	
	var isCellExpired: Bool? {
		didSet {
			guard let o = ThisOffer else { return }
			if let expiresin = expiresInLabel {
				if isCellExpired == true {
					viewbutton.isHidden = true
					agolabel.isHidden = true
					expiresin.text = "Expired"
					expiresin.textColor = UIColor.red
				} else {
					if let leftstring : String = DateToCountdown(date: o.expiredate)  {
						viewbutton.isHidden = false
						agolabel.isHidden = false
						expiresin.text = "Expires " + leftstring
						expiresin.textColor = UIColor.black
					}
				}
			}
		}
	}
	
	//Current offer of the cell
	var ThisOffer: Offer! {
		didSet {
			moneylabel.text = NumberToPrice(Value: ThisOffer.money)
			companylabel.text = ThisOffer.company.name
			postsLabel.text = ThisOffer.posts.count == 1 ? "For 1 post" : "For \(ThisOffer.posts.count) posts"
			self.isCellExpired = ThisOffer.isExpired
			Tick()
		}
	}
}
