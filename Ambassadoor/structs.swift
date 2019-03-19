//
//  structs.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/22/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import Foundation
import UIKit

//Protocol for ACCEPTING offers.
protocol OfferResponse {
	func OfferAccepted(offer: Offer) -> ()
}


//Shadow Class reused all throughout this app.
@IBDesignable
class ShadowView: UIView {
	override func awakeFromNib() {
		super.awakeFromNib()
		DrawShadows()
	}
	override var bounds: CGRect { didSet { DrawShadows() } }
	@IBInspectable var cornerRadius: Float = 10 {	didSet { DrawShadows() } }
	@IBInspectable var ShadowOpacity: Float = 0.2 { didSet { DrawShadows() } }
	@IBInspectable var ShadowRadius: Float = 1.75 { didSet { DrawShadows() } }
	@IBInspectable var ShadowColor: UIColor = UIColor.black { didSet { DrawShadows() } }
	
	func DrawShadows() {
		//draw shadow & rounded corners for offer cell
		self.layer.cornerRadius = CGFloat(cornerRadius)
		self.layer.shadowColor = ShadowColor.cgColor
		self.layer.shadowOpacity = ShadowOpacity
		self.layer.shadowOffset = CGSize.zero
		self.layer.shadowRadius = CGFloat(ShadowRadius)
		self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
		
	}
}

//Structure for an offer that comes into username's inbox
class Offer : NSObject {
	let money: Double
	let company: Company
	let posts: [Post]
	let offerdate: Date
	let offer_ID: String
	let expiredate: Date
	var allPostsConfrimedSince: Date?
	var allConfirmed: Bool {
		get {
			var areConfirmed = true
			for x : Post in posts {
				if x.isConfirmed == false {
					areConfirmed = false
				}
			}
			return areConfirmed
		}
	}
	var isAccepted: Bool
	var isExpired: Bool {
		return self.expiredate.timeIntervalSinceNow <= 0
	}
	var debugInfo: String {
		return "Offer by \(company.name) for $\(String(money)) that is \(isExpired ? "" : "not ") expired."
	}
    init(dictionary: [String: AnyObject]) {
        self.money = dictionary["money"] as! Double
        self.company = dictionary["company"] as! Company
        self.posts = dictionary["posts"] as! [Post]
        self.offerdate = dictionary["offerdate"] as! Date
        self.offer_ID = dictionary["offer_ID"] as! String
        self.expiredate = dictionary["expiredate"] as! Date
        self.allPostsConfrimedSince = dictionary["allPostsConfirmedSince"] as? Date
        self.isAccepted = dictionary["isAccepted"] as! Bool
    }
}

//Strcuture for users
class User: NSObject {
	let name: String?
	let username: String
	let followerCount: Double
	let profilePicURL: String?
	var primaryCategory: Category
	var SecondaryCategory: Category?
	let averageLikes: Double?
	var zipCode: Int?
	
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String
        self.username = dictionary["username"] as! String
        self.followerCount = dictionary["followerCount"] as! Double
		if (dictionary["profilePicture"] as? String ?? "") == "" {
			self.profilePicURL = nil
		} else {
			self.profilePicURL = dictionary["profilePicture"] as? String
		}
		debugPrint("Category: \(String(describing: dictionary["primaryCategory"]))")
		self.primaryCategory = Category.init(rawValue: dictionary["primaryCategory"] as? String ?? "Other")!
		if ((dictionary["secondaryCategory"] ?? "") as! String) == ""{
			self.SecondaryCategory = nil
		} else {
			self.SecondaryCategory = ((dictionary["secondaryCategory"] as? String ?? "") == "" ? nil : Category.init(rawValue: dictionary["secondaryCategory"] as! String))!
		}
		self.averageLikes = dictionary["averageLikes"] as? Double
		self.zipCode = dictionary["zipCode"] as? Int
    }
	
	override var description: String {
		return "NAME: \(name ?? "NIL")\nUSERNAME: \(username)\nFOLLOWER COUNT: \(followerCount)\nPROFILE PIC: \(profilePicURL ?? "NIL")\nACCOUNT TYPE: \(primaryCategory)\nAVERAGE LIKES: \(averageLikes ?? -404)"
	}
}

//Structure for post
struct Post {
	let image: String?
	let instructions: String
	let captionMustInclude: String?
	let products: [Product]?
	let post_ID: String
	let PostType: TypeofPost
	var confirmedSince: Date?
	var isConfirmed: Bool
}

//struct for product
struct Product {
	let image: String?
	let name: String
	let price: Double
	let buy_url: String
	let color: String
	let product_ID: String
}

//struct for company
struct Company {
	let name: String
	let logo: String?
	let mission: String
	let website: String
	let account_ID: String
	let instagram_name: String
	let description: String
}

//Carries personal info only avalible to view and edit by the user.
struct PersonalInfo {
	let gender: Gender?
    let accountBalance: Int?
}

enum Gender {
	case male, female, other
}

enum TypeofPost {
	case SinglePost, MultiPost, Story
}

