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

protocol myselfRefreshDelegate {
	func myselfRefreshed()
}

var myselfRefreshListeners: [myselfRefreshDelegate] = []
var offerPoolListeners: [OfferPoolRefreshDelegate] = []

//This function only needs to activated ONCE on startup of the app. After that please do not execute it again.

func startListeningToOfferPool() {
	let listenRef = Database.database().reference().child("Pool")
	
	listenRef.observe(.value) { (snap) in
		serializeAndUpdateOfferPool(dictionary: snap.value as! [String: Any])
	}
}

func startListeningToMyself(userId: String) {
	let listenRef = Database.database().reference().child("Accounts/Private/Influencers/\(Myself.userId)")
	
	listenRef.observe(.value) { (snap) in
		Myself = Influencer.init(dictionary: snap.value as! [String: Any], userId: snap.key)
		for l in myselfRefreshListeners {
			l.myselfRefreshed()
		}
	}
	
	let PublicFollowedByRef = Database.database().reference().child("Accounts/Public/Influencers/\(Myself.userId)/followingBusinesses")
	
	PublicFollowedByRef.observe(.value) { (snap) in
		if let followedBy = snap.value as? [String] {
			Myself.basic.followedBy = followedBy
		} else {
			Myself.basic.followedBy = []
		}
		for l in myselfRefreshListeners {
			l.myselfRefreshed()
		}
	}
}

func serializeAndUpdateOfferPool(dictionary d: [String: Any]) {
	var pool: [PoolOffer] = []
	for id in d.keys {
		let thisOffer = PoolOffer.init(dictionary: d[id] as! [String: Any], poolId: id)
		pool.append(thisOffer)
	}
	SortAndUpdateOfferPool(pool: pool)
}

func SortAndUpdateOfferPool(pool p: [PoolOffer]?) {
	var pool: [PoolOffer]! = p
	if pool == nil {
		pool = offerPool.filter{$0.cashPower > (Myself.basic.baselinePricePerPost * Double($0.draftPosts.count) * $0.payIncrease)} //only offers that contian enough money to be accepted by an influencer.
	} else {
		pool = pool.filter{$0.cashPower > (Myself.basic.baselinePricePerPost * Double($0.draftPosts.count) * $0.payIncrease)} //only offers that contian enough money to be accepted by an influencer.
	}
	
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
	return offerPool.filter{$0.filter.DoesInfluencerPassFilter(basicInfluencer: Myself.basic) && !$0.hasInfluencerAccepted(influencer: Myself)}
}

func GetOfferPool() -> [PoolOffer] {
	return offerPool
}
