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
    static let INSTAGRAM_REDIRECT_URI = "https://ambassadoor.co"
    static var INSTAGRAM_ACCESS_TOKEN = ""
    static let INSTAGRAM_SCOPE = "public_content" /* add whatever scope you need https://www.instagram.com/developer/authorization/ */
    
    static var instagramProfileData: [String: AnyObject] = [:]
    
    static func getProfileInfo(completed: @escaping () -> () ) {
        let url = URL(string: "https://api.instagram.com/v1/users/self/?access_token=" + INSTAGRAM_ACCESS_TOKEN)
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
            if err == nil {
                // check if JSON data is downloaded yet
                guard let jsondata = data else { return }
                do {
                    do {
                        // Deserilize object from JSON
                        if let profileData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
                            self.instagramProfileData = profileData["data"] as! [String : AnyObject]
                            let user = User(
                                name: instagramProfileData["full_name"] as? String,
                                username: instagramProfileData["username"] as? String,
                                followerCount: instagramProfileData["counts"]?["followed_by"] as? Double ?? 0,
                                profilePicture: instagramProfileData["profile_picture"] as? String,
                                AccountType: SubCategories.Other // Will need to get from user on account creation
                            )
                            debugPrint(user)
                        }
                    }
                    // Wait for data to be retrieved before moving on
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch {
                    print("JSON Downloading Error!")
                }
            }
        }.resume()
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
}
