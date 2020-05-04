//
//  FollowButton.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 5/3/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

enum followState {
	case notFollowed, Followed
}

enum accountType {
	case business, influencer
}

@IBDesignable class FollowButtonRegular: UIControl {
	
	var FollowState: followState = .notFollowed {
		didSet {
			updateFollowState()
		}
	}
	
	@IBAction func ButtonPressed(_ sender: Any) {
		
	}
	
	@IBInspectable var isBusiness = false {
		didSet {
			LoadColorScheme()
		}
	}
	
	@IBOutlet weak var shadowView: ShadowView!
	
	func LoadColorScheme() {
		if !isBusiness {
			shadowView.backgroundColor = UIColor.init(named: "Main_amassa")
		} else {
			shadowView.backgroundColor = .systemBlue
		}
	}
	
	func updateFollowState() {
		
	}
	
}
