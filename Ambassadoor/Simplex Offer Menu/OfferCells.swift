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
			if let picurl = offerDetail.companyDetails?.logo {
				self.logo.downloadAndSetImage(picurl)
			} else {
				self.logo.UseDefaultImage()
			}
			self.companyName.text = offerDetail.companyDetails?.name
			
			if offerDetail.isDefaultOffer {
				self.cashOut.isHidden = false
				self.cashOut.text = "Get Verified"
				self.progressViewWidth.constant = (self.frame.size.width - 12)
				self.progressView.backgroundColor = .systemOrange
				self.cashOut.textColor = GetForeColor()
				   self.companyName.textColor = GetForeColor()
			} else {
				if offerDetail.isFiltered {
					let pay = calculateCostForUser(offer: offerDetail, user: Yourself, increasePayVariable: offerDetail.incresePay ?? 1)
					self.cashOut.isHidden = false
					self.cashOut.text = NumberToPrice(Value: pay)
                    self.progressViewWidth.constant = (self.frame.size.width - 12) * CGFloat((offerDetail.cashPower!/offerDetail.originalAmount!))
					self.progressView.backgroundColor = UIColor.init(red: 1, green: 227/255, blue: 35/255, alpha: 1)
					self.cashOut.textColor = GetForeColor()
					self.companyName.textColor = GetForeColor()
				}else{
					self.cashOut.isHidden = false
					self.cashOut.text = "No Money Left in This Offer"
					self.progressViewWidth.constant = self.frame.size.width
					self.progressView.backgroundColor = GetBackColor()
					self.cashOut.textColor = .systemGray
					self.companyName.textColor = .systemGray
				}
			}
			self.updateConstraints()
			self.layoutIfNeeded()
			
		}
		
	}
	
	func GetIsFiltered() -> Bool {
		return offer?.isFiltered ?? false
	}
    
    
}
