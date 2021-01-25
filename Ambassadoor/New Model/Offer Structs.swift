//
//  Offer Structs.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/24/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

class DraftOffer { //before business sends
	var draftId: String
	var businessId: String
	
	var mustBeOver21: Bool
	var payIncrease: Double
	
	var draftPosts: [DraftPost]
	var title: String
	var lastEdited: String
	
	init(dictionary d: [String: Any], businessId id: String, draftId did: String) {
		businessId = id
		draftId = did
		
		title = d["title"] as! String
		lastEdited = d["lastEdited"] as! String
		
		draftPosts = []
		if let postDraftsDict = d["draftPosts"] as? [String: Any] {
			for postDraftId in postDraftsDict.keys {
				draftPosts.append(DraftPost.init(dictionary: postDraftsDict[postDraftId] as! [String: Any], businessId: businessId, draftId: draftId, draftPost: postDraftId, poolId: nil))
			}
		}
		
		mustBeOver21 = d["mustBeOver21"] as! Bool
		payIncrease = d["payIncrease"] as! Double
		
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["title"] = title
		d["lastEdited"] = lastEdited
		
		if draftPosts.count != 0 {
			var draftPostDict: [String: Any] = [:]
			for draftPost in draftPosts {
				draftPostDict[draftPost.draftPostId] = draftPost.toDictionary()
			}
			d["draftPosts"] = draftPosts
		}
		
		return d
	}
}

class DraftPost {
	var requiredHastags: [String]
	var requriedKeywords: [String]
	var instructions: String
	
	var draftPostId: String
	var draftId: String
	var poolId: String?
	var businessId: String
	
	init(dictionary d: [String: Any], businessId id: String, draftId did: String, draftPost pid: String, poolId plid: String?) {
		businessId = id
		draftId = did
		draftPostId = pid
		poolId = plid
		
		requiredHastags = d["requiredHastags"] as! [String]
		requriedKeywords = d["requriedKeywords"] as! [String]
		instructions = d["instructions"] as! String
		
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["requiredHastags"] = requiredHastags
		d["requriedKeywords"] = requriedKeywords
		d["instructions"] = instructions
		
		return d
	}
}

class OfferFilter {
	
	//List should be empty if all are accepted.
	var acceptedZipCodes: [String]
	var acceptedCategories: [String]
	var acceptedGenders: [String]
	
	var businessId: String
	
	init(dictionary d: [String: Any], businessId id: String) {
		businessId = id
				
		acceptedZipCodes = d["acceptedZipCodes"] as! [String]
		acceptedCategories = d["acceptedCategories"] as! [String]
		acceptedGenders = d["acceptedGenders"] as! [String]
		
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["acceptedZipCodes"] = acceptedZipCodes
		d["acceptedCategories"] = acceptedCategories
		d["acceptedGenders"] = acceptedGenders
		
		return d
	}
	
	func DoesInfluencerPassFilter(basicInfluencer: BasicInfluencer) -> Bool {
		if acceptedZipCodes.count != 0 {
			if !acceptedZipCodes.contains(basicInfluencer.zipCode) {
				return false
			}
		}
		if acceptedGenders.count != 0 {
			if !acceptedGenders.contains(basicInfluencer.gender) {
				return false
			}
		}
		if acceptedCategories.count != 0 {
			for cat in basicInfluencer.categories {
				if acceptedCategories.contains(cat) {
					return true
				}
			}
		} else {
			return true
		}
		return false
	}
	
}

class PoolOffer { //while in offer pool (GETS ASSIGNED NEW ID)
	
	var cashPower: Double
	var originalCashPower: Double
	
	var comissionUserId: String?
	var comissionBusinessId: String?
	
	var poolId: String
	var businessId: String
	var draftOfferId: String
	
	var filter: OfferFilter
	var draftPosts: [DraftPost]
	var flags: [String] //SUCH AS: mustBeOver21, isForTesting, isDefaultOffer
	var sentDate: String
	var payIncrease: Double
	
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
	
	init(draftOffer: DraftOffer, filter flt: OfferFilter, withMoney cash: Double, createdBy bus: Business) {
		cashPower = cash
		originalCashPower = cash
		comissionUserId = bus.referredByUserId
		comissionBusinessId = bus.referredByBusinessId
		poolId = Date().toString(dateFormat: "yyyy.MM.dd") + "." + bus.basic!.name + "." + randomString(length: 10)
		businessId = bus.businessId
		draftOfferId = draftOffer.draftId
		filter = flt
		draftPosts = draftOffer.draftPosts
		flags = []
		sentDate = Date().toString(dateFormat: "yyyy-MM-dd HH:mm:ssZ")
		payIncrease = draftOffer.payIncrease
		
		if draftOffer.mustBeOver21 {
			self.AddFlag("mustBeOver21")
		}
	}
	
	init(dictionary d: [String: Any], businessId id: String, poolId pid: String) {
		businessId = id
		poolId = pid
		
		filter = OfferFilter.init(dictionary: d["filter"] as! [String: Any], businessId: businessId)
		
		draftOfferId = d["draftOfferId"] as! String
		flags = d["flags"] as! [String]
		sentDate = d["sentDate"] as! String
		
		draftPosts = []
		if let postDraftsDict = d["draftPosts"] as? [String: Any] {
			for postDraftId in postDraftsDict.keys {
				draftPosts.append(DraftPost.init(dictionary: postDraftsDict[postDraftId] as! [String: Any], businessId: businessId, draftId: draftOfferId, draftPost: postDraftId, poolId: poolId))
			}
		}
		
		comissionUserId = d["comissionUserId"] as? String
		comissionBusinessId = d["comissionBusinessId"] as? String
		
		cashPower = d["cashPower"] as! Double
		originalCashPower = d["originalCashPower"] as! Double
		payIncrease = d["payIncrease"] as! Double
		
	}
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["filter"] = filter.toDictionary()
		d["draftOfferId"] = draftOfferId
		d["flags"] = flags
		d["sentDate"] = sentDate
		d["cashPower"] = cashPower
		d["originalCashPower"] = originalCashPower
		
		if let comissionUserId = comissionUserId {
			d["comissionUserId"] = comissionUserId }
		if let comissionBusinessId = comissionBusinessId {
			d["comissionBusinessId"] = comissionBusinessId }
		d["payIncrease"] = payIncrease
		
		if draftPosts.count != 0 {
			var draftPostDict: [String: Any] = [:]
			for draftPost in draftPosts {
				draftPostDict[draftPost.draftPostId] = draftPost.toDictionary()
			}
			d["draftPosts"] = draftPosts
		}
		
		
		
		
		
		return d
	}
	
}

class inProgressOffer { //when accepted by influencer (GETS ASSIGNED NEW ID)
	var poolId: String
	var inProgressId: String
	
	var businessId: String
	var userId: String
	
	init(dictionary d: [String: Any], inProgressId ipid: String, userId id: String) {
		userId = id
		inProgressId = ipid
		
		
	}
}

class sentOffer { //when business goes back to look at previously sent out offers
	var poolId: String
	var sentOfferId: String
	var draftOfferId: String
	
	var businessId: String
	
	init(dictionary d: [String: Any], businessId id: String, sentOfferId soid: String) {
		businessId = id
		sentOfferId = soid
		
		
	}
	
	func toDictionary() -> [String: Any] { return [:] }
}
