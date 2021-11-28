//
//  CalculatedValues.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

extension BasicInfluencer {
	var engagementRate: Double {
		if followerCount == 0 {
			return 0
		}
		return averageLikes / followerCount
	}
	var engagementRateInt: Int {
		return Int((engagementRate * 100).rounded(.down))
	}
	var baselinePricePerPost: Double {
		return averageLikes * cashToLikesCoefficient
	}
	var age: Int {
		return Calendar.current.dateComponents([.year], from: birthday, to: Date()).year!
	}
	var isForTesting: Bool {
		get {
			return checkFlag("isForTesting")
		}
	}
	var resizedProfile: String {
		get {
			let resizedUrl: String = self.profilePicURL.replacingOccurrences(of: "profile%2F", with: "profile%2Fsmall%2F").replacingOccurrences(of: ".jpeg", with: "_256x256.jpeg").replacingOccurrences(of: ".png", with: "_256x256.jpeg")
            print("256=",resizedUrl)
			return resizedUrl
		}
	}
}

extension Business {
	func GetActiveBasicBusiness() -> BasicBusiness? {
		for b in basics {
			if b.basicId == activeBasicId {
				return b
			}
		}
		return nil
	}
}

extension BasicBusiness {
	var avaliableOffers: [PoolOffer] {
		return getFilteredOfferPool().filter{$0.basicId == basicId}
	}
	var isForTesting: Bool {
		get {
			return checkFlag("isForTesting")
		}
	}
}

extension OfferFilter {
    ///   Check if the influencer pass the filter based on age, gender, location, interest and Cost Value
    /// - Parameter basicInfluencer: send Influencer which one need to check
    /// - Returns: Returns true if influencer pass the offer's Filter otherwise false
	func DoesInfluencerPassFilter(basicInfluencer: BasicInfluencer) -> Bool {
		if basicInfluencer.age < 18 { //If a influencer is not 18, NOTHING should be acceptable for them
			return false
		}
		if mustBe21 {
			if basicInfluencer.age < 21 {
				return false
			}
		}
		if basicInfluencer.averageLikes == 0 {
			return false
		}
		if basicInfluencer.engagementRate < minimumEngagementRate {
			return false
		}
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
		if basicInfluencer.followingBusinesses.contains(basicId) {
			return true
		}
		if acceptedInterests.count != 0 {
			for cat in basicInfluencer.interests {
				if acceptedInterests.contains(cat) {
					return true
				}
			}
		} else {
			return true
		}
		print("Failed finally.")
		return false
	}
}

extension PoolOffer {
    
    /// Check if the influencer is already accepted this offer
    /// - Parameter inf: Send Infuencer which one need to check.
    /// - Returns: returns true if influencer is already acceoted this offer otherwise flase.
	func hasInfluencerAccepted(influencer inf: Influencer) -> Bool {
		if acceptedUserIds.contains(Myself.userId) {
			return true
		}
		for p in inf.inProgressPosts {
			if p.PoolOfferId == self.poolId {
				return true
			}
		}
		return false
	}
	func BasicBusiness() -> BasicBusiness? {
		return GetBasicBusiness(id: basicId)
	}
    
    /// We detemine every influencer cost based on their average likes and Ambassadoor coefficiemt. Here
    /// Business user may give credit boost to influencer by pay increase. This way we calculate Influencer cost per post.
	/// If the offer is a gift card offer, then guarentee $20.
    /// - Parameter inf: send Influencer which one need to check
    /// - Returns: Influencer Cost In Double
	func pricePerPost(forInfluencer inf: BasicInfluencer) -> Double {
		if self.checkFlag("xo case study") {
			return 20
		}
		return inf.baselinePricePerPost * self.payIncrease
	}
    
    ///   Calculate the total cost of the influencer for the offer
    /// - Parameter inf: send Influencer which one need to check
    /// - Returns: Total cost of the Influencer for the offer in Double
	func totalCost(forInfluencer inf: BasicInfluencer) -> Double {
		
		if self.checkFlag("xo case study") {
			return 20
		}
		
		return pricePerPost(forInfluencer: inf) * Double(draftPosts.count)
	}
    
    ///   Check if Influencer cost is affordable to the offer price
    /// - Parameter inf: send Influencer which one need to check
    /// - Returns: Returns true if influencer affordable for the offer otherwise false
	func canAffordInflunecer(forInfluencer inf: BasicInfluencer) -> Bool {
		return cashPower >= totalCost(forInfluencer: inf)
	}
    
    ///   Show offers to influencer based on Influencer's Age, Gender, Interest, Location and Cost Value
    /// - Parameter inf: Send influencer which one need to check.
    /// - Returns: Returns true if influencer can able to accept the offer otherwise false
	func canBeAccepted(forInfluencer inf: Influencer) -> Bool {
		return filter.DoesInfluencerPassFilter(basicInfluencer: inf.basic) && canAffordInflunecer(forInfluencer: inf.basic) && !hasInfluencerAccepted(influencer: inf)
	}
}

extension InProgressPost {
	func BasicBusiness() -> BasicBusiness? {
		return GetBasicBusiness(id: basicId)
	}
}
