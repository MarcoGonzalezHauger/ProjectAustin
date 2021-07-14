//
//  BasicBusinessTVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/28/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class BasicBusinessCell: UITableViewCell, FollowerButtonDelegete {

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
	
	@IBOutlet weak var followButton: FollowButtonSmall!
	@IBOutlet weak var businessLogo: UIImageView!
	@IBOutlet weak var businessNameLabel: UILabel!
	@IBOutlet weak var businessMissionLabel: UILabel!
	

	var thisBusiness: BasicBusiness!
	
	var represents: BasicBusiness {
		set {
			thisBusiness = newValue
			updateBusinessData()
		}
		get {
			return thisBusiness
		}
	}
	
	func updateBusinessData() {
		followButton.delegate = self
		businessNameLabel.text = represents.name
		businessMissionLabel.text = represents.mission
		
		businessLogo.downloadAndSetImage(represents.logoUrl)
		
        followButton.isFollowing = represents.isFollowing(as: Myself)
        //followButton.isFollowing = represents.isFollowing(as: Myself)
        
	}
}
