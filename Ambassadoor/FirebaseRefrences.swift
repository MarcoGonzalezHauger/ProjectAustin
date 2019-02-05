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
func GetOffers(userId: String, ref: DatabaseReference) -> [Offer] {
    let ref = ref.child("offers")
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

func GetFakeOffers() -> [Offer] {
    var fakeoffers : [Offer] = []
    for x : Double in [50, 1245, 28421, 812472, 12581238, 40, 240, 7029] {
        fakeoffers.append(Offer.init(dictionary: ["money": 23 as AnyObject, "company": Company.init(name: "Pharoah Attire", logo: nil, mission: "Inspire confidence.", website: "https://pharaohattirestore.com", account_ID: "", instagram_name: "@pharaoh_attire", description: "Based out a New York, a company that creates shirts and apparel that inspires confidence.") as AnyObject, "posts": [Post.init(image: nil, instructions: "Post an image using a pharoah attire shirt", caption: nil, products: [Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: ""), Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: ""), Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: "")], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: Bool.random()), Post.init(image: nil, instructions: "Post an image to your story with a pharoah attire shirt and mention there is a sale.", caption: nil, products: [Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: "")], post_ID: "", PostType: .Story, confirmedSince: nil, isConfirmed: Bool.random())] as AnyObject, "offerdate": Date().addingTimeInterval(x * -1) as AnyObject, "offer_ID": "" as AnyObject, "expiredate": Date(timeIntervalSinceNow: x / 4) as AnyObject, "allPostsConfirmedSince": "" as AnyObject, "isAccepted": Bool.random() as AnyObject]))
    }
    return fakeoffers
}

//Gets all relavent people, people who you are friends and a few random people to compete with.
func GetRelevantPeople() -> [User] {
	var userslist : [User] = []
	for _ : Int in (1...Int.random(in: 1...50)) {
		for x : SubCategories in [.Hiker, .WinterSports, .Baseball, .Basketball, .Golf, .Tennis, .Soccer, .Football, .Boxing, .MMA, .Swimming, .TableTennis, .Gymnastics, .Dancer, .Rugby, .Bowling, .Frisbee, .Cricket, .SpeedBiking, .MountainBiking, .WaterSkiing, .Running, .PowerLifting, .BodyBuilding, .Wrestling, .StrongMan, .NASCAR, .RalleyRacing, .Parkour, .Model, .Makeup, .Actor, .RunwayModel, .Designer, .Brand, .Stylist, .HairStylist, .FasionArtist, .Painter, .Sketcher, .Musician, .Band, .SingerSongWriter, .WinterSports] {
			userslist.append(User.init(name: nil, username: "@defaultuser\(Int.random(in: 50...300))", followerCount: Double(Int.random(in: 10...10000) << 2), profilePicture: nil, AccountType: x))
		}
	}
	return userslist
}

//Creates an account with nothing more than the username of the account. Returns Bool to see if it worked.
func CreateAccount(instagramUsername username: String, ref: DatabaseReference) -> Bool {
    // Pointer reference in Firebase to Users
    let ref = ref.child("users")
    let userReference = ref.childByAutoId()
    // Test data for now, all of the other data will be fetched from the Instagram API besides username which will come directly from the user
    let values = [
        "name": "Chris Chomicki", //test
        "username": username,     //from USER
        "followerCount": 99,      //test
        "profilePicture": "",     //test
        "AccountType": SubCategoryToString(subcategory: SubCategories.BodyBuilding),  //from USER
        ] as [String : Any]
    userReference.updateChildValues(values)
	return true
}
