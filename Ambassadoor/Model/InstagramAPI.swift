//
//  InstagramAPI.swift
//  Ambassadoor
//
//  Created by Chris Chomicki on 2/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import Foundation
import WebKit

struct API {
    //instagram base url and secret key's
    static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
    static let INSTAGRAM_CLIENT_ID = "fa083c34de6847ff95db596d75ef1c31"
    static let INSTAGRAM_CLIENTSERCRET = "b81172265e6b417782fcf075e2daf2ff"
    static let INSTAGRAM_REDIRECT_URI = "https://ambassadoor.co/welcome"
    static let INSTAGRAM_REDIRECT_URI2 = "https://www.ambassadoor.co/welcome"
    
    //Dwolla account information Note: currently not using dwolla
    static let kDwollaClient_id = "CijOdBYNcHDSwXjkf4PnsXjHBYSgKdgc7TdfoDNUZiNvOPfAst"
    static let kDwollaClient_secret = "m8oCRchilXnkR3eFAKlNuQWFqv9zROJX0CkD5aiys1H3nmvQMb"
    static let kCreateCustomer = "https://api-sandbox.dwolla.com/customers"
    static var superBankFundingSource = "https://api-sandbox.dwolla.com/funding-sources/b23abf0b-c28d-4941-84af-617626865f2b"
    static var kFundTransferURL = "https://api-sandbox.dwolla.com/transfers"
    
    
    //Stripe account live and demo client ID and secret ID
    //Live
    static var Stripeclient_id = "ca_FrDIP5fLBXnTWCJTkPzngRUquWqrzKZh"
    static var Stripeclient_secret = "sk_live_KwcqGxImMq4fosE3n7QMycBw00eMO7si8E"
    //demo
//    static var Stripeclient_id = "ca_FrDIyMuhEQEpU7K8z6tsPNMwKJ2f6AiM"
//    static var Stripeclient_secret = "sk_test_zrg6oDehYkCJIVAA4oe5LrWD00mNP6IImr"

    
    //get instagram users media
    static let INSTAGRAM_getMedia = "https://api.instagram.com/v1/users/self/media/recent/?access_token="
    static var instagramMediaData: [[String: AnyObject]] = []

    
    static var INSTAGRAM_ACCESS_TOKEN = ""
    static let threeMonths: Double = 7889229
    static let INSTAGRAM_SCOPE = "basic" /* add whatever scope you need https://www.instagram.com/developer/ */
    
    
    // Get user information from instagram using login access token
    static var instagramProfileData: [String: AnyObject] = [:]
    
