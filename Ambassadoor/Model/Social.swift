//
//  Social.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 18/01/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase


func checkIfUserExists(userID: String,completion: @escaping(_ exist: Bool, _ user: User?)-> Void) {
    //var isAlreadyRegistered: Bool = false
    let ref = Database.database().reference().child("users").child(userID)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        //if let _ = snapshot.value as? [String: AnyObject]{
        if snapshot.exists(){
            completion(true, nil)
            
        }else{
            createNewInfluencerAuthentication(info: NewAccount)
            let userData = API.serializeRawUserData(details: NewAccount)
            ref.updateChildValues(userData)
            do {
                let userRef = try User.init(dictionary: userData)
                completion(false, userRef)
            } catch let error {
                print(error)
            }
            //let userRef = User.init(dictionary: userData)
            
        }
        
    }) { (error) in
        createNewInfluencerAuthentication(info: NewAccount)
        let userData = API.serializeRawUserData(details: NewAccount)
        ref.updateChildValues(userData)
        do {
            let userRef = try User.init(dictionary: userData)
            completion(false, userRef)
        } catch let error {
            print(error)
        }
    }
}

//naveen added func
func CreateAccount(instagramUser: User, completion:@escaping (_ Results: User , _ bool:Bool) -> ()) {
    // Pointer reference in Firebase to Users
    let ref = Database.database().reference().child("users")
    // Boolean flag to keep track if user is already in database
    var alreadyRegistered: Bool = false
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        //print(snapshot.childrenCount)
        for case let user as DataSnapshot in snapshot.children {
            if (user.childSnapshot(forPath: "username").value as? String == instagramUser.username) {
                alreadyRegistered = true
                if let dictionary = user.value as? [String: AnyObject] {
                    instagramUser.gender = TextToGender(gender: dictionary["gender"] as! String)
                    instagramUser.zipCode = dictionary["zipCode"] as? String
                    instagramUser.isBankAdded = dictionary["isBankAdded"] as! Bool
                    instagramUser.yourMoney = dictionary["yourMoney"] as! Double
                    
                    if let joined = dictionary["joinedDate"] as? String {
                        instagramUser.joinedDate = joined
                    }else{
                        instagramUser.joinedDate = Date.getCurrentDate()
                    }
                    
                    if  let categories = dictionary["categories"] as? [String] {
                        instagramUser.categories = categories
                    }else{
                        instagramUser.categories = []
                    }
                    
                    if let referralcode = dictionary["referralcode"] as? String{
                        instagramUser.referralcode = referralcode
                    }else{
                        var referralcodeString = ""
                        //random four digit code
                        referralcodeString.append(randomString(length: 4))
                        
                        instagramUser.referralcode = referralcodeString.uppercased()
                        
                    }
                    
                    
                    if let isDefaultOfferVerify = dictionary["isDefaultOfferVerify"] as? Bool{
                        instagramUser.isDefaultOfferVerify = isDefaultOfferVerify
                    }else{
                        instagramUser.isDefaultOfferVerify = false
                    }
                    
                    if let lastPaidOSCDate = dictionary["lastPaidOSCDate"] as? String{
                        instagramUser.lastPaidOSCDate = lastPaidOSCDate
                    }else{
                        instagramUser.lastPaidOSCDate = Date.getCurrentDate()
                    }
                    
                    if let priorityValue = dictionary["priorityValue"] as? Int{
                        instagramUser.priorityValue = priorityValue
                    }else{
                        instagramUser.priorityValue = 0
                    }
                    
                    if let authenticationToken = dictionary["authenticationToken"] as? String{
                        if authenticationToken != "" {
                            instagramUser.authenticationToken = authenticationToken
                        }else{
                            instagramUser.authenticationToken = API.INSTAGRAM_ACCESS_TOKEN
                        }
                    }else{
                        instagramUser.authenticationToken = API.INSTAGRAM_ACCESS_TOKEN
                    }
                    
                }
                
            }
        }
        
        if alreadyRegistered {
            let userReference = ref.child(instagramUser.id)
            let userData = API.serializeUserWithOutMoney(user: instagramUser, id: instagramUser.id)
            userReference.updateChildValues(userData)
            completion(instagramUser,true)
        } else {
            completion(instagramUser,false)
        }
    })
    
}

//naveen added func
func GetAllUsers(completion:@escaping (_ result: [User])->())  {
    let usersRef = Database.database().reference().child("users")
    var users: [User] = []
    //    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
    usersRef.observe(.value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            
            users.removeAll()
            
            for (_, user) in dictionary{
                let userDictionary = user as? NSDictionary
                
                do {
                    
                    let userInstance = try User(dictionary: userDictionary! as! [String : AnyObject])
                    if userInstance.version != "0.0.0"{
                        users.append(userInstance)
                    }
                    
                } catch let error {
                    print(error)
                }
            }
            
            completion(users)
        }
    }, withCancel: nil)
}

func updateUserDetails(userID: String, userData:[String: Any]){
    
    let ref = Database.database().reference().child("users").child(userID)
    ref.updateChildValues(userData)
}


func fetchSingleUserDetails(userID: String, completion: @escaping(_ status: Bool, _ user: User)->Void) {
    let usersRef = Database.database().reference().child("users").child(userID)
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            
            //Yourself = userInstance
            
            //            print("Appdelegate gender = \(Yourself.gender)")
            
            do {
                let userInstance = try User(dictionary: dictionary )
                
                if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String{
                    
                    userInstance.version = appVersion
                    completion(true,userInstance)
                    let versionUpdateRef = Database.database().reference().child("users").child(userID)
                    versionUpdateRef.updateChildValues(["version":appVersion])
                    
                }else{
                    completion(true,userInstance)
                }
                
                
            } catch let error {
                print(error)
            }
            
        }
    }, withCancel: nil)
}

func updateFollowingList(userID: String, ownUserID: User) {
    let usersRef = Database.database().reference().child("users").child(ownUserID.id)
    usersRef.updateChildValues(["following":ownUserID.following!])
}

func updateBusinessFollowingList(company: CompanyDetails,userID: String, ownUserID: User) {
    let usersRef = Database.database().reference().child("users").child(ownUserID.id)
    usersRef.updateChildValues(["businessFollowing":ownUserID.businessFollowing!])
    
    let businessRef = Database.database().reference().child("companies").child(userID).child(company.account_ID!)
    var followers = company.followers
    followers?.append(ownUserID.id)
    businessRef.updateChildValues(["followers":followers!])
}

func getFilteredUsers(userIDs: [String], completion: @escaping(_ status: Bool, _ users: [User]?, _ deveiceTokens: [String]?)-> Void) {
    
    let usersRef = Database.database().reference().child("users")
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let dictValue = snapshot.value as? [String: AnyObject] {
            
            let filteredData = dictValue.filter { (value) -> Bool in
                return userIDs.contains(value.key)
            }
            
            var usersList = [User]()
            var tokens = [String]()
            
            for (_,value) in filteredData {
                
                if let valueDict = value as? [String: Any] {
                    
                    
                    do {
                        let user = try User.init(dictionary: valueDict)
                        usersList.append(user)
                        if let token = valueDict["tokenFIR"] as? String {
                            tokens.append(token)
                        }
                    } catch let error {
                        print(error)
                    }
                    
                    
                }
                
            }
            completion(true,usersList,tokens)
        }
        
    }) { (error) in
        completion(false,nil, nil)
    }
    
}
