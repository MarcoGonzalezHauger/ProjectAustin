//
//  FollowButton.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 5/3/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

protocol FollowerButtonDelegete {
	func isFollowingChanged(sender: AnyObject, newValue: Bool)
}

@IBDesignable class FollowButtonRegular: UIControl {
	
	var changedByPress = false
	var delegate: FollowerButtonDelegete?
	
	var isFollowing = false {
		didSet {
			if !changedByPress {
				if isFollowing {
					isFollowingLabel.text = "Following"
				} else {
					isFollowingLabel.text = "Follow"
				}
			}
		}
	}
	
	@IBAction func ButtonPressed(_ sender: Any) {
		UseTapticEngine()
		changedByPress = true
		isFollowing = !isFollowing
		delegate?.isFollowingChanged(sender: self, newValue: isFollowing)
		changedByPress = false
		
		if isFollowing {
			isFollowingLabel.text = "Followed"
		} else {
			isFollowingLabel.text = "Follow"
		}
	}
	
	@IBInspectable var isBusiness = false {
		didSet {
			LoadColorScheme()
		}
	}
	
	@IBOutlet weak var isFollowingLabel: UILabel!
	@IBOutlet weak var shadowView: ShadowView!
	
	func LoadColorScheme() {
		if !isBusiness {
			shadowView.backgroundColor = UIColor.init(named: "Main_amassa")
		} else {
			shadowView.backgroundColor = .systemBlue
		}
	}
	
}