	static func getProfileInfo(completed: ((_ user: User?) -> () )?) {
        let url = URL(string: "https://api.instagram.com/v1/users/self/?access_token=" + INSTAGRAM_ACCESS_TOKEN)
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
			
			print("GetProfileInfo: Downloading username data from instagram API")
			
            if err == nil {
                // check if JSON data is downloaded yet
                guard let jsondata = data else { return }
                do {
                    do {
                        // Deserilize object from JSON
                        if let profileData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {

                            if let codelimit = profileData["code"] as? Int64 {
                                completed?(nil)
                            }else{
                                let meta = profileData["meta"] as! [String : AnyObject]
                                //naveen added code validation
                                let code = meta["code"] as! Int
                                if  code == 200 {
									print("code was 200.")
                                    self.instagramProfileData = profileData["data"] as! [String : AnyObject]
                                    var userDictionary: [String: Any] = [
                                        "name": instagramProfileData["full_name"] as! String,
                                        "username": instagramProfileData["username"] as! String,
                                        "followerCount": instagramProfileData["counts"]?["followed_by"] as! Double,
                                        "profilePicture": instagramProfileData["profile_picture"] as! String,
                                        "zipCode": 0,
                                        "id": instagramProfileData["id"] as! String,
                                        "gender": "",
                                        "isBankAdded": false,
                                        "yourMoney": 0.0,
                                        "joinedDate": "",
                                        "categories": [],
                                        "referralcode": "",
                                        "isDefaultOfferVerify": false,
                                        "lastPaidOSCDate": "",
                                        "priorityValue": 0,
                                        "authenticationToken": INSTAGRAM_ACCESS_TOKEN
                                    ]
                                    debugPrint("Done Creating Userinfo dictinary")
                                    getAverageLikesOfUser(instagramId: instagramProfileData["id"] as! String, completed: { (averageLikes: Double?) in
                                        DispatchQueue.main.async {
                                            debugPrint("Got Average Likes of User.")
                                            userDictionary["averageLikes"] = averageLikes
                                            let user = User(dictionary: userDictionary)
                                            DispatchQueue.main.async {
                                                UserDefaults.standard.set(user.id, forKey: "userid")

                                            completed?(user)
                                            }
                                        }
                                    })
                                }else{
									print("\(code): \(meta["error_type"] as! String)\n\(meta["error_message"] as! String)")
									print("code was not 200.")
                                }
                            }

                        }
                    }
                    // Wait for data to be retrieved before moving on
                    DispatchQueue.main.async {
						print("Deserialization Failed.")
						//completed?(nil)
                    }
                } catch {
                    print("JSON Downloading Error!")
                }
            }
        }.resume()
    }
    
    //get instagram user recent media post data
    static func getRecentMedia(completed: ((_ mediaData: [[String: Any]]?) -> () )?) {
        let url = URL(string: "https://api.instagram.com/v1/users/self/media/recent/?access_token=" + INSTAGRAM_ACCESS_TOKEN)
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
            
            print("GetRecentMedia: Downloading username data from instagram API")
            
            if err == nil {
                // check if JSON data is downloaded yet
				guard let jsondata = data else { return }
				do {
					do {
						// Deserilize object from JSON
						if let totalData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
							if let meta = totalData["meta"] as? [String : AnyObject] {
								//naveen added code validation
								let code = meta["code"] as! Int
								if  code == 200{
									self.instagramMediaData = totalData["data"] as! [[String : AnyObject]]
									completed?(self.instagramMediaData)
								}
							}
							
						}
					}
					// Wait for data to be retrieved before moving on
					DispatchQueue.main.async {
						print("Deserialization Failed.")
						//completed?(nil)
					}
                } catch {
                    print("JSON Downloading Error!")
                }
            }
        }.resume()
    }
    
    
    // change User detail class object to json value
    static func serializeUser(user: User, id: String) -> [String: Any] {
        let userData: [String: Any] = [
            "id": id,
            "name": user.name!,
            "username": user.username,
            "followerCount": user.followerCount,
            "profilePicture": user.profilePicURL!,
            "averageLikes": user.averageLikes ?? 0,
			"zipCode": user.zipCode as Any,
            "gender": user.gender == nil ? "" : user.gender!.rawValue,
            "isBankAdded": user.isBankAdded,
            "yourMoney": user.yourMoney,
            "joinedDate": user.joinedDate!,
            "categories": user.categories as AnyObject,
            "referralcode": user.referralcode,
            "isDefaultOfferVerify": user.isDefaultOfferVerify,
            "lastPaidOSCDate": user.lastPaidOSCDate,
            "priorityValue": user.priorityValue,
            "authenticationToken": user.authenticationToken,
            "tokenFIR":global.deviceFIRToken
        ]
        return userData
    }
    
    // change bank detail class object to json value
    static func serializeBank(bank: Bank) -> [String: Any] {
        let bankData: [String: Any] = [
            "publicToken": bank.publicToken,
            "institutionName": bank.institutionName,
            "institutionID": bank.institutionID,
            "acctID": bank.acctID,
            "acctName": bank.acctName,
        ]
        return bankData
    }
    
    //Get user profile pic from instagram
    static func getProfilePictureURL(userId: String) -> String {
        let url = URL(string: "https://api.instagram.com/v1/users/" + userId + "/?access_token=" + INSTAGRAM_ACCESS_TOKEN)
        var profilePictureURL = ""
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
            if err == nil {
                // check if JSON data is downloaded yet
                guard let jsondata = data else { return }
                do {
                    do {
                        // Deserilize object from JSON
                        if let profileData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
                            if let data = profileData["data"] {
                                profilePictureURL = data["profile_picture"] as! String
                                print(profilePictureURL)
                            }
                        }
                    }
                } catch {
                    print("JSON Downloading Error!")
                }
            }
        }.resume()
        return profilePictureURL
    }
    
    // Computes the average amount of likes on the 5 latest posts or the average of the posts in the last 3 months if more
	static func getAverageLikesOfUser(instagramId: String, completed: @escaping (_ averageLikes: Double?) -> ()) {
        let url = URL(string: "https://api.instagram.com/v1/users/" + String(instagramId) + "/media/recent?access_token=" + INSTAGRAM_ACCESS_TOKEN)
        let currentTime = NSDate().timeIntervalSince1970
        var count = 0
        var average = 0
		var averageLikes: Double?
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
            if err == nil {
                // check if JSON data is downloaded yet
                guard let jsondata = data else { return }
                do {
                    do {
                        // Deserilize object from JSON
                        if let postData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String: AnyObject] {
                            if let data = postData["data"] {
                                // Go through posts and check to see if they're less than 3 months old
                                for post in data as! [AnyObject] {
                                    if let createdTime = post["created_time"] as? String {
                                        let createdTimeDouble = Double(createdTime)!
                                        if (createdTimeDouble > (currentTime - threeMonths) || count <= 5 ) {
                                            let likes = post["likes"] as AnyObject
                                            let likesCount = likes["count"] as! Int
                                            average += likesCount
                                            count += 1
                                        }
                                    }
                                }
								averageLikes = count >= 5 ? round(Double(average / count)) : nil
                            }
                        }
                        DispatchQueue.main.async {
                            completed(averageLikes)
                        }
                    }
                } catch {
                    print("JSON Downloading Error! in Average Likes Of User Function.")
                }
            }
        }.resume()
    }
    
    // Logout instagram token
    static func instaLogout(){
        let dataStore = WKWebsiteDataStore.default()
		dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
			for record in records {
				if record.displayName.contains("instagram") {
					dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record], completionHandler: {
						print("Deleted: " + record.displayName);
					})
				}
			}
		}
    }
    
    
    static func serializeDefaultOffer(offerID: String, postID:String, userID: String) -> [String: Any] {
        var posts: [[String: Any]] = [[String: Any]]()
        let post: [String:Any] = [
            "PostType":"Single Post",
            "hashtags": ["Ambassadoor"],
			"keywords": [],
            "confirmedSince":"",
            "hashCaption":"",
            "image":"",
            "instructions":"Create a picture and post it to instagram. It can be of anything.",
            "isConfirmed":false,
            "post_ID":postID,
            "products":[]
            ]
        posts.append(post)
                        
        let offerData: [String: Any] = [
            "allConfirmed": false,
            "allPostsConfirmedSince": "",
            "category":[],
            "company": "company1",
            "expiredate": Date.getStringFromDate(date: Date().afterDays(day: 365*1000)) as Any ,
            "genders":["All"] as Any,
            "isAccepted": false,
            "isExpired": false,
            "money": 0.0,
            "offer_ID": offerID,
            "offerdate": getStringFromTodayDate(),
            "ownerUserID": "-XXXDefault",
            "posts": posts,
            "status": "available",
            "targetCategories": [],
            "title": "Default Offer",
            "user_IDs": [userID] as Any,
            "zipCodes": [],
            ]
        return offerData
    }
    
    static func serializeInfluencerAuthentication(details: NewAccountInfo) -> [String: Any]{
        
        let offerData: [String: Any] = [
        "email":details.email,
        "password":details.password,
        "userid":details.id,
        "createdAt":Date.getCurrentDate(),
        "Signed In":Date.getCurrentDate(),
        "username":details.instagramUsername
        ]
        return offerData
    }
    
    static func serializeRawUserData(details: NewAccountInfo) -> [String: Any]{
        let userData: [String: Any] = [
            "id": details.id,
            "name": details.instagramName,
            "username": details.instagramUsername,
            "followerCount": details.followerCount,
            "profilePicture": details.profilePicture,
            "averageLikes": details.averageLikes,
            "zipCode": details.zipCode,
            "gender": details.gender,
            "isBankAdded": false,
            "yourMoney": 0.0,
            "joinedDate": Date.getCurrentDate(),
            "categories": details.categories,
            "referralcode": details.referralCode,
            "isDefaultOfferVerify": false,
            "lastPaidOSCDate": "",
            "priorityValue": 0,
            "authenticationToken": details.authenticationToken,
            "tokenFIR":global.deviceFIRToken
        ]
        return userData
    }
    
}
