//
//  OfferPool algo.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

protocol OfferPoolRefreshDelegate {
	func refreshed()
}

var offerPoolListeners: [OfferPoolRefreshDelegate] = []

//This function only needs to activated ONCE on startup of the app. After that please do not execute it again.

func startListeningToOfferPool() {
	let ref = Database.database().reference().child("Pool")
	ref.observeSingleEvent(of: .value) { (snap) in
		let dict = snap.value as! [String: Any]
		serializeAndUpdateOfferPool(dictionary: dict)
	}
	ref.observe(.childChanged) { (snap) in
		let dict = snap.value as! [String: Any]
		serializeAndUpdateOfferPool(dictionary: dict)
	}
}

func serializeAndUpdateOfferPool(dictionary d: [String: Any]) {
	var pool: [PoolOffer] = []
	for id in d.keys {
		let thisOffer = PoolOffer.init(dictionary: d[id] as! [String: Any], poolId: id)
		pool.append(thisOffer)
	}
	
	pool = pool.filter{$0.cashPower > (Myself.basic.baselinePricePerPost * Double($0.draftPosts.count) * $0.payIncrease)} //only offers that contian enough money to be accepted by an influencer.
	
	pool.sort { (o1, o2) -> Bool in
		if o1.payIncrease == o2.payIncrease {
			return o1.sentDate > o2.sentDate
		} else {
			return o1.payIncrease > o2.payIncrease
		}
	}
	
	for p in offerPoolListeners {
		p.refreshed()
	}
}

func getFollowingOfferPool() -> [PoolOffer] {
	return getFilteredOfferPool().filter{Myself.basic.followingBusinesses.contains($0.businessId)}
}

func getFilteredOfferPool() -> [PoolOffer] {
	return offerPool.filter{$0.filter.DoesInfluencerPassFilter(basicInfluencer: Myself.basic)}
}

func GetOfferPool() -> [PoolOffer] {
	return offerPool
}
