//
//  InstagramAPI.swift
//  Ambassadoor
//
//  Created by Chris Chomicki on 2/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import Foundation
import WebKit

struct API {
    /*
     //instagram base url and secret key's
     static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
     static let INSTAGRAM_CLIENT_ID = "fa083c34de6847ff95db596d75ef1c31"
     static let INSTAGRAM_CLIENTSERCRET = "b81172265e6b417782fcf075e2daf2ff"
     static let INSTAGRAM_REDIRECT_URI = "https://ambassadoor.co/welcome"
     static let INSTAGRAM_REDIRECT_URI2 = "https://www.ambassadoor.co/welcome"
     */
    
    static let privacyUrl = "https://www.ambassadoor.co/privacy-policy"
    static let termsUrl = "https://www.ambassadoor.co/terms-of-service"
    static let supportEmail = "support@ambassadoor.co"
    
    static var isForTesting = false
    static let shouldAboveVersion = "2.0.0"
    
    static let INSTAGRAM_CREATOR_HELP = "https://help.instagram.com/2358103564437429"
    static let INSTAGRAM_BUSINESS_HELP = "https://help.instagram.com/502981923235522?helpref=hc_fnav"
    static let FB_PAGE_HELP = "https://www.facebook.com/help/104002523024878"
    
    static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
    //static let INSTAGRAM_CLIENT_ID = "fa083c34de6847ff95db596d75ef1c31"
    static let INSTAGRAM_CLIENT_ID = "177566490238866"
    //static let INSTAGRAM_CLIENTSERCRET = "b81172265e6b417782fcf075e2daf2ff"
    static let INSTAGRAM_CLIENTSERCRET = "7ef91a8ef559a42d72562d3a9b210275"
    static let INSTAGRAM_REDIRECT_URI = "https://www.ambassadoor.co/"
    //static let INSTAGRAM_REDIRECT_URI = "https://ambassadoor.co/welcome"
    static let INSTAGRAM_REDIRECT_URI2 = "https://www.ambassadoor.co/welcome"
    
    static let FACEBOOK_CLIENT_ID = "1802052916593320"
    static let FACEBOOK_CLIENTSERCRET = "933711de6744e652f5bbf00ec53b36cc"
    
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
    static var instagramMediaID: [String] = [String]()
    
