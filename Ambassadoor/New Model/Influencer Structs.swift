//
//  User2.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/21/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation


//MARK: Main Class

class Influencer {
	
	//Subclasses
	var basic: BasicInfluencer
	var inbox: [Message]
	var finance: InfluencerFinance
	
	var instagramPosts: [InstagramPost]
	var inProgressOffers: [inProgressOffer]
	
	//Authentication and Tokens
	var email: String
	var password: String
	var instagramAuthToken: String
	var instagramAccountId: String
	var tokenFIR: String
	
	
	var userId: String
		
	init(dictionary d: [String: Any], userId id: String) {
		userId = id
		
		basic = BasicInfluencer(dictionary: d["basic"] as! [String: Any], userId: id)
		finance = InfluencerFinance(dictionary: d["finance"] as! [String: Any], userID: id)
		
		inbox = []
		if let thisInbox = d["inbox"] as? [String: Any] {
			for messageId in thisInbox.keys {
				let thisMessage = thisInbox[messageId] as! [String : Any]
				inbox.append(Message(dictionary: thisMessage, userId: id, messageId: messageId))
			}
		}
		
		email = d["email"] as! String
		password = d["password"] as! String
		instagramAuthToken = d["instagramAuthToken"] as! String
		instagramAccountId = d["instagramAccountId"] as! String
		tokenFIR = d["tokenFIR"] as! String
	
		
		
	}
	
	// To Diciontary Function
		
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		//Subclasses
		d["basic"] = basic.toDictionary()
		d["finance"] = finance.toDictionary()
		
		//Regular Variables
		d["password"] = password
		d["email"] = email
		d["instagramAuthToken"] = instagramAuthToken
		d["instagramAccountId"] = instagramAccountId
		d["tokenFIR"] = tokenFIR
		
		if inbox.count != 0 {
			var inboxDictionary: [String: Any] = [:]
			for msg in inbox {
				inboxDictionary[msg.messageId] = msg.toDictionary()
			}
			d["inbox"] = inboxDictionary
		}
		
		
		return d
	}
	
	
	
}

//MARK: Subclasses

class BasicInfluencer { //All public information goes here.
	var name: String
	var username: String
	var followerCount: Double
	var averageLikes: Double
	var profilePicURL: String
	var zipCode: String
	var gender: String
	var joinedDate: String
	var categories: [String]
	var referralCode: String
	var userId: String
	var flags: [String]
	var followingInfluencers: [String]
	var followingBusinesses: [String]
	var followedBy: [String]
	
	func checkFlag(_ flag: String) -> Bool {
		return flags.contains(flag)
	}
	
	func AddFlag(_ flag: String) {
		if !flags.contains(flag) {
			flags.append(flag)
		}
	}
	
	func RemoveFlag(_ flag: String) {
		if flags.contains(flag) {
			flags.removeAll{$0 == flag}
		}
	}
	
	init(dictionary d: [String: Any], userId id: String) {
		userId = id
		
		name = d["name"] as! String
		username = d["username"] as! String
		followerCount = d["followerCount"] as! Double
		averageLikes = d["averageLikes"] as! Double
		profilePicURL = d["profilePicURL"] as! String
		zipCode = d["zipCode"] as! String
		gender = d["gender"] as! String
		joinedDate = d["joinedDate"] as! String
		categories = d["categories"] as! [String]
		referralCode = d["referralCode"] as! String
		flags = d["flags"] as! [String]
		followingInfluencers = d["followingInfluencers"] as! [String]
		followingBusinesses = d["followingBusinesses"] as! [String]
		followedBy = d["followedBy"] as! [String]
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["name"] = name
		d["username"] = username
		d["followerCount"] = followerCount
		d["averageLikes"] = averageLikes
		d["profilePicURL"] = profilePicURL
		d["zipCode"] = zipCode
		d["gender"] = gender
		d["joinedDate"] = joinedDate
		d["categories"] = categories
		d["referralCode"] = referralCode
		d["flags"] = flags
		d["followingInfluencers"] = followingInfluencers
		d["followingBusinesses"] = followingBusinesses
		d["followedBy"] = followedBy
		
		return d
	}
}

class InstagramPost {
	
}

