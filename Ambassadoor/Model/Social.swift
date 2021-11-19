//
//  Social.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 18/01/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

/// Check if user exist if exist returns false or save user details to firebase
/// - Parameters:
///   - userID: Instagram ID
///   - instagramAuth: Instagram Auth Access token
///   - completion: Callback with true or false Optional and Influencer Object Optional
func checkNewIfUserExists(userID: String, instagramAuth: String, completion: @escaping(_ exist: Bool, _ user: Influencer?)-> Void) {
    //var isAlreadyRegistered: Bool = false
	
	let ref = Database.database().reference().child("Accounts/Private/Influencers")
	let query = ref.queryOrdered(byChild: "instagramAuthToken").queryEqual(toValue: userID)
	query.observeSingleEvent(of: .value, with: { (snapshot) in
		
		if snapshot.exists() {
			completion(true, nil)
		}else{
			let userData = Influencer.createUserDictionary(user: NewAccount)
			let basic = BasicInfluencer.createBasicUserDictionary(userInfo: NewAccount)
			createNewAccountDataToFIR(userID: userID, basic: basic, accountDetails: userData)
			let userRef = Influencer.init(dictionary: userData, userId: userID)
			completion(false, userRef)
		}
		
	}) { (error) in
		fatalError("Was not able to do firebase event.")
	}
}

func createNewAccountDataToFIR(userID: String, basic: [String: Any], accountDetails: [String: Any]) {
    let refPrivate = Database.database().reference().child("Accounts/Private/Influencers").child(userID)
    refPrivate.updateChildValues(accountDetails)
    
    let refPublic = Database.database().reference().child("Accounts/Public/Influencers").child(userID)
    refPublic.updateChildValues(basic)
}


func newUpdateUserDetails(path: String, user: Influencer){
    
    let userData = user.toDictionary()
    
    let refPrivate = Database.database().reference().child("Accounts/Private/Influencers").child(path)
    refPrivate.updateChildValues(userData)
    
    let userPublicData = user.basic.toDictionary()
    
    let refPublic = Database.database().reference().child("Accounts/Public/Influencers").child(path)
    refPublic.updateChildValues(userPublicData)
}

func newUpdateAverageLikes(privatePath: String, publicPath: String, userData:[String: Any]){
    
    let refPrivate = Database.database().reference().child("Accounts/Private/Influencers").child(privatePath)
    refPrivate.updateChildValues(userData)
    
    let refPublic = Database.database().reference().child("Accounts/Public/Influencers").child(publicPath)
    refPublic.updateChildValues(userData)
}

//MARK: New Database FollowedBy Update

func updateBasicBusinessFollowedByList(businessId: String, followedBy: [String]) {
    
    let privateRef = Database.database().reference().child("Accounts/Private/Businesses").child(businessId).child("basic")
    privateRef.updateChildValues(["followedBy":followedBy])
    
    let publicRef = Database.database().reference().child("Accounts/Public/Businesses").child(businessId)
    publicRef.updateChildValues(["followedBy":followedBy])
    
}

//MARK: New Database Following List Update

func updateBasicInfluencersBusinessFollowingList(userId: String, followlist: [String]) {
    
    let privateRef = Database.database().reference().child("Accounts/Private/Influencers").child(userId).child("basic")
    privateRef.updateChildValues(["followingBusinesses":followlist])
    
    let publicRef = Database.database().reference().child("Accounts/Public/Influencers").child(userId)
    publicRef.updateChildValues(["followingBusinesses":followlist])
    
}
