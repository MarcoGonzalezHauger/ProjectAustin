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
	@IBOutlet weak var backDrop2: UIImageView!
	@IBOutlet weak var bd1_left: NSLayoutConstraint!
	@IBOutlet weak var bd2_left: NSLayoutConstraint!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		LoadViewFromNib()
	}
	
	@IBInspectable var backgroundTint: UIColor = .black
	
	override func awakeFromNib() {
		let templateImage = UIImage.init(named: "clouds")!
		backDrop.image = templateImage
		backDrop2.image = templateImage
		backDrop2.tintColor = backgroundTint
		backDrop.tintColor = backgroundTint
		bd2_left.constant = backDrop.bounds.width
		bd1_left.constant = 0
		layoutIfNeeded()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			self.Forever()
		}
		
//		backDrop.isHidden = true
//		blur.isHidden = true
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
		//print("forver Triggered")
		let transitionLength = 10
		//reset
		self.bd2_left.constant = backDrop.bounds.width
		self.bd1_left.constant = 0
		self.layoutIfNeeded()
		
		//slide animation
		self.bd1_left.constant = -self.backDrop.bounds.width
		self.bd2_left.constant = 0
		
		UIView.animate(withDuration: TimeInterval(transitionLength), delay: 0, options: [.curveLinear], animations: {
			self.layoutIfNeeded()
		}, completion: { (Bool1) in
			self.Forever()
		})
	}
	
}
