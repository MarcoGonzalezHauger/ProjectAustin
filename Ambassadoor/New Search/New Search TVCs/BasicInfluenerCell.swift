//
//  BasicInfluenerCell.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/28/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class BasicInfluenerCell: UITableViewCell, FollowerButtonDelegete {
	
	func isFollowingChanged(sender: AnyObject, newValue: Bool) {
		if newValue {
			represents.Follow(as: Myself)
			let parentView = (self.superview) as! UITableView
			let fullView = parentView.superview!
			let point = parentView.convert(self.frame.origin, to: fullView)
			CreateFlyout(text: "Followed", view: fullView, desiredLocation: point)
		} else {
			represents.Unfollow(as: Myself)
		}
	}

	var thisInf: BasicInfluencer!
	
	@IBOutlet weak var followButton: FollowButtonSmall!
	@IBOutlet weak var verifiedBadge: UIImageView!
	@IBOutlet weak var executiveBadge: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var averageLikesLabel: UILabel!
	@IBOutlet weak var followerCountLabel: UILabel!
	@IBOutlet weak var userImagePicture: UIImageView!
	@IBOutlet weak var engagmentRateLabel: UILabel!
	
	var represents: BasicInfluencer {
		set {
			thisInf = newValue
			updateInfluencerData()
		}
		get {
			return thisInf
		}
	}
	
	func updateInfluencerData() {
		followButton.delegate = self
		verifiedBadge.isHidden = !represents.checkFlag("isVerified")
		executiveBadge.isHidden = !represents.checkFlag("isAmbassadoorExecutive")
		nameLabel.text = represents.name
		
		averageLikesLabel.text = CompressNumber(number: represents.averageLikes)
		followerCountLabel.text = CompressNumber(number: represents.followerCount)
				
		engagmentRateLabel.text = "\(represents.engagementRateInt)%"
		userImagePicture.downloadAndSetImage(represents.resizedProfile)
		
		if represents.userId == Myself.userId {
			followButton.isHidden = true
		} else {
			followButton.isHidden = false
			followButton.isFollowing = represents.isFollowing(as: Myself)
		}
		
	}

}
