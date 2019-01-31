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
class ShadowView: UIView {
	override func awakeFromNib() {
		super.awakeFromNib()
		DrawShadows()
	}
	override var bounds: CGRect { didSet { DrawShadows() } }
	var cornerRadius = 10 {	didSet { DrawShadows() } }
	var ShadowOpacity: Float = 0.2 { didSet { DrawShadows() } }
	var ShadowRadius = 1.75 { didSet { DrawShadows() } }
	var ShadowColor = UIColor.black { didSet { DrawShadows() } }
	
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
struct User {
	let name: String?
	let username: String
	let followerCount: Double
	let profilePicture: UIImage?
	let AccountType: SubCategories
}

//Structure for post
struct Post {
	let image: UIImage?
	let instructions: String
	let caption: String?
	let products: [Product]?
	let post_ID: String
	let PostType: TypeofPost
	var confirmedSince: Date?
	var isConfirmed: Bool
}

//struct for product
struct Product {
	let image: UIImage?
	let name: String
	let price: Double
	let buy_url: String
	let color: String
	let product_ID: String
}

//struct for company
struct Company {
	let name: String
	let logo: UIImage?
	let mission: String
	let website: String
	let account_ID: String
	let instagram_name: String
	let description: String
}

struct PersonalInfo {
	let areacode: Int?
	let gender: Gender?
}

enum Gender {
	case male, female, other
}

enum TypeofPost {
	case SinglePost, MultiPost, Story
}

//COMPLETE FOR LATER
//account type enumeration
public enum SubCategories : String {
	case Hiker, WinterSports, Baseball, Basketball, Golf, Tennis, Soccer, Football, Boxing, MMA, Swimming, TableTennis, Gymnastics, Dancer, Rugby, Bowling, Frisbee, Cricket, SpeedBiking, MountainBiking, WaterSkiing, Running, PowerLifting, BodyBuilding, Wrestling, StrongMan, NASCAR, RalleyRacing, Parkour, Model, Makeup, Actor, RunwayModel, Designer, Brand, Stylist, HairStylist, FasionArtist, Painter, Sketcher, Musician, Band, SingerSongWriter
}

//Categories that house subCategories.
struct Categories {
	let Athletic: [SubCategories] = [.Hiker, .WinterSports, .Baseball, .Basketball, .Golf, .Tennis, .Soccer, .Football, .Boxing, .MMA, .Swimming, .TableTennis, .Gymnastics, .Dancer, .Rugby, .Bowling, .Frisbee, .Cricket, .SpeedBiking, .MountainBiking, .WaterSkiing, .Running, .PowerLifting, .BodyBuilding, .Wrestling, .StrongMan, .NASCAR, .RalleyRacing, .Parkour]
	let Fasion: [SubCategories] = [.Model, .Makeup, .Actor, .RunwayModel, .Designer, .Brand, .Stylist, .HairStylist, .FasionArtist, .Painter, .Sketcher, .Musician, .Band, .SingerSongWriter, .Dancer]
	let Photographer: [SubCategories] = []
}
