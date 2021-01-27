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
		return averageLikes / followerCount
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
