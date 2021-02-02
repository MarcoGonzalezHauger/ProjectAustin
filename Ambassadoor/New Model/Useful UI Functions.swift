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
	view.addSubview(tempLabel)
	tempLabel.text = text
	tempLabel.textColor = .systemRed
	tempLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.05555)
	tempLabel.layer.position = desiredLocation
	view.bringSubviewToFront(tempLabel)
	print("FlyLabelCreeated")
}

func SetLabelText(label: UILabel, text textstring: String, animated: Bool, fromTop: Bool = true) {
	if animated {
		let animation: CATransition = CATransition()
		animation.timingFunction = CAMediaTimingFunction(name:
			CAMediaTimingFunctionName.easeInEaseOut)
		animation.type = CATransitionType.push
		animation.subtype = fromTop ? CATransitionSubtype.fromTop : CATransitionSubtype.fromBottom
		label.text = textstring
		animation.duration = 0.25
		label.layer.add(animation, forKey: CATransitionType.push.rawValue)
	} else {
		label.text = textstring
	}
}

let impact = UIImpactFeedbackGenerator()
func UseTapticEngine() {
	impact.impactOccurred()
}

func GetForeColor() -> UIColor {
	if #available(iOS 13.0, *) {
		return .label
	} else {
		return .black
	}
}

func GetBackColor() -> UIColor {
	if #available(iOS 13.0, *) {
		return .systemBackground
	} else {
		return .white
	}
}

func GetInterestUrl(interest: String) -> String {
	return "https://firebasestorage.googleapis.com/v0/b/amassadoor.appspot.com/o/interestImages%2Fprofile%2F\(interest.replacingOccurrences(of: " ", with: "%20"))_128x128.png?alt=media&token=4264d4fc-143d-4cf3-ac6b-fa4f9e341712"
}

func GetColorForNumber(number: Double) -> UIColor {
	if number < 0 {
		return UIColor.init(named: "newYouVsThemRed")!
	} else if number > 0 {
		return UIColor.init(named: "newYouVsThemGreen")!
	} else {
		return GetForeColor()
	}
}

func engagmentRateInDetail(engagmentRate eg: Double, enforceSign es: Bool) -> String {
	if es {
		return (eg > 0 ? "+" : "") + String((eg * 10000).rounded() / 100) + "%"
	} else {
		return String((eg * 10000).rounded() / 100) + "%"
	}
}

func roundPriceDown(price: Double) -> Double {
	return (price * 100).rounded(.down) / 100
}

func GetColorFromPercentage(percent: Double) -> UIColor {
	switch true {
	case percent < 0.2:
		return .systemRed
	case percent < 0.55:
		return .systemYellow
	default:
		return .systemGreen
	}
}

func CompressNumber(number: Double) -> String {
	var number = number
	var returnValue = ""
	var suffix = ""
	var prefix = ""
	if number < 0 {
		number = number * -1
		prefix = "-"
	}
	switch number {
	case 0...999:
		returnValue =  String(number)
	case 1000...99999:
		returnValue =  "\(floor(number/100) / 10)"
		suffix = "K"
	case 100000...999999:
		returnValue =  "\(floor(number/1000))"
		suffix = "K"
	case 1000000...9999999:
		returnValue =  "\(floor(number/10000) / 100)"
		suffix = "M"
	case 10000000...99999999:
		returnValue =  "\(floor(number/100000) / 10)"
		suffix = "M"
	case 100000000...999999999:
		returnValue =  "\(floor(number/1000000))"
		suffix = "M"
	case 1000000000...9999999999:
		returnValue =  "\(floor(number/10000000) / 100)"
		suffix = "B"
	case 10000000000...99999999999:
		returnValue =  "\(floor(number/100000000) / 10)"
		suffix = "B"
	case 100000000000...999999999999:
		returnValue =  "\(floor(number/1000000000))"
		suffix = "B"
	default:
		//okay if you have more than a billion followers/average likes... c'mon.
		return "A Lot."
	}
	if returnValue.hasSuffix(".00") || returnValue.hasSuffix(".0") {
		returnValue = String(returnValue.split(separator: ".").first!)
	}
	return prefix + returnValue + suffix
}
