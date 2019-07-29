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
	let fakeproduct = Product.init(image: "https://haveaseat.com.au/wp-content/uploads/2016/10/nardi_3052.jpg", name: "This Cool Chair", price: 20, buy_url: "https://haveaseat.com.au/bora-armchair/", color: "Any", product_ID: "")
	let fakecompany = Company.init(name: "The Chair Company", logo: "https://freefuninaustin.com/wp-content/uploads/sites/52/2018/03/theabyss-300x300.png", mission: "You might want to sit down for this", website: "https://www.athome.com/", account_ID: "", instagram_name: "", description: "The Chair Company of the Future")
    
//	for _ : Int in 0...30 {
//		let x = pow(Double(Int.random(in: 3...120)), 4)
//		fakeoffers.append(Offer.init(dictionary: ["money": Double.random(in: 10...40) as AnyObject, "company": fakecompany as AnyObject, "posts": [Post.init(image: nil, instructions: "Post an image using a pharoah attire shirt", captionMustInclude: nil, products: [fakeproduct, fakeproduct, fakeproduct], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: Bool.random()), Post.init(image: nil, instructions: "Post an image to your story with a pharoah attire shirt and mention there is a sale.", captionMustInclude: nil, products: [fakeproduct], post_ID: "", PostType: .Story, confirmedSince: nil, isConfirmed: Bool.random())] as AnyObject, "offerdate": Date().addingTimeInterval(x * -1) as AnyObject, "offer_ID": "fakeOffer\(Int.random(in: 1...9999999))" as AnyObject, "expiredate": Date(timeIntervalSinceNow: x / 4) as AnyObject, "allPostsConfirmedSince": "" as AnyObject, "isAccepted": Bool.random() as AnyObject]))
//	}
    
    fakeoffers.append(Offer.init(dictionary: ["money": Double.random(in: 10...40) as AnyObject, "company": fakecompany as AnyObject, "posts": [Post.init(image: nil, instructions: "Post an image using a pharoah attire shirt", captionMustInclude: nil, products: [fakeproduct, fakeproduct, fakeproduct], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: Bool.random()), Post.init(image: nil, instructions: "Post an image to your story with a pharoah attire shirt and mention there is a sale.", captionMustInclude: nil, products: [fakeproduct], post_ID: "", PostType: .Story, confirmedSince: nil, isConfirmed: Bool.random())] as AnyObject, "offerdate": Date.yesterday - 6 as AnyObject, "offer_ID": "fakeOffer1)" as AnyObject, "expiredate": Date.tomorrow as AnyObject, "allPostsConfirmedSince": "" as AnyObject,"isAccepted": true as AnyObject]))
    fakeoffers.append(Offer.init(dictionary: ["money": Double.random(in: 10...40) as AnyObject, "company": fakecompany as AnyObject, "posts": [Post.init(image: nil, instructions: "Post an image using a pharoah attire shirt", captionMustInclude: nil, products: [fakeproduct, fakeproduct, fakeproduct], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: Bool.random()), Post.init(image: nil, instructions: "Post an image to your story with a pharoah attire shirt and mention there is a sale.", captionMustInclude: nil, products: [fakeproduct], post_ID: "", PostType: .Story, confirmedSince: nil, isConfirmed: Bool.random())] as AnyObject, "offerdate": Date.yesterday - 5 as AnyObject, "offer_ID": "fakeOffer2)" as AnyObject, "expiredate": Date.tomorrow as AnyObject, "allPostsConfirmedSince": "" as AnyObject,"isAccepted": false as AnyObject]))
    
    return fakeoffers
}

