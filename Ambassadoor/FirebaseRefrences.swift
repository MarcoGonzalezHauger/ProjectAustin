//
//  FirebaseRefrences.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/21/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

//Gets all offers relavent to the user.
func GetOffers() -> [Offer] {
	var fakeoffers : [Offer] = []
	for x : Double in [50, 1245, 28421, 812472, 12581238, 40, 240, 7029] {
		fakeoffers.append(Offer.init(money: 23, company: Company.init(name: "Pharoah Attire", logo: nil, mission: "Inspire confidence.", website: "https://pharaohattirestore.com", account_ID: "", instagram_name: "@pharaoh_attire", description: "Based out a New York, a company that creates shirts and apparel that inspires confidence."), posts: [Post.init(image: nil, instructions: "Post an image using a pharoah attire shirt", caption: nil, products: [Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: ""), Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: ""), Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: "")], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: Bool.random()), Post.init(image: nil, instructions: "Post an image to your story with a pharoah attire shirt and mention there is a sale.", caption: nil, products: [Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: "")], post_ID: "", PostType: .Story, confirmedSince: nil, isConfirmed: Bool.random())], offerdate: Date().addingTimeInterval(x * -1), offer_ID: "", expiredate: Date(timeIntervalSinceNow: x / 4), allPostsConfrimedSince: nil, isAccepted: Bool.random()))
	}
	return fakeoffers
}

//Gets all relavent people, people who you are friends and a few random people to compete with.
func GetRelevantPeople() -> [User] {
	var userslist : [User] = []
	for _ : Int in (1...75) {
		for x : SubCategories in [.Hiker, .WinterSports, .Baseball, .Basketball, .Golf, .Tennis, .Soccer, .Football, .Boxing, .MMA, .Swimming, .TableTennis, .Gymnastics, .Dancer, .Rugby, .Bowling, .Frisbee, .Cricket, .SpeedBiking, .MountainBiking, .WaterSkiing, .Running, .PowerLifting, .BodyBuilding, .Wrestling, .StrongMan, .NASCAR, .RalleyRacing, .Parkour, .Model, .Makeup, .Actor, .RunwayModel, .Designer, .Brand, .Stylist, .HairStylist, .FasionArtist, .Painter, .Sketcher, .Musician, .Band, .SingerSongWriter, .WinterSports] {
			userslist.append(User.init(name: nil, username: "@defaultuser\(Int.random(in: 50...300))", followerCount: Double(Int.random(in: 10...10000) << 2), profilePicture: nil, AccountType: x))
		}
	}
	return userslist
}
