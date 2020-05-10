//
//  SimplexBackground.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 5/10/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Foundation

class SimplexBackground: UIView {
	
	@IBOutlet weak var backDrop: UIImageView!
	@IBOutlet weak var blur: UIVisualEffectView!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		LoadViewFromNib()
	}
	
	override func awakeFromNib() {
		self.backDrop.image = UIImage.init(named: "clouds")
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			self.Forever()
		}
		backDrop.isHidden = true
		blur.isHidden = true
	}
	
	func LoadViewFromNib() {
		let bundle = Bundle.init(for: type(of: self))
		let nib = UINib(nibName: "SimplexBackground", bundle: bundle)
		let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		view.frame = frame
		view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
		addSubview(view)
		
		
	}
	
	func Forever() {
		let transitionLength = 30
		let animation: CATransition = CATransition()
		animation.timingFunction = CAMediaTimingFunction(name:
			CAMediaTimingFunctionName.linear)
		animation.type = CATransitionType.push
		animation.subtype = CATransitionSubtype.fromRight
		self.backDrop.image = UIImage.init(named: "clouds")
		animation.duration = CFTimeInterval(transitionLength)
		self.backDrop.layer.add(animation, forKey: CATransitionType.push.rawValue)
		DispatchQueue.main.asyncAfter(deadline: .now() + Double(transitionLength)) {
			self.Forever()
		}
	}
	
}
