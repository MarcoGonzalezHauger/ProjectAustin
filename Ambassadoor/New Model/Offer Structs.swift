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
	var lastEdited: Date
	
	init(dictionary d: [String: Any], businessId id: String, draftId did: String) {
		businessId = id
		draftId = did
		
		title = d["title"] as! String
		lastEdited = (d["lastEdited"] as! String).toUDate()
		
		draftPosts = []
		if let postDraftsDict = d["draftPosts"] as? [String: Any] {
			for postDraftId in postDraftsDict.keys {
				draftPosts.append(DraftPost.init(dictionary: postDraftsDict[postDraftId] as! [String: Any], businessId: businessId, draftId: draftId, draftPostId: postDraftId, poolId: nil))
			}
		}
		
		mustBeOver21 = d["mustBeOver21"] as! Bool
		payIncrease = d["payIncrease"] as! Double
		
	}
	
	init(draftId: String, businessId: String, mustBeOver21: Bool, payIncrease: Double, draftPosts: [DraftPost], title: String, lastEdited: Date) {
		self.draftId = draftId
		self.businessId = businessId
		self.mustBeOver21 = mustBeOver21
		self.payIncrease = payIncrease
		self.draftPosts = draftPosts
		self.title = title
		self.lastEdited = lastEdited
		
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["title"] = title
		d["lastEdited"] = lastEdited.toUString()
		
		if draftPosts.count != 0 {
			var draftPostDict: [String: Any] = [:]
			for draftPost in draftPosts {
				draftPostDict[draftPost.draftPostId] = draftPost.toDictionary()
			}
			d["draftPosts"] = draftPostDict
		}
		
		return d
	}
}

class DraftPost {
	var requiredHastags: [String]
	var requiredKeywords: [String]
	var instructions: String
	
	var draftPostId: String
	var draftId: String
	var poolId: String?
	var businessId: String
	
	init(dictionary d: [String: Any], businessId id: String, draftId did: String, draftPostId pid: String, poolId plid: String?) {
		businessId = id
		draftId = did
		draftPostId = pid
		poolId = plid
		
		requiredHastags = d["requiredHastags"] as! [String]
		requiredKeywords = d["requiredKeywords"] as! [String]
		instructions = d["instructions"] as! String
		
	}
	
	init(businessId id: String, draftId did: String, poolId plid: String?, hash: [String], keywords: [String], ins: String) {
		businessId = id
		draftId = did
		poolId = plid
		
		draftPostId = GetNewID()
		
		requiredHastags = hash
		requiredKeywords = keywords
		instructions = ins
		
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["requiredHastags"] = requiredHastags
		d["requiredKeywords"] = requiredKeywords
		d["instructions"] = instructions
		
		return d
	}
}

class OfferFilter {
	
	//List should be empty if all are accepted.
	var acceptedZipCodes: [String]
	var acceptedCategories: [String]
	var acceptedGenders: [String]
	var mustBe21: Bool
	var minimumEngagmentRate: Double
	
	var businessId: String
	
	init(dictionary d: [String: Any], businessId id: String) {
		businessId = id
				
		acceptedZipCodes = d["acceptedZipCodes"] as! [String]
		acceptedCategories = d["acceptedCategories"] as! [String]
		acceptedGenders = d["acceptedGenders"] as! [String]
		mustBe21 = d["mustBe21"] as! Bool
		minimumEngagmentRate = d["minimumEngagmentRate"] as! Double
		
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["acceptedZipCodes"] = acceptedZipCodes
		d["acceptedCategories"] = acceptedCategories
		d["acceptedGenders"] = acceptedGenders
		d["mustBe21"] = mustBe21
		d["minimumEngagmentRate"] = minimumEngagmentRate
		
		return d
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
	var sentDate: Date
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
		poolId = bus.basic!.name + ", " + GetNewID()
		businessId = bus.businessId
		draftOfferId = draftOffer.draftId
		filter = flt
		draftPosts = draftOffer.draftPosts
		flags = []
		sentDate = Date()
		payIncrease = draftOffer.payIncrease
		
		if draftOffer.mustBeOver21 {
			self.AddFlag("mustBeOver21")
		}
	}
	