class InfluencerFinance {
	var isBankAdded: Bool {
		get {
			return bank != nil
		}
	}
	var hasStripeAccount: Bool {
		get {
			return stripeAccount != nil
		}
	}
	var balance: Double
	var stripeAccount: StripeAccountInformation?
	var userId: String
	var bank: InfluencerBank?
	var log: [InfluencerTransactionLogItem]
	
	init(dictionary d: [String: Any], userID id: String) {
		userId = id
		
		balance = d["balance"] as! Double
		if let bankDictionary = d["bank"] as? [String: Any] {
			bank = InfluencerBank(dictionary: bankDictionary, userID: userId)
		}
		log = []
		if let thisLog = d["log"] as? [String: Any] {
			for logItem in thisLog.keys {
				let thisLogItem = thisLog[logItem] as! [String : Any]
				log.append(InfluencerTransactionLogItem(dictionary: thisLogItem, userID: userId, transactionId: logItem))
			}
		}
		
		if let thisStripeAccount = d["stripeAccount"] as? [String: Any] {
			stripeAccount = StripeAccountInformation(dictionary: thisStripeAccount, userOrBusinessId: id)
		}
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		if let bank = bank {
			d["bank"] = bank.toDictionary()
		}
		if log.count != 0 {
			var logDictionary: [String: Any] = [:]
			for logItem in log {
				logDictionary[logItem.transactionId] = logItem.toDictionary()
			}
			d["log"] = logDictionary
		}
		
		if let stripeAccount = stripeAccount {
			d["stripeAccount"] = stripeAccount.toDictionary()
		}
		d["balance"] = balance
		
		return d
	}
}

//MARK: Items

class InfluencerTransactionLogItem {
	var value: Double
	var time: String
	var transactionId: String
	var type: String //acceptable values: fromOffer, addedToBank, ambverChanged
	var userId: String
	
	init(dictionary d: [String: Any], userID id: String, transactionId tID: String) {
		userId = id
		transactionId = tID
		
		value = d["value"] as! Double
		time = d["time"] as! String
		type = d["type"] as! String
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		d["value"] = value
		d["time"] = time
		d["type"] = type
		return d
	}
}

class StripeAccountInformation {
	var accessToken: String
	var livemode: Bool
	var refreshToken: String
	var tokenType: String
	var stripePublishableKey: String
	var stripeUserId: String
	var scope: String
	var userOrBusinessId: String
	
	init(dictionary d: [String: Any], userOrBusinessId id: String) {
		userOrBusinessId = id
		
		accessToken = d["accessToken"] as! String
		livemode = d["livemode"] as! Bool
		refreshToken = d["refreshToken"] as! String
		tokenType = d["tokenType"] as! String
		stripePublishableKey = d["stripePublishableKey"] as! String
		stripeUserId = d["stripeUserId"] as! String
		scope = d["scope"] as! String
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["accessToken"] = accessToken
		d["livemode"] = livemode
		d["refreshToken"] = refreshToken
		d["tokenType"] = tokenType
		d["stripePublishableKey"] = stripePublishableKey
		d["stripeUserId"] = stripeUserId
		d["scope"] = scope
		
		return d
	}
	
}

class InfluencerBank {
	var publicToken: String
	var institutionName: String
	var institutionID: String
	var accountID: String
	var accountName: String
	var userId: String
   
	init(dictionary d: [String: Any], userID id: String) {
		userId = id
		
		publicToken = d["publicToken"] as! String
		institutionName = d["institutionName"] as! String
		institutionID = d["institutionID"] as! String
		accountID = d["accountID"] as! String
		accountName = d["accountName"] as! String
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		d["publicToken"] = publicToken
		d["institutionName"] = institutionName
		d["institutionID"] = institutionID
		d["accountID"] = accountID
		d["accountName"] = accountName
		return d
	}
}

class Message {
	var text: String
	var title: String
	var time: String
	var read: Bool
	var messageId: String
	var userId: String
	init(dictionary d: [String: Any], userId id: String, messageId mId: String) {
		userId = id
		messageId = mId
		
		text = d["text"] as! String
		title = d["title"] as! String
		time = d["time"] as! String
		read = d["read"] as! Bool
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		d["text"] = text
		d["title"] = title
		d["time"] = time
		d["read"] = read
		return d
	}
}
