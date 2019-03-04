//
//  FirebaseRefrences.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/21/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import Foundation
import Firebase

//Gets all offers relavent to the user via Firebase
func GetOffers(userId: String) -> [Offer] {
    let ref = Database.database().reference().child("offers")
    let offersRef = ref.child(userId)
    var offers: [Offer] = []
    offersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            for (_, offer) in dictionary{
                let offerDictionary = offer as? NSDictionary
                let offerInstance = Offer(dictionary: offerDictionary! as! [String : AnyObject])
                offers.append(offerInstance)
            }
        }
    }, withCancel: nil)
    return offers
}

//Creates the offer and returns the newly created offer as an Offer instance
func CreateOffer() -> Offer {
    let ref = Database.database().reference().child("offers")
    let offerRef = ref.childByAutoId()
    /*
    let values = [
        "money": 0
        "company": Company,
        "posts": [Post],
        "offerdate": Date,
        "offer_ID": String,
        "expiredate": Date,
        "allPostsConfrimedSince": Date?,
        "allConfirmed": Bool,
        "areConfirmed": Bool,
        "isAccepted": Bool,
        "isExpired": Bool,
        ] as [String : Any]
 */
    let values: [String: AnyObject] = [:]
    offerRef.updateChildValues(values)
    var offerInstance = Offer(dictionary: [:])
    offerRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            offerInstance = Offer(dictionary: dictionary)
        }
    }, withCancel: nil)
    return offerInstance
}

func GetFakeOffers() -> [Offer] {
    var fakeoffers : [Offer] = []
	for _ : Int in 0...30 {
		let x = Double(Int.random(in: 3...120) << 3)
        fakeoffers.append(Offer.init(dictionary: ["money": 23 as AnyObject, "company": Company.init(name: "Pharoah Attire", logo: nil, mission: "Inspire confidence.", website: "https://pharaohattirestore.com", account_ID: "", instagram_name: "pharaoh_attire", description: "Based out a New York, a company that creates shirts and apparel that inspires confidence.") as AnyObject, "posts": [Post.init(image: nil, instructions: "Post an image using a pharoah attire shirt", captionMustInclude: nil, products: [Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: ""), Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: ""), Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: "")], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: Bool.random()), Post.init(image: nil, instructions: "Post an image to your story with a pharoah attire shirt and mention there is a sale.", captionMustInclude: nil, products: [Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: "")], post_ID: "", PostType: .Story, confirmedSince: nil, isConfirmed: Bool.random())] as AnyObject, "offerdate": Date().addingTimeInterval(x * -1) as AnyObject, "offer_ID": "" as AnyObject, "expiredate": Date(timeIntervalSinceNow: x / 4) as AnyObject, "allPostsConfirmedSince": "" as AnyObject, "isAccepted": Bool.random() as AnyObject]))
	}
    return fakeoffers
}

//Gets all relavent people, people who you are friends and a few random people to compete with.
func GetRandomTestUsers() -> [User] { 
	var userslist : [User] = []
	for _ : Int in (1...Int.random(in: 1...50)) {
		for x : Category in [.Hiker, .WinterSports, .Baseball, .Basketball, .Golf, .Tennis, .Soccer, .Football, .Boxing, .MMA, .Swimming, .TableTennis, .Gymnastics, .Dancer, .Rugby, .Bowling, .Frisbee, .Cricket, .SpeedBiking, .MountainBiking, .WaterSkiing, .Running, .PowerLifting, .BodyBuilding, .Wrestling, .StrongMan, .NASCAR, .RalleyRacing, .Parkour, .Model, .Makeup, .Actor, .RunwayModel, .Designer, .Brand, .Stylist, .HairStylist, .FasionArtist, .Painter, .Sketcher, .Musician, .Band, .SingerSongWriter, .WinterSports] {
			userslist.append(User.init(dictionary: ["name": GetRandomName() as AnyObject, "username": getRandomUsername() as AnyObject, "followerCount": Double(Int.random(in: 10...1000) << 2) as AnyObject, "profilePicture": "https://scontent-lga3-1.cdninstagram.com/vp/60d965d5d78243bd600e899ceef7b22e/5D03F5A8/t51.2885-19/s150x150/16123627_1826526524262048_8535256149333639168_n.jpg?_nc_ht=scontent-lga3-1.cdninstagram.com" as  AnyObject, "AccountType": x as AnyObject, "averageLikes": Double(Int.random(in: 1...1000) << 2) as AnyObject, "id": "" as AnyObject]))
		}
	}
	userslist.append(User.init(dictionary: ["name": "The guy I'm looking for" as AnyObject, "username": "GuyImLooking4" as AnyObject, "followerCount": Double(Int.random(in: 10...1000) << 2) as AnyObject, "profilePicture": "https://st2.depositphotos.com/1061700/10161/v/950/depositphotos_101612710-stock-illustration-question-mark-icon-vector-illustration.jpg" as  AnyObject, "AccountType": Category.Parkour as AnyObject, "averageLikes": Double(Int.random(in: 1...1000) << 2) as AnyObject, "id": "" as AnyObject]))
	return userslist
}

func GetRandomName() ->  String {
	return "\(Int.random(in: 0...9))BrunoG\(Int.random(in: 100...9999))"
}

func getRandomUsername() -> String {
	return "brunogonzalezhauger"
}

//Creates an account with nothing more than the username of the account. Returns instance of account returned from firebase
func CreateAccount(instagramUsername username: String) -> User {
    // Pointer reference in Firebase to Users
    let ref = Database.database().reference().child("users")
    let userReference = ref.childByAutoId()
    // Test data for now, all of the other data will be fetched from the Instagram API besides username which will come directly from the user
    let values = [
        "name": "Chris Chomicki", //test
        "username": username,     //from USER
        "followerCount": 99,      //test
        "profilePicture": "",     //test
        "AccountType": Category.BodyBuilding.rawValue  //from USER
        ] as [String : Any]
    userReference.updateChildValues(values)
    var userInstance: User = User(dictionary: [:])
    userReference.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            userInstance = User(dictionary: dictionary)
        }
    }, withCancel: nil)
	return userInstance
}