	init(cashPower: Double, originalCashPower: Double, comissionUserId: String, comissionBusinessId: String, poolId: String, businessId: String, draftOfferId: String, filter: OfferFilter, draftPosts: [DraftPost], flags: [String], sentDate: Date, payIncrease: Double) {
		self.cashPower = cashPower
		self.originalCashPower = originalCashPower
		self.comissionUserId = comissionUserId
		self.comissionBusinessId = comissionBusinessId
		self.poolId = poolId
		self.businessId = businessId
		self.draftOfferId = draftOfferId
		self.filter = filter
		self.draftPosts = draftPosts
		self.flags = flags
		self.sentDate = sentDate
		self.payIncrease = payIncrease
	}
	
	init(dictionary d: [String: Any], poolId pid: String) {
		poolId = pid
		businessId = d["businessId"] as! String
		
		filter = OfferFilter.init(dictionary: d["filter"] as! [String: Any], businessId: businessId)
		
		draftOfferId = d["draftOfferId"] as! String
		flags = d["flags"] as! [String]
		sentDate = (d["sentDate"] as! String).toUDate()
		
		draftPosts = []
		if let postDraftsDict = d["draftPosts"] as? [String: Any] {
			for postDraftId in postDraftsDict.keys {
				draftPosts.append(DraftPost.init(dictionary: postDraftsDict[postDraftId] as! [String: Any], businessId: businessId, draftId: draftOfferId, draftPostId: postDraftId, poolId: poolId))
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
		d["sentDate"] = sentDate.toUString()
		d["cashPower"] = cashPower
		d["originalCashPower"] = originalCashPower
		d["businessId"] = businessId
		
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
			d["draftPosts"] = draftPostDict
		}
		
		return d
	}
	
}

class InProgressPost {
	
	var inProgressPostId: String
	var userId: String
	
	var PoolOfferId: String
	var draftOfferId: String
	var businessId: String
	var draftPostId: String
	
	var comissionUserId: String?
	var comissionBusinessId: String?
	
	var draftPost: DraftPost
	
	var cashValue: Double
	var status: String //Accepted, Expired, Posted, Verified, Paid, Rejected, Cancelled.
	
	//MARK: Accetped
	var dateAccepted: Date
	var expirationDate: Date //dateAccepted + 48 hours
	
	//MARK: Expired
	//NO variables needed for this status. the status is enough information.
	
	//MARK: Posted
	var instagramPost: InstagramPost?
	var willBePaidOn: Date //instagramPost.timestamp + 48 hours
	
	//MARK: Verified
	var dateVerified: Date //The date where the post was verified by AMBVER.
	//this status will also use the willBePaidOn variable used on the posted.
	
	//MARK: Paid
	var datePaid: Date //The date wher the stuatus was changed to "Paid"
	
	//MARK: Rejected
	var denyReason: String
	var dateRejected: Date
	
	//MARK: Cancelled
	var dateCancelled: Date
	var wasRefundedForCancel: Bool
	
	init(draftPost dp: DraftPost, comissionUserId cuid: String?, comissionBusinessId cbid: String?, userId id: String, poolOfferId poid: String, businessId bid: String, draftOfferId doid: String, cashValue cash: Double) { //This init function should be used when the user first accepts an offer and the PoolOffer is truned into many different inProgressPosts.
		
		draftPost = dp
		draftPostId = dp.draftPostId
		
		comissionUserId = cuid
		comissionBusinessId = cbid
		userId = id
		PoolOfferId = poid
		businessId = bid
		draftOfferId = doid
		
		
		//Creating the id for this class:
		inProgressPostId = GetNewID()
		
		status = "Accepted"
		cashValue = cash
		
		
		//all start as "" when offer is first accepted.
		
		willBePaidOn = GetEmptyDate()
		dateVerified = GetEmptyDate()
		datePaid = GetEmptyDate()
		dateAccepted = GetEmptyDate()
		expirationDate =  GetEmptyDate()
		dateRejected = GetEmptyDate()
		dateCancelled = GetEmptyDate()
		wasRefundedForCancel = false
		denyReason = ""
		
		
	}
	
