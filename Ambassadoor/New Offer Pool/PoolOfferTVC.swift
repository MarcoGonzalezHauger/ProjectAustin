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
		priceForInfluencer.text = NumberToPrice(Value: poolOffer.totalCost(forInfluencer: Myself.basic), enforceCents: true)
		perPostLabel.text = NumberToPrice(Value: poolOffer.pricePerPost(forInfluencer: Myself.basic)) + " each post"
		
		let percent = poolOffer.cashPower / poolOffer.originalCashPower
		leftOfLabel.text = NumberToPrice(Value: poolOffer.cashPower) + " left of " + NumberToPrice(Value: poolOffer.originalCashPower)
		self.progressView.backgroundColor = GetColorFromPercentage(percent: percent)
		let maxWidth = expectedWidth - 24
		if maxWidth * CGFloat(percent) > 0 {
			self.barWidth.constant = maxWidth * CGFloat(percent)
		} else {
			self.barWidth.constant = 0
		}
		if poolOffer.cashPower < poolOffer.totalCost(forInfluencer: Myself.basic) {
			leftOfLabel.textColor = .red
			perPostLabel.text = "Not enough left in Offer."
		} else {
			leftOfLabel.textColor = GetForeColor()
		}
	}
    
}
