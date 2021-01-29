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
	var engagmentRate: Double {
		if followerCount == 0 {
			return 0
		}
		return averageLikes / followerCount
	}
	var engagmentRateInt: Int {
		return Int((engagmentRate * 100).rounded(.down))
	}
	var baselinePricePerPost: Double {
		return averageLikes * cashToLikesCoefficient
	}
	var age: Int {
		return Calendar.current.dateComponents([.year], from: birthday, to: Date()).year!
	}
}

extension OfferFilter {
	func DoesInfluencerPassFilter(basicInfluencer: BasicInfluencer) -> Bool {
		if basicInfluencer.age < 18 { //If a influencer is not 18, NOTHING should be acceptable for them
			return false
		}
		if mustBe21 {
			if basicInfluencer.age < 21 {
				return false
			}
		}
		if basicInfluencer.engagmentRate < minimumEngagmentRate {
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
		if basicInfluencer.followingBusinesses.contains(businessId) {
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
		return false
	}
}

extension PoolOffer {
	func hasInfluencerAccepted(influencer inf: Influencer) -> Bool {
		for p in inf.inProgressPosts {
			if p.PoolOfferId == self.poolId {
				return true
			}
		}
		return false
	}
}
