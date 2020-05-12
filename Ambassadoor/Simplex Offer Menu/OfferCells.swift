//
//  OfferCells.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 5/11/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import UIKit

let tewntyOneColor: UIColor = .systemPink

class FollowedCompaniesOffer: UITableViewCell {
	
	@IBOutlet weak var logo: UIImageView!
	@IBOutlet weak var cashOut: UILabel!
	@IBOutlet weak var companyName: UILabel!
	@IBOutlet weak var progressView: ShadowView!
	@IBOutlet weak var is21view: ShadowView!
	
	@IBOutlet weak var progressViewWidth: NSLayoutConstraint!
	var offer: Offer?{
		didSet{
			self.is21view.backgroundColor = tewntyOneColor
			if let offerDetail = offer{
				if let picurl = offerDetail.company?.logo {
					self.logo.downloadAndSetImage(picurl)
				} else {
					self.logo.UseDefaultImage()
				}
				
				let pay = calculateCostForUser(offer: offerDetail, user: Yourself)
				self.cashOut.text = NumberToPrice(Value: pay)
				self.progressViewWidth.constant = self.frame.size.width * CGFloat((offerDetail.cashPower!/offerDetail.money))
				self.progressView.backgroundColor = UIColor.init(red: 1, green: 227/255, blue: 35/255, alpha: 1)
				self.companyName.text = offerDetail.company?.name
				self.updateConstraints()
				self.layoutIfNeeded()
				self.is21view.isHidden = !offerDetail.mustBe21
			}
			
		}
	}
	
}

class StandardOfferCell: UITableViewCell {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var cashOut: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var progressView: ShadowView!
	@IBOutlet weak var is21view: ShadowView!
	
	@IBOutlet weak var progressViewWidth: NSLayoutConstraint!
	var offer: Offer?{
		didSet{
			UpdateOfferCell()
		}
	}
	
	func UpdateOfferCell() {
		if let offerDetail = offer {
			self.is21view.backgroundColor = tewntyOneColor

			self.is21view.isHidden = !offerDetail.mustBe21
			if let picurl = offerDetail.company?.logo {
				self.logo.downloadAndSetImage(picurl)
			} else {
				self.logo.UseDefaultImage()
			}
			self.companyName.text = offerDetail.company?.name
			if offerDetail.isFiltered {
				let pay = calculateCostForUser(offer: offerDetail, user: Yourself)
				self.cashOut.isHidden = false
				self.cashOut.text = NumberToPrice(Value: pay)
				self.progressViewWidth.constant = self.frame.size.width * CGFloat((offerDetail.cashPower!/offerDetail.money))
				self.progressView.backgroundColor = UIColor.init(red: 1, green: 227/255, blue: 35/255, alpha: 1)
				self.updateConstraints()
				self.layoutIfNeeded()
			}else{
				self.cashOut.isHidden = true
				self.progressViewWidth.constant = self.frame.size.width
				self.progressView.backgroundColor = .red
				self.updateConstraints()
				self.layoutIfNeeded()
			}
		}
		
	}
	
	func GetIsFiltered() -> Bool {
		return offer?.isFiltered ?? false
	}
    
    
}