//Gets all relavent people, people who you are friends and a few random people to compete with.
func GetRandomTestUsers() -> [User] { 
	var userslist : [User] = []
	for _ : Int in (1...Int.random(in: 1...50)) {
		for x : Category in [.Hiker, .WinterSports, .Baseball, .Basketball, .Golf, .Tennis, .Soccer, .Football, .Boxing, .MMA, .Swimming, .TableTennis, .Gymnastics, .Dancer, .Rugby, .Bowling, .Frisbee, .Cricket, .SpeedBiking, .MountainBiking, .WaterSkiing, .Running, .PowerLifting, .BodyBuilding, .Wrestling, .StrongMan, .NASCAR, .RalleyRacing, .Parkour, .Model, .Makeup, .Actor, .RunwayModel, .Designer, .Brand, .Stylist, .HairStylist, .FasionArtist, .Painter, .Sketcher, .Musician, .Band, .SingerSongWriter, .WinterSports] {
			userslist.append(User.init(dictionary: ["name": GetRandomName() as AnyObject, "username": getRandomUsername() as AnyObject, "followerCount": Double(Int.random(in: 10...1000) << 2) as AnyObject, "profilePicture": "https://scontent-lga3-1.cdninstagram.com/vp/60d965d5d78243bd600e899ceef7b22e/5D03F5A8/t51.2885-19/s150x150/16123627_1826526524262048_8535256149333639168_n.jpg?_nc_ht=scontent-lga3-1.cdninstagram.com" as  AnyObject, "primaryCategory": x as AnyObject, "averageLikes": pow(Double(Int.random(in: 1...1000)), 2) as AnyObject, "id": "" as AnyObject]))
		}
	}
	userslist.append(User.init(dictionary: ["name": "The guy I'm looking for" as AnyObject, "username": "GuyImLooking4" as AnyObject, "followerCount": Double(Int.random(in: 10...1000) << 2) as AnyObject, "profilePicture": "https://st2.depositphotos.com/1061700/10161/v/950/depositphotos_101612710-stock-illustration-question-mark-icon-vector-illustration.jpg" as  AnyObject, "primaryCategory": Category.Parkour as AnyObject, "averageLikes": Double(Int.random(in: 1...1000) << 2) as AnyObject, "id": "" as AnyObject]))
	return userslist
}

func GetRandomName() ->  String {
	return "\(Int.random(in: 0...9))BrunoG\(Int.random(in: 100...9999))"
}

func getRandomUsername() -> String {
	return "brunogonzalezhauger"
}

//Creates an account with nothing more than the username of the account. Returns instance of account returned from firebase
func CreateAccount(instagramUser: User) -> User {
    // Pointer reference in Firebase to Users
    let ref = Database.database().reference().child("users")
    // Boolean flag to keep track if user is already in database
    var alreadyRegistered: Bool = false
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        print(snapshot.childrenCount)
        for case let user as DataSnapshot in snapshot.children {
            if (user.childSnapshot(forPath: "username").value as! String == instagramUser.username) {
                alreadyRegistered = true
            }
        }
    })
    if alreadyRegistered {
        return instagramUser
    } else {
        let userReference = ref.childByAutoId()
        let userData = API.serializeUser(user: instagramUser, id: userReference.key!)
        userReference.updateChildValues(userData)
        return instagramUser
    }
}

// Query all users in Firebase and to do filtering based on algorithm
//func GetAllUsers() -> [User] {
//    let usersRef = Database.database().reference().child("users")
//    var users: [User] = []
//    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
//        if let dictionary = snapshot.value as? [String: AnyObject] {
//            for (_, user) in dictionary{
//                let userDictionary = user as? NSDictionary
//                let userInstance = User(dictionary: userDictionary! as! [String : AnyObject])
//                users.append(userInstance)
//                global.SocialData.append(userInstance)
//            }
//        }
//    }, withCancel: nil)
//    return users
//}

//naveen added func
func GetAllUsers(completion:@escaping (_ result: [User])->())  {
    let usersRef = Database.database().reference().child("users")
    var users: [User] = []
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            for (_, user) in dictionary{
                let userDictionary = user as? NSDictionary
                let userInstance = User(dictionary: userDictionary! as! [String : AnyObject])
                users.append(userInstance)
            }
            completion(users)
        }
    }, withCancel: nil)
}
