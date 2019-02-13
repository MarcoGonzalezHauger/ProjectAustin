//
//  BoldButton.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/9/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

@IBDesignable
class BoldButton: UIControl {
	
	
	var TheButton: UIButton = UIButton(type: .system)
	
	override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 20
		self.layer.borderWidth = 2
		self.layer.borderColor = UIColor.white.cgColor
		addSubview(TheButton)
		TheButton.translatesAutoresizingMaskIntoConstraints = false
		TheButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		TheButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		TheButton.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		TheButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
		TheButton.addTarget(self, action: #selector(ButtonDown), for: .touchDown)
		TheButton.addTarget(self, action: #selector(ButtonUp), for: .touchUpInside)
		TheButton.addTarget(self, action: #selector(ButtonUp), for: .touchUpOutside)
		TheButton.addTarget(self, action: #selector(ButtonPressed), for: .touchUpInside)
		self.clipsToBounds = true
		DrawControl(isLitUp: false)
    }
	
	func DrawControl(isLitUp: Bool) {
		UIView.animate(withDuration: 0.15) {
			if isLitUp {
				self.layer.backgroundColor = UIColor.white.cgColor
				self.TheButton.setTitleColor(self.superview?.backgroundColor, for: .normal)
			} else {
				self.layer.backgroundColor = self.superview?.backgroundColor?.cgColor
				self.TheButton.setTitleColor(UIColor.white, for: .normal)
			}
		}
	}
	
	@objc func ButtonDown() {
		DrawControl(isLitUp: true)
	}
	
	@objc func ButtonUp() {
		DrawControl(isLitUp: false)
	}
	
	@objc func ButtonPressed() {
		sendActions(for: .touchUpInside)
	}
	
	//Font for the button
	@IBInspectable
	var FontSize: Int = 23 {
		didSet {
			TheButton.titleLabel?.font = .boldSystemFont(ofSize: CGFloat(FontSize))
		}
	}
	
	//Text for button.
	@IBInspectable
	var Text: String = "" {
		didSet {
			TheButton.setTitle(Text, for: .normal)
		}
	}
	
 }
