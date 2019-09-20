//
//  InstagramAPI.swift
//  Ambassadoor
//
//  Created by Chris Chomicki on 2/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import Foundation

struct API {
    static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
    static let INSTAGRAM_CLIENT_ID = "fa083c34de6847ff95db596d75ef1c31"
    static let INSTAGRAM_CLIENTSERCRET = "b81172265e6b417782fcf075e2daf2ff"
    static let INSTAGRAM_REDIRECT_URI = "https://ambassadoor.co/welcome"
    
    //Dwolla
    static let kDwollaClient_id = "CijOdBYNcHDSwXjkf4PnsXjHBYSgKdgc7TdfoDNUZiNvOPfAst"
    static let kDwollaClient_secret = "m8oCRchilXnkR3eFAKlNuQWFqv9zROJX0CkD5aiys1H3nmvQMb"
    static let kCreateCustomer = "https://api-sandbox.dwolla.com/customers"
    
    static var superBankFundingSource = "https://api-sandbox.dwolla.com/funding-sources/b23abf0b-c28d-4941-84af-617626865f2b"
    
    static var kFundTransferURL = "https://api-sandbox.dwolla.com/transfers"

    //naveen added
    //naveen login
    //"https://ambassdoor.com/welcome#access_token=3225555942.3a8760e.7a76cfffabb44e21bcc0db92dc10f7f8"
//    static let INSTAGRAM_CLIENT_ID = "a92e22c060e04281917b29a4120aadf3"
//    static let INSTAGRAM_CLIENTSERCRET = "42fc056dd5aa43bf9aacc9fc923df75c"
//    static let INSTAGRAM_REDIRECT_URI = "https://ambassadoor.com/welcome"
    
    static var INSTAGRAM_ACCESS_TOKEN = ""
    static let threeMonths: Double = 7889229
    static let INSTAGRAM_SCOPE = "public_content" /* add whatever scope you need https://www.instagram.com/developer/ */
    
    static var instagramProfileData: [String: AnyObject] = [:]
    
	static func getProfileInfo(completed: ((_ user: User?) -> () )?) {
        let url = URL(string: "https://api.instagram.com/v1/users/self/?access_token=" + INSTAGRAM_ACCESS_TOKEN)
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
			
			debugPrint("Downloading username data from instagram API")
			
            if err == nil {
                // check if JSON data is downloaded yet
                guard let jsondata = data else { return }
                do {
                    do {
                        // Deserilize object from JSON
                        if let profileData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
                            let meta = profileData["meta"] as! [String : AnyObject]
                            //naveen added code validation
                            let code = meta["code"] as! Int
                            if  code == 200{
                                self.instagramProfileData = profileData["data"] as! [String : AnyObject]
                                var userDictionary: [String: Any] = [
                                    "name": instagramProfileData["full_name"] as! String,
                                    "username": instagramProfileData["username"] as! String,
                                    "followerCount": instagramProfileData["counts"]?["followed_by"] as! Double,
                                    "profilePicture": instagramProfileData["profile_picture"] as! String,
                                    
                                    "primaryCategory": "", // need to get from user on account creation
                                    
                                    "zipCode": 0,
                                    
                                    "secondaryCategory": "",
                                    
                                    //naveen added
                                    "id": instagramProfileData["id"] as! String,
                                    "gender": "",
                                    "isBankAdded": false,
                                    "yourMoney": 0,
                                    "joinedDate": "",
                                    "categories": []
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
                                
                            }

                        }
                    }
                    // Wait for data to be retrieved before moving on
                    DispatchQueue.main.async {
						debugPrint("Deserialization Failed.")
						//completed?(nil)
                    }
                } catch {
                    print("JSON Downloading Error!")
                }
            }
        }.resume()
    }
    
    static func serializeUser(user: User, id: String) -> [String: Any] {
        let userData: [String: Any] = [
            "id": id,
            "name": user.name!,
            "username": user.username,
            "followerCount": user.followerCount,
            "profilePicture": user.profilePicURL!,
            "primaryCategory": user.primaryCategory.rawValue,
			"secondaryCategory": user.SecondaryCategory == nil ? "" : user.SecondaryCategory!.rawValue,
            "averageLikes": user.averageLikes ?? 0,
			"zipCode": user.zipCode as Any,
            "gender": user.gender == nil ? "" : user.gender!.rawValue,
            "isBankAdded": user.isBankAdded,
            "yourMoney": user.yourMoney,
            "joinedDate": user.joinedDate!,
            "categories": user.categories as AnyObject
        ]
        return userData
    }
    //naveen added
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
                                debugPrint(profilePictureURL)
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
    
    //naveen added func
    static func instaLogout(){
        let cookieJar : HTTPCookieStorage = HTTPCookieStorage.shared
        for cookie in cookieJar.cookies! as [HTTPCookie]{
//            print("cookie.domain = %@", cookie.domain)
            
            if cookie.domain == "www.instagram.com" ||
                cookie.domain == "api.instagram.com" || cookie.domain == ".instagram.com"{
                
                cookieJar.deleteCookie(cookie)
            }
        }
    }
    
    
    static func getInsight(completed: ((_ user: User?) -> () )?) {
        let url = URL(string: "https://api.instagram.com/v1/users/self/?access_token=" + INSTAGRAM_ACCESS_TOKEN)
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
            
            debugPrint("Downloading username data from instagram API")
            
            if err == nil {
                // check if JSON data is downloaded yet
                guard let jsondata = data else { return }
                do {
                    do {
                        // Deserilize object from JSON
                        if let profileData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
                            let meta = profileData["meta"] as! [String : AnyObject]
                            //naveen added code validation
                            let code = meta["code"] as! Int
                            if  code == 200{
                                self.instagramProfileData = profileData["data"] as! [String : AnyObject]
                                var userDictionary: [String: Any] = [
                                    "name": instagramProfileData["full_name"] as! String,
                                    "username": instagramProfileData["username"] as! String,
                                    "followerCount": instagramProfileData["counts"]?["followed_by"] as! Double,
                                    "profilePicture": instagramProfileData["profile_picture"] as! String,
                                    
                                    "primaryCategory": "", // need to get from user on account creation
                                    
                                    "zipCode": "0",
                                    
                                    "secondaryCategory": "",
                                    
                                    //naveen added
                                    "id": instagramProfileData["id"] as! String,
                                    "gender": ""
                                ]
                                debugPrint("Done Creating Userinfo dictinary")
                                getAverageLikesOfUser(instagramId: instagramProfileData["id"] as! String, completed: { (averageLikes: Double?) in
                                    DispatchQueue.main.async {
                                        debugPrint("Got Average Likes of User.")
                                        userDictionary["averageLikes"] = averageLikes
                                        let user = User(dictionary: userDictionary)
                                        completed?(user)
                                    }
                                })
                            }else{
                                
                            }
                            
                        }
                    }
                    // Wait for data to be retrieved before moving on
                    DispatchQueue.main.async {
                        debugPrint("Deserialization Failed.")
                        //completed?(nil)
                    }
                } catch {
                    print("JSON Downloading Error!")
                }
            }
        }.resume()
    }
    
}