    static var INSTAGRAM_ACCESS_TOKEN = ""
    static let threeMonths: Double = 7889229
    static let INSTAGRAM_SCOPE = "basic" /* add whatever scope you need https://www.instagram.com/developer/ */
    
    
    // Get user information from instagram using login access token
    static var instagramProfileData: [String: AnyObject] = [:]
    
    
    static func getProfileInfo(userId: String,completed: ((_ businessuser: Bool) -> () )?) {
        
        
        let url = URL(string: "https://graph.instagram.com/\(userId)?fields=id,username,media_count,account_type&access_token=" + INSTAGRAM_ACCESS_TOKEN)
        //        let url = URL(string: "https://graph.instagram.com/me/media?fields=id,caption,media_type,media_url,permalink,thumbnail_url,timestamp,username&access_token=" + INSTAGRAM_ACCESS_TOKEN)
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
            
            print("GetProfileInfo: Downloading username data from instagram API")
            
            if err == nil {
                // check if JSON data is downloaded yet
                guard let jsondata = data else { return }
                do {
                    do {
                        // Deserilize object from JSON
                        if let profileData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
                            
                            if let business = profileData["account_type"] as? String{
                                
                                if business == "BUSINESS"{
                                    
                                    completed!(true)
                                    
                                }else{
                                    completed!(false)
                                }
                                
                            }else{
                                completed!(false)
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
    
    static func getInstagramAccessToken(params: [String: AnyObject],appendedURI: String,completion:@escaping(String,String,Int64)-> Void){
        
        let urlString = "https://api.instagram.com/oauth/access_token"
        
        let url = URL(string: urlString)!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "Post"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type");
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        request.httpBody = appendedURI.data(using: .utf8)
        
        //        do {
        //            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        //        } catch let error {
        //            print(error.localizedDescription)
        //        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("result=",dataString!)
                do {
                    
                    if let accDetail = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any] {
                        
                        let accessToken = accDetail["access_token"] as! String
                        
                        let userID = accDetail["user_id"] as! Int64
                        
                        completion("success", accessToken, userID)
                        
                    }
                    
                }catch let error {
                    
                    
                    
                }
            }
            
        }
        task.resume()
    }
    
    //get instagram user recent media post data
    /*
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
     "tokenFIR":global.deviceFIRToken,
     "following":[],
     "businessFollowing":[],
     "email":details.email
     */
    

    
    // change bank detail class object to json value
    
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
    
    static func facebookLogout(){
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
    
    //If instagram user is business user, we need to allow user to facebook login for fetching instagram business user details.
    
    static func facebookLoginAct(userIDBusiness: String, owner: UIViewController, completion: @escaping(_ object:Any?, _ longliveToken: String?, _ error: Error?)->Void) {
        
        let login: LoginManager = LoginManager()
        login.loginBehavior = .browser
        login.logOut()
        //"pages_show_list"
        //API.facebookLogout()
        AccessToken.current = nil
        Profile.current = nil
        clearFacebookCookies()
        //"pages_show_list"
        //"manage_pages"
        //"pages_read_engagement"
        login.logIn(permissions: ["instagram_basic", "pages_show_list", "manage_pages"], from: owner) { (result, FBerror) in
            if((FBerror) != nil){
                print(FBerror as Any)
                completion(nil, nil, FBerror)
                
            }else if result!.isCancelled{
                
                completion(nil, nil, NSError(domain: "CancelErrorDomain", code: 408, userInfo: nil))
                
            }
            else{
                
                
                GraphRequest(graphPath: "/oauth/access_token", parameters: ["grant_type": "fb_exchange_token","client_id":API.FACEBOOK_CLIENT_ID,"client_secret": FACEBOOK_CLIENTSERCRET,"fb_exchange_token":AccessToken.current!.tokenString]).start(completionHandler: { (connection, userToken, error) -> Void in
                    
                    if error == nil{
                        //completion(userDetail, nil)
                        
                        if let liveTokenDict = userToken as? [String: AnyObject] {
                            
                            if let liveToken = liveTokenDict["access_token"] as? String{
                                
                                GraphRequest(graphPath: userIDBusiness, parameters: ["fields":"biography,id,followers_count,follows_count,media_count,name,profile_picture_url,username,website"]).start(completionHandler: { (connection, userDetail, tokenError) -> Void in
                                    
                                    if tokenError == nil{
                                        completion(userDetail, liveToken, nil)
                                    }else{
                                        completion(nil, nil, tokenError)
                                    }
                                    
                                })
                                
                            }
                            
                        }
                        
                    }else{
                        GraphRequest(graphPath: userIDBusiness, parameters: ["fields":"biography,id,followers_count,follows_count,media_count,name,profile_picture_url,username,website"]).start(completionHandler: { (connection, userDetail, tokenError) -> Void in
                            
                            if error == nil{
                                completion(userDetail, AccessToken.current!.tokenString, nil)
                            }else{
                                completion(nil, nil, tokenError)
                            }
                            
                        })
                    }
                    
                })
                
                
            }
            
        }
        
    }
    
    static func getInstaprofile(InstaID: String, userID: String, completion: @escaping(_ status: Bool)->()){
        GraphRequest(graphPath: InstaID, parameters: ["fields":"biography,id,followers_count,follows_count,media_count,name,profile_picture_url,username,website"]).start(completionHandler: { (connection, userDetail, tokenError) -> Void in
            
            if tokenError == nil{
                //completion(userDetail, liveToken, nil)
                if let userDetailDict = userDetail as? [String: AnyObject]{
                    if let pic = userDetailDict["profile_picture_url"] as? String {
                        Myself.basic.profilePicURL = pic
                    }
                }
                
                updateFirebaseProfileURL(profileUrl: Myself.basic.profilePicURL, id: Myself.basic.username) { (url, status) in
                    
                    if status{
                        Myself.basic.profilePicURL = url!
                        completion(true)
                    }else{
                        completion(false)
                    }
                }
            }else{
                //completion(nil, nil, tokenError)
            }
            
        })

    }
    
    static func clearFacebookCookies() {
        let cookies = HTTPCookieStorage.shared
        let facebookCookies = cookies.cookies(for: URL(string: "https://facebook.com/")!)
        for cookie in facebookCookies! {
            cookies.deleteCookie(cookie )
        }
        let facebookSingleCookies = cookies.cookies(for: URL(string: "http://login.facebook.com")!)
        for cookie in facebookSingleCookies! {
            cookies.deleteCookie(cookie )
        }
        if let cookieArray = cookies.cookies{
        for cookie in cookieArray {
            let domainName = cookie.domain
            if let range = domainName.range(of: "facebook"){
                if !range.isEmpty {
                   cookies.deleteCookie(cookie )
                }
            }
            
            
            
        }
        
        }
    }
    
    static func facebookLoginBusinessAccount(owner: UIViewController, completion: @escaping(_ object:Any?, _ longliveToken: String?, _ error: AnyObject?)->Void) {
        
        let login: LoginManager = LoginManager()
        login.loginBehavior = .browser
        login.logOut()
        //"pages_show_list"
        //API.facebookLogout()
        AccessToken.current = nil
        Profile.current = nil
        clearFacebookCookies()
        
        login.logIn(permissions: ["instagram_basic", "pages_show_list", "manage_pages"], from: owner) { (result, FBerror) in
            if((FBerror) != nil){
                print(FBerror as Any)
                completion(nil, nil, FBerror as AnyObject?)
                
            }else if result!.isCancelled{
                
                completion(nil, nil, NSError(domain: "CancelErrorDomain", code: 408, userInfo: nil))
                
            }
            else{
                
                
                
                GraphRequest(graphPath: "/oauth/access_token", parameters: ["grant_type": "fb_exchange_token","client_id":API.FACEBOOK_CLIENT_ID,"client_secret": FACEBOOK_CLIENTSERCRET,"fb_exchange_token":AccessToken.current!.tokenString]).start(completionHandler: { (connection, userToken, error) -> Void in
                    
                    if error == nil{
                        //completion(userDetail, nil)
                        
                        if let liveTokenDict = userToken as? [String: AnyObject] {
                            
                            if let liveToken = liveTokenDict["access_token"] as? String{
                                
                                GraphRequest(graphPath: "me/accounts", parameters: [:]).start(completionHandler: { (connection, accountDetail, tokenError) -> Void in
                                    
                                    if let userDetailDict = accountDetail as? [String: AnyObject] {
                                        
                                        if let userDetailArray = userDetailDict["data"] as? NSArray{
                                            
                                            
                                            if userDetailArray.count != 0{
                                            
                                            var insBusinesArray = [[String: AnyObject]]()
                                            
                                            let serialQueue = DispatchQueue.init(label: "serialQueue")
                                                
                                            var isSyncCount = 0
                                            
                                            for (index,userDetailData) in userDetailArray.enumerated() {
                                                
                                                
                                                
                                                if let userDetailFirsstObject = userDetailData as? [String: AnyObject]{
                                                    
                                                    if let pageID = userDetailFirsstObject["id"] as? String {
                                                        
                                                        serialQueue.sync {
                                                            
                                                            GraphRequest(graphPath: pageID, parameters: ["fields":"instagram_business_account"]).start(completionHandler: { (connection, businessDetail, tokenError) -> Void in
                                                                
                                                                isSyncCount += 1
                                                                
                                                                if let businessDetailDict = businessDetail as? [String: AnyObject]{
                                                                    
                                                                    if let businessIDDetail = businessDetailDict["instagram_business_account"] as? [String: AnyObject]{
                                                                        
                                                                        insBusinesArray.append(businessIDDetail)
                                                                        
                                                                        
                                                                        
                                                                    }
                                                                    //                                                                else{
                                                                    //
                                                                    //                                                                    completion(nil, nil, "Instagram Not Linked" as AnyObject)
                                                                    //
                                                                    //                                                                }
                                                                    
                                                                }
                                                                
                                                                if isSyncCount == userDetailArray.count {
                                                                    if insBusinesArray.count != 0{
                                                                        
                                                                        DispatchQueue.main.async {
                                                                            if let businessID = insBusinesArray.first!["id"] as? String{
                                                                                
                                                                                GraphRequest(graphPath: businessID, parameters: ["fields":"biography,id,followers_count,follows_count,media_count,name,profile_picture_url,username,website"]).start(completionHandler: { (connection, userDetail, tokenError) -> Void in
                                                                                    
                                                                                    if tokenError == nil{
                                                                                        completion(userDetail, liveToken, nil)
                                                                                        return
                                                                                    }else{
                                                                                        completion(nil, nil, tokenError as AnyObject?)
                                                                                    }
                                                                                    
                                                                                })
                                                                                
                                                                            }
                                                                            
                                                                            
                                                                        }
                                                                        
                                                                    }else{
                                                                        
                                                                        completion(nil, nil, "Instagram Not Linked" as AnyObject)
                                                                        
                                                                    }
                                                                    
                                                                    
                                                                }
                                                                
                                                                
                                                            })
                                                            
                                                        }
                                                        
                                                    }else{
                                                        
                                                        
                                                        
                                                    }
                                                    
                                                    
                                                    
                                                }
                                                
                                                
                                                
                                            }
                                            
                                        }else{
                                                
                                                completion(nil, nil, "Instagram Not Linked" as AnyObject)
                                            
                                        }
                                            
                                            
                                            
                                            //                                            if let userDetailFirsstObject = userDetailArray.firstObject as? [String: AnyObject]{
                                            //
                                            //                                                if let pageID = userDetailFirsstObject["id"] as? String {
                                            //
                                            //                                                    GraphRequest(graphPath: pageID, parameters: ["fields":"instagram_business_account"]).start(completionHandler: { (connection, businessDetail, tokenError) -> Void in
                                            //
                                            //                                                        if let businessDetailDict = businessDetail as? [String: AnyObject]{
                                            //
                                            //                                                            if let businessIDDetail = businessDetailDict["instagram_business_account"] as? [String: AnyObject]{
                                            //
                                            //                                                                if let businessID = businessIDDetail["id"] as? String{
                                            //
                                            //                                                                GraphRequest(graphPath: businessID, parameters: ["fields":"biography,id,followers_count,follows_count,media_count,name,profile_picture_url,username,website"]).start(completionHandler: { (connection, userDetail, tokenError) -> Void in
                                            //
                                            //                                                                    if tokenError == nil{
                                            //                                                                        completion(userDetail, liveToken, nil)
                                            //                                                                    }else{
                                            //                                                                        completion(nil, nil, tokenError as AnyObject?)
                                            //                                                                    }
                                            //
                                            //                                                                })
                                            //
                                            //                                                                }
                                            //
                                            //                                                            }else if let businessID = businessDetailDict["id"] as? String {
                                            //
                                            //                                                                GraphRequest(graphPath: businessID, parameters: ["fields":"biography,id,followers_count,follows_count,media_count,name,profile_picture_url,username,website"]).start(completionHandler: { (connection, userDetail, tokenError) -> Void in
                                            //
                                            //                                                                    if tokenError == nil{
                                            //                                                                        completion(userDetail, liveToken, nil)
                                            //                                                                    }else{
                                            //                                                                        completion(nil, nil, tokenError as AnyObject?)
                                            //                                                                    }
                                            //
                                            //                                                                })
                                            //
                                            //
                                            //                                                            }
                                            //
                                            //                                                            else{
                                            //
                                            //                                                                completion(nil, nil, "Instagram Not Linked" as AnyObject)
                                            //
                                            //                                                            }
                                            //
                                            //                                                        }
                                            //
                                            //
                                            //                                                    })
                                            //
                                            //                                                }
                                            //
                                            //
                                            //                                            }else{
                                            //
                                            //
                                            //                                                completion(nil, nil, "Page Not Created" as AnyObject)
                                            //
                                            //                                        }
                                            
                                        }else{
                                            completion(nil, nil, "Instagram Not Linked" as AnyObject)
                                        }
                                    }else{
                                        completion(nil, nil, "Instagram Not Linked" as AnyObject)
                                    }
                                    
                                    
                                })
                                
                            }
                            
                        }
                        
                    }else{
                        //                        GraphRequest(graphPath: userIDBusiness, parameters: ["fields":"biography,id,followers_count,follows_count,media_count,name,profile_picture_url,username,website"]).start(completionHandler: { (connection, userDetail, tokenError) -> Void in
                        //
                        //                            if error == nil{
                        //                                completion(userDetail, AccessToken.current!.tokenString, nil)
                        //                            }else{
                        //                                completion(nil, nil, tokenError)
                        //                            }
                        //
                        //                        })
                    }
                    
                })
                
                
            }
            
        }
        
    }
    
    static func calculateAverageLikes(userID: String,longLiveToken: String,completion:@escaping(_ recentMedia: Any?,_ error: Error?)->Void) {
        
        GraphRequest(graphPath: userID + "/media", parameters: ["access_token":longLiveToken]).start(completionHandler: { (connection, recentMedia, error) -> Void in
            if error == nil{
                completion(recentMedia,nil)
            }else{
                completion(nil,error)
            }
        })
        
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
            "expiredate": Date.getStringFromDate(date: Date().afterDays(numberOfDays: 365*1000)) as Any ,
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
            "tokenFIR":global.deviceFIRToken,
            "following":[],
            "businessFollowing":[],
            "email":details.email,
            "isForTesting":API.isForTesting
        ]
        return userData
    }
    
//    static func serializeProduct(product: Product) -> [String: Any] {
//        let userData: [String: Any] = [
//            "product_ID": product.product_ID as Any,
//            "image": product.image as Any,
//            "name": product.name,
//            "price": product.price,
//            "buy_url": product.buy_url as Any,
//            "color": product.color
//        ]
//        return userData
//    }
    
}
