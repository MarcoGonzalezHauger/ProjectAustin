//
//  PoolOfferTVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/31/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class PoolOfferTVC: UITableViewCell {

	var poolOffer: PoolOffer!
	
	@IBOutlet weak var backImage: UIImageView!
	@IBOutlet weak var blurView: UIVisualEffectView!
	
	@IBOutlet weak var priceForInfluencer: UILabel!
	@IBOutlet weak var perPostLabel: UILabel!
	@IBOutlet weak var byCoLabel: UILabel!
	@IBOutlet weak var regularProfilePic: UIImageView!
	
	@IBOutlet weak var leftOfLabel: UILabel!
	@IBOutlet weak var progressView: UIView!
	@IBOutlet weak var barView: ShadowView!
	@IBOutlet weak var barWidth: NSLayoutConstraint!
	
	func updateContents(expectedWidth: CGFloat) {
		backImage.layer.cornerRadius = 8
		blurView.layer.cornerRadius = 8
		if let bb = poolOffer.BasicBusiness() {
			backImage.downloadAndSetImage(bb.logoUrl)
			regularProfilePic.downloadAndSetImage(bb.logoUrl)
			byCoLabel.text = "by " + bb.name
		} else {
			backImage.image = nil
			regularProfilePic.image = nil
			byCoLabel.text = poolOffer.businessId
		}
		
		if poolOffer.checkFlag("xo case study") {
			
			
			priceForInfluencer.text = "$20 Gift Card"
			perPostLabel.text = ""
			leftOfLabel.text = "Exlcusive Gift Card Offer"
			let maxWidth = expectedWidth - 24
			self.barWidth.constant = maxWidth
			self.progressView.backgroundColor = .systemGreen
			
		} else {
			
			//Regular
			
			let costPerPost = roundPriceDown(price: poolOffer.totalCost(forInfluencer: Myself.basic))
			print("costPerPost====",costPerPost)
			priceForInfluencer.text = NumberToPrice(Value: costPerPost, enforceCents: true)
			perPostLabel.text = NumberToPrice(Value: poolOffer.pricePerPost(forInfluencer: Myself.basic)) + " each post"
			let percent = poolOffer.cashPower / poolOffer.originalCashPower
			leftOfLabel.text = NumberToPrice(Value: poolOffer.cashPower) + " left of " + NumberToPrice(Value: poolOffer.originalCashPower)
			progressView.backgroundColor = GetColorFromPercentage(percent: percent)
			let maxWidth = expectedWidth - 24
			if maxWidth * CGFloat(percent) > 0 {
				self.barWidth.constant = maxWidth * CGFloat(percent)
			} else {
				self.barWidth.constant = 0
			}
			if !poolOffer.canAffordInflunecer(forInfluencer: Myself.basic) {
				perPostLabel.text = "Not enough left in Offer."
				progressView.backgroundColor = .red
			}
		}
		
		
		
		
	}
}
