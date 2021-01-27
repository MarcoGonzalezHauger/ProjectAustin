//
//  Business Structs.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/24/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

//MARK: Main Class

class Business {
	
	var isCompanyRegistered: Bool {
		get {
			return basic != nil
		}
	}
	
	//subclasses
	var drafts: [DraftOffer]
	var finance: BusinessFinance
	var basic: BasicBusiness?
	var sentOffers: [sentOffer]
	
	//variables
	var businessId: String
	var token: String
	var email: String
	var refreshToken: String
	var deviceFIRToken: String
	
	var referredByUserId: String?
	var referredByBusinessId: String?
		
	init(dictionary d: [String: Any], businessId id: String) {
		businessId = id
		
		businessId = d["businessId"] as! String
		token = d["token"] as! String
		email = d["email"] as! String
		refreshToken = d["refreshToken"] as! String
		deviceFIRToken = d["deviceFIRToken"] as! String
		
		referredByUserId = d["referredByUserId"] as? String
		referredByBusinessId = d["referredByBusinessId"] as? String
		
		if let basicDict = d["basic"] as? [String: Any] {
			basic = BasicBusiness.init(dictionary: basicDict, businessId: businessId)
		}
		
		finance = BusinessFinance.init(dictionary: d["finance"] as! [String: Any], businessId: businessId)
		
		drafts = []
		if let draftDict = d["drafts"] as? [String: Any] {
			for draftId in draftDict.keys {
				drafts.append(DraftOffer.init(dictionary: draftDict[draftId] as! [String: Any], businessId: businessId, draftId: draftId))
			}
		}
		
		sentOffers = []
		if let sentOffersDict = d["sentOffers"] as? [String: Any] {
			for sentOfferId in sentOffersDict.keys {
				sentOffers.append(sentOffer.init(dictionary: sentOffersDict[sentOfferId] as! [String: Any], businessId: businessId, sentOfferId: sentOfferId))
			}
		}
		
	}
	
	// To Diciontary Function
		
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["finance"] = finance.toDictionary()
		if let basic = basic {
			d["basic"] = basic.toDictionary()
		}
		
		if let referredByUserId = referredByUserId {
			d["referredByUserId"] = referredByUserId
		}
		if let referredByBusinessId = referredByBusinessId {
			d["referredByBusinessId"] = referredByBusinessId
		}
		
		if drafts.count != 0 {
			var draftDictionary: [String: Any] = [:]
			for draft in drafts {
				draftDictionary[draft.draftId] = draft.toDictionary()
			}
			d["drafts"] = draftDictionary
		}
		
		if sentOffers.count != 0 {
			var sentOffersDictionary: [String: Any] = [:]
			for sentOffer in sentOffers {
				sentOffersDictionary[sentOffer.sentOfferId] = sentOffer.toDictionary()
			}
			d["sentOffers"] = sentOffersDictionary
		}
		
		d["businessId"] = businessId
		d["token"] = token
		d["email"] = email
		d["refreshToken"] = refreshToken
		d["deviceFIRToken"] = deviceFIRToken
		
		return d
	}
}

//MARK: Subclasses

class BasicBusiness {
	var name: String
	var logoUrl: String
	var mission: String
	var website: String
	var joinedDate: Date
	var referralCode: String
	var flags: [String]
	var followedBy: [String]
	
	var businessId: String
	
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
	
	init(dictionary d: [String: Any], businessId id: String) {
		businessId = id
		
		name = d["name"] as! String
		logoUrl = d["logoUrl"] as! String
		mission = d["mission"] as! String
		website = d["website"] as! String
		joinedDate = (d["joinedDate"] as! String).toUDate()
		referralCode = d["referralCode"] as! String
		flags = d["flags"] as! [String]
		followedBy = d["followedBy"] as! [String]
		
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["name"] = name
		d["logoUrl"] = logoUrl
		d["mission"] = mission
		d["website"] = website
		d["joinedDate"] = joinedDate.toUString()
		d["referralCode"] = referralCode
		d["flags"] = flags
		d["followedBy"] = followedBy
		
		return d
	}
}

class BusinessFinance {
	
	var hasStripeAccount: Bool {
		get {
			return stripeAccount != nil
		}
	}
	
	var stripeAccount: StripeAccountInformation?
	var log: [BusinessTransactionLogItem]
	
	var balance: Double
	var businessId: String
	
	init(dictionary d: [String: Any], businessId id: String) {
		businessId = id
		
		log = []
		if let thisLog = d["log"] as? [String: Any] {
			for logItem in thisLog.keys {
				let thisLogItem = thisLog[logItem] as! [String : Any]
				log.append(BusinessTransactionLogItem(dictionary: thisLogItem, businessId: businessId, transactionId: logItem))
			}
		}
		
		if let thisStripeAccount = d["stripeAccount"] as? [String: Any] {
			stripeAccount = StripeAccountInformation(dictionary: thisStripeAccount, userOrBusinessId: id)
		}
		
		balance = d["balance"] as! Double
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
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

class BusinessTransactionLogItem {
	var value: Double
	var time: Date
	var type: String //acceptable values: creditCardDeposit, withdrawedToStripe, ambver, sentOffer, tookBackOffer, addedOfferFunds
	
	var transactionId: String
	var businessId: String
	
	init(dictionary d: [String: Any], businessId id: String, transactionId tID: String) {
		businessId = id
		transactionId = tID
		
		value = d["value"] as! Double
		time = (d["time"] as! String).toUDate()
		type = d["type"] as! String
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		d["value"] = value
		d["time"] = time.toUString()
		d["type"] = type
		return d
	}
}
