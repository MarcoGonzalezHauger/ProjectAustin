//
//  NewProfilePage.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/28/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewProfilePage: UIViewController, balanceRefreshDelegate {
	
	func refreshed(userId: String, newBalance: Double) {
		if userId == Myself.userId {
			Myself.finance.balance = newBalance
			balanceLabel.text = NumberToPrice(Value: newBalance)
		}
	}

	@IBOutlet var uniformShadowViews: [ShadowView]!
	@IBOutlet weak var backProfileImage: UIImageView!
	@IBOutlet weak var frontProfileImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var executiveBadge: UIImageView!
	@IBOutlet weak var verifiedBadge: UIImageView!
	@IBOutlet weak var averageLikesLabel: UILabel!
	@IBOutlet weak var followerCountLabel: UILabel!
	@IBOutlet weak var engagmentRateLabel: UILabel!
	
	@IBOutlet weak var referralCodeLabel: UILabel!
	@IBOutlet weak var balanceLabel: UILabel!
	
	@IBOutlet weak var zipCodeLabel: UILabel!
	@IBOutlet weak var townNameLabel: UILabel!
	
	@IBOutlet weak var genderLabel: UILabel!
	@IBOutlet weak var ageLabel: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		for sv in uniformShadowViews {
			sv.cornerRadius = 8
		}
		loadFromMyself()
		balanceListners.append(self)
		StartListeningToBalance(userId: Myself.userId)
    }
	
	func loadFromMyself() {
		loadInfluencerInfo(influencer: Myself)
	}
	
	func loadInfluencerInfo(influencer i: Influencer) {
		backProfileImage.downloadAndSetImage(i.basic.profilePicURL)
		frontProfileImage.downloadAndSetImage(i.basic.profilePicURL)
		nameLabel.text = i.basic.name
		executiveBadge.isHidden = !i.basic.checkFlag("isAmbassadoorExecutive")
		verifiedBadge.isHidden = !i.basic.checkFlag("isVerified")
		averageLikesLabel.text = NumberToStringWithCommas(number: i.basic.averageLikes)
		followerCountLabel.text = NumberToStringWithCommas(number: i.basic.followerCount)
		engagmentRateLabel.text = "\(i.basic.engagmentRateInt)%"
		
		referralCodeLabel.text = "\(i.basic.referralCode)"
		balanceLabel.text = NumberToPrice(Value: i.finance.balance)
		
		zipCodeLabel.text = i.basic.zipCode
		self.townNameLabel.isHidden = true
		GetTownName(zipCode: i.basic.zipCode) { (zipCodeData, zipCode) in
			if let zipCodeData = zipCodeData {
				self.townNameLabel.isHidden = false
				self.townNameLabel.text = zipCodeData.CityAndStateName
			} else {
				self.townNameLabel.isHidden = true
			}
		}
		
		genderLabel.text = i.basic.gender
		
		ageLabel.text = "\(i.basic.age)"
		
	}

}
