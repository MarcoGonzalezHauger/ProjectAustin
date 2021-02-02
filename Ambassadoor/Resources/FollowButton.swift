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

class FollowButtonRegular: UIView {
	
	var changedByPress = false
	var delegate: FollowerButtonDelegete?
	
	@IBOutlet weak var trailing: NSLayoutConstraint!
	
	
	var isFollowing = false {
		didSet {
			if !changedByPress {
				if isFollowing {
					SetLabelText(text: "Following", animated: false)
					self.width.constant = 115
				} else {
					SetLabelText(text: "Follow", animated: false)
					self.width.constant = 92
				}
			}
		}
	}
	
	func MakeCentered() {
		trailing?.isActive = false
	}
	
	func ButtonPressed() {
		UseTapticEngine()
		changedByPress = true
		isFollowing = !isFollowing
		changedByPress = false
		delegate?.isFollowingChanged(sender: self, newValue: isFollowing)
		
		if isFollowing {
			CreateFollowEffect()
		} else {
			CreateUnfollowEffect()
		}
	}
	
	func CreateUnfollowEffect() {
//		shadowView.backgroundColor = .systemRed
//		gradientView.alpha = 0
//		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//			if !self.isFollowing {
//				UIView.animate(withDuration: 1, delay: 0.0, options: [.allowUserInteraction], animations: {
//					self.gradientView.alpha = 1
//				})
//			}
//		}
		self.SetLabelText(text: "Unfollowed", animated: false)
		self.width.constant = 125
		UIView.animate(withDuration: 0.25) {
			self.layoutIfNeeded()
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			if !self.isFollowing {
				self.SetLabelText(text: "Follow", animated: true, fromTop: false)
				self.width.constant = 92
				UIView.animate(withDuration: 0.25) {
					self.layoutIfNeeded()
				}
			}
		}
	}
	
	func CreateFollowEffect() {
//		shadowView.backgroundColor = getColorForBool(bool: isBusiness)
//		gradientView.alpha = 0
//		UIView.animate(withDuration: 1, delay: 0.0, options: [.allowUserInteraction], animations: {
//			self.gradientView.alpha = 1
//		})
//
		self.width.constant = 110
		UIView.animate(withDuration: 0.25) {
			self.layoutIfNeeded()
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
			self.SetLabelText(text: "Followed", animated: true)
		}
	}
	
	@IBOutlet weak var width: NSLayoutConstraint!
	
	func SetLabelText(text textstring: String, animated: Bool, fromTop: Bool = true) {
        if animated {
            let animation: CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.push
			animation.subtype = fromTop ? CATransitionSubtype.fromTop : CATransitionSubtype.fromBottom
            self.isFollowingLabel.text = textstring
            animation.duration = 0.25
            self.isFollowingLabel.layer.add(animation, forKey: CATransitionType.push.rawValue)
        } else {
            isFollowingLabel.text = textstring
        }
    }
	
	var touchDown: UILongPressGestureRecognizer?
	
	func setupTap() {
		touchDown = UILongPressGestureRecognizer(target:self, action: #selector(didTouchDown))
		touchDown!.minimumPressDuration = 0
		self.addGestureRecognizer(touchDown!)
	}

	@objc func didTouchDown(gesture: UILongPressGestureRecognizer) {
		if gesture.state == .began {
			ButtonPressed()
		}
	}
	
	var isBusiness = false {
		didSet {
			LoadColorScheme()
		}
	}
	
	@IBOutlet weak var isFollowingLabel: UILabel!
	@IBOutlet weak var shadowView: ShadowView!
	@IBOutlet weak var gradientView: UIView!
	@IBOutlet weak var ambIcon: UIImageView!
	
	func LoadColorScheme() {
		let tint = getColorForBool(bool: isBusiness)
		shadowView.borderColor = tint
		isFollowingLabel.textColor = tint
		ambIcon.tintColor = tint
	}
	
	func getColorForBool(bool: Bool) -> UIColor {
		return UIColor.init(named: "AmbPurple")!
//		return bool ? UIColor.init(named: "AmbassadoorOrange")! : .systemBlue
//		return bool ? UIColor.init(patternImage: UIImage.init(named: "followerbutton_business")!) : UIColor.init(patternImage: UIImage.init(named: "followerbutton_influencer")!)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		LoadViewFromNib()
		setupTap()
	}
	
	func LoadViewFromNib() {
		let bundle = Bundle.init(for: type(of: self))
		let nib = UINib(nibName: "FollowButtonRegular", bundle: bundle)
		let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		view.frame = bounds
		view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
		addSubview(view)
		//return view
	}
	
}
