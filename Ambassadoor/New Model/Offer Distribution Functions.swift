//
//  Offer Distribution Functions.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

extension DraftOffer {
	func distributeToPool(asBusiness: Business, filter: OfferFilter, withMoney: Double, completed: @escaping (_ failedReason: String, _ newBusinessWithChanges: Business?) -> ()) {
		if asBusiness.finance.balance < withMoney - 0.01 {
			completed("You do not enough money to distribute this offer.", nil)
			return
		}
		let newPoolOffer = PoolOffer.init(draftOffer: self, filter: filter, withMoney: withMoney, createdBy: asBusiness)
		newPoolOffer.UpdateToFirebase { (success) in
			if success {
				asBusiness.sentOffers.append(sentOffer.init(poolId: newPoolOffer.poolId, draftOfferId: self.draftId, businessId: self.businessId, title: self.title))
				asBusiness.finance.balance -= withMoney
				if asBusiness.finance.balance < 0 {
					asBusiness.finance.balance = 0
				}
				completed("", asBusiness)
				asBusiness.UpdateToFirebase(completed: nil)
			} else {
				completed("There was an network error.", nil)
			}
		}
	}
}

extension PoolOffer {
	func acceptThisOffer(asInfluencer thisInfluencer: Influencer, completed: @escaping (_ failedReason: String, _ newInfluencerWithChanges: Influencer?) -> ()) {
		
		for p in thisInfluencer.inProgressPosts {
			if p.PoolOfferId == self.poolId {
				completed("You already accepted this offer.", nil)
			} else if p.draftOfferId == self.draftOfferId {
				completed("You already accepted this offer.", nil)
			}
		}
		
		let ref = Database.database().reference().child(poolPath)
		ref.observeSingleEvent(of: .value) { (dataSnapshot) in
			
			let offerRefreshDictionary = dataSnapshot.value as! [String: Any]
			self.cashPower = offerRefreshDictionary["cashPower"] as! Double
			self.filter = OfferFilter.init(dictionary: offerRefreshDictionary["filter"] as! [String: Any], businessId: self.businessId)
			
			let costPerPost = thisInfluencer.basic.baselinePricePerPost * self.payIncrease
			let totalCost = costPerPost * Double(self.draftPosts.count)
			if totalCost > self.cashPower {
				completed("There isn't enough money in this offer to afford your fee. (\(NumberToPrice(Value: totalCost)))", nil)
			} else {
				if self.filter.DoesInfluencerPassFilter(basicInfluencer: thisInfluencer.basic) {
					completed("You don't meet the filters of this offer.", nil)
				} else {
					let newCashPower = self.cashPower - totalCost
					
					var newPosts: [InProgressPost] = [] // we do this before updating cashPower, because if the app crahses while compiling a list of new draftposts AFTER the money has been withdrawn, that would be a huge problem.
					for p in self.draftPosts {
						let newInP = InProgressPost.init(draftPost: p, comissionUserId: self.comissionUserId, comissionBusinessId: self.comissionBusinessId, userId: thisInfluencer.userId, poolOfferId: self.poolId, businessId: self.businessId, draftOfferId: self.draftOfferId, cashValue: costPerPost)
						newPosts.append(newInP)
					}
					
					ref.setValue(["cashPower": newCashPower]) { (err, dataref) in
						if err != nil {
							thisInfluencer.inProgressPosts.append(contentsOf: newPosts)
							thisInfluencer.UpdateToFirebase(completed: nil)
							completed("", thisInfluencer)
						} else {
							completed("A network error prevented you from accepting this offer.", nil)
						}
					}
				}
			}
		}
	}
}
