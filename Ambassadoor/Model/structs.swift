//
//  structs.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/22/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import Foundation
import UIKit
import CoreData


//Shadow Class reused all throughout this app.
@IBDesignable
class ShadowView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        DrawShadows()
    }
    override var bounds: CGRect { didSet { DrawShadows() } }
    @IBInspectable var cornerRadius: Float = 10 { didSet { updateCornerRadius() } }
    @IBInspectable var ShadowOpacity: Float = 0 { didSet { updateShadows() } }
    @IBInspectable var ShadowRadius: Float = 1.75 { didSet { updateShadows() } }
    @IBInspectable var ShadowColor: UIColor = UIColor.black { didSet { updateShadows() } }
    @IBInspectable var borderWidth: Float = 0.0 { didSet { updateBorder() } }
	@IBInspectable var borderColor: UIColor = .clear { didSet { updateBorder() }}
	
	func animateBorderColor(toColor: UIColor, duration: Double) {
		let animation: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
		animation.fromValue = borderColor.cgColor
		animation.toValue = toColor.cgColor
		animation.duration = duration
		layer.add(animation, forKey: "borderColor")
		borderColor = toColor
	}
	
	func DrawShadows() {
		//draw shadow & rounded corners for offer cell
		updateCornerRadius()
		updateShadows()
		updateBorder()
    }
	
	func updateCornerRadius() {
		if cornerRadius != 0 {
			self.layer.cornerRadius = CGFloat(cornerRadius)
		}
	}
	
	func updateShadows() {
		if ShadowOpacity != 0 {
			self.layer.shadowColor = ShadowColor.cgColor
			self.layer.shadowOpacity = ShadowOpacity
			self.layer.shadowOffset = CGSize(width: 0, height: 4)
			self.layer.shadowRadius = CGFloat(ShadowRadius)
		}
	}
	
	func updateBorder() {
		if borderWidth != 0 {
			self.layer.borderWidth = CGFloat(borderWidth)
			self.layer.borderColor = borderColor.cgColor
			self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
		}
	}
	
}


class CachedImages: NSObject {
    var link: String?
    var imagedata: Data?
    var object: NSManagedObject?
    var date: Date?
    
    init(object: NSManagedObject) {
        if let data = object.value(forKey: "imagedata") as? Data{
            self.link = (object.value(forKey: "url") as! NSString) as String
            self.imagedata = data
            self.date = (object.value(forKey: "updatedDate") as? Date ?? Date.getcurrentESTdate())
            self.object = object
        }
        
    }
}

var FreePass = false //If user has a newer app version; Not beta code required.

enum SuspiciousFlags: String {
    case zeroPost = "User has made zero post",
    veryLowFollowers = "like to follow ratio very low",
    moreLikesThanFollowers = "This person gets more likes than followers.",
    overMoneyExcess = "Suspicoius Offer Money"
    
}

