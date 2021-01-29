//
//  Useful UI Functions.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/28/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import UIKit

func CreateFlyout(text: String, view: UIView, desiredLocation: CGPoint) {
	let tempLabel: UILabel = UILabel.init()
	tempLabel.text = text
	tempLabel.textColor = .systemRed
	tempLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.05555)
	tempLabel.layer.position = desiredLocation
	view.addSubview(tempLabel)
	view.bringSubviewToFront(tempLabel)
	print("FlyLabelCreeated")
}