	init(dictionary d: [String: Any], inProgressPostId ipid: String, userId id: String) {
		userId = id
		inProgressPostId = ipid
		
		dateAccepted = (d["dateAccepted"] as! String).toUDate()
		expirationDate = (d["expirationDate"] as! String).toUDate()
		willBePaidOn = (d["willBePaidOn"] as! String).toUDate()
		dateVerified = (d["dateVerified"] as! String).toUDate()
		datePaid = (d["datePaid"] as! String).toUDate()
		dateRejected = (d["dateRejected"] as! String).toUDate()
		dateCancelled = (d["dateCancelled"] as! String).toUDate()
		
		wasRefundedForCancel = d["wasRefundedForCancel"] as! Bool
		
		
		if let instaPostDict = d["instagramPost"] as? [String: Any] {
			instagramPost = InstagramPost.init(dictionary: instaPostDict, userId: id)		//sometimes nil
		}									//sometimes ""
		denyReason = d["denyReason"] as! String												//sometimes ""
		
		PoolOfferId = d["PoolOfferId"] as! String											//never ""
		draftOfferId = d["draftOfferId"] as! String											//never ""
		businessId = d["businessId"] as! String												//never ""
		draftPostId = d["draftPostId"] as! String											//never ""
		
		comissionUserId = d["comissionUserId"] as? String									//sometimes ""
		comissionBusinessId = d["comissionBusinessId"] as? String							//sometimes ""
		
		draftPost = DraftPost.init(dictionary: d["draftPost"] as! [String: Any], businessId: businessId, draftId: draftOfferId, draftPostId: draftPostId, poolId: PoolOfferId) //never nil
		
		status = d["status"] as! String //never ""
		cashValue = d["cashValue"] as! Double
	}
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		if let comissionUserId = comissionUserId {
			d["comissionUserId"] = comissionUserId }
		if let comissionBusinessId = comissionBusinessId {
			d["comissionBusinessId"] = comissionBusinessId }
		if let instagramPost = instagramPost {
			d["instagramPost"] = instagramPost.toDictionary() }
		
		d["status"] = status
		d["cashValue"] = cashValue
		
		d["wasRefundedForCancel"] = wasRefundedForCancel
		
		d["dateAccepted"] = dateAccepted.toUString()
		d["expirationDate"] = expirationDate.toUString()
		d["dateVerified"] = dateVerified.toUString()
		d["datePaid"] = datePaid.toUString()
		d["dateRejected"] = dateRejected.toUString()
		d["willBePaidOn"] = willBePaidOn.toUString()
		d["dateCancelled"] = dateCancelled.toUString()
		
		d["denyReason"] = denyReason
		
		d["PoolOfferId"] = PoolOfferId
		d["draftOfferId"] = draftOfferId
		d["businessId"] = businessId
		d["draftPostId"] = draftPostId
		
		return d
	}
}

class sentOffer { //when business goes back to look at previously sent out offers.
	var poolId: String
	var draftOfferId: String
	var inProgressPosts: [InProgressPost]
	
	var sentOfferId: String
	var businessId: String
	
	var title: String
	var timeSent: Date
	
	init(dictionary d: [String: Any], businessId id: String, sentOfferId soid: String) {
		businessId = id
		sentOfferId = soid
		
		poolId = d["poolId"] as! String
		draftOfferId = d["draftOfferId"] as! String
		inProgressPosts = d["inProgressPosts"] as! [InProgressPost]
		title = d["title"] as! String
		timeSent = (d["timeSent"] as! String).toUDate()
		
	}

	init(poolId pid: String, draftOfferId doid: String, businessId bid: String, title t: String) {
		poolId = pid
		draftOfferId = doid
		businessId = bid
		inProgressPosts = []
		
		title = t
		timeSent = Date()
		
		sentOfferId = GetNewID()
	}
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["poolId"] = poolId
		d["draftOfferId"] = draftOfferId
		d["inProgressPosts"] = inProgressPosts
		d["title"] = title
		d["timeSent"] = timeSent.toUString()
		
		return d
	}
}
