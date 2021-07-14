//
//  Social Interactions ext.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

extension BasicInfluencer {
	
	func Follow(as myInf: Influencer) {
		if !self.isFollowing(as: myInf) {
			self.followedBy.append(myInf.userId)
			self.UpdateToFirebase(completed: nil)
			myInf.basic.followingInfluencers.append(self.userId)
			myInf.UpdateToFirebase(alsoUpdateToPublic: true, completed: nil)
		}
	}
	
	func Unfollow(as myInf: Influencer) {
		self.followedBy.removeAll{$0 == myInf.userId}
		self.UpdateToFirebase(completed: nil)
		myInf.basic.followingInfluencers.removeAll{$0 == self.userId}
		myInf.basic.UpdateToFirebase(completed: nil)
	}
	
	func isFollowing(as myInf: Influencer) -> Bool {
		return followedBy.contains(myInf.userId)
	}
    
//    func FollowBusiness(as myInf: Business) {
//        if !self.isFollowingBusiness(as: myInf) {
//            self.followingBusinesses.append(myInf.businessId)
//            self.UpdateToFirebase(completed: nil)
//        }
//    }
//
//    func UnfollowBusiness(as myInf: Business) {
//        self.followingBusinesses.removeAll{$0 == myInf.businessId}
//        self.UpdateToFirebase(completed: nil)
//    }
//
//    func isFollowingBusiness(as myInf: Business) -> Bool {
//        return followingBusinesses.contains(myInf.businessId)
//    }
}

extension BasicBusiness {
	
	func Follow(as myInf: Influencer) {
		if !self.isFollowing(as: myInf) {
			self.followedBy.append(myInf.userId)
			self.UpdateToFirebase(completed: nil)
			myInf.basic.followingBusinesses.append(self.basicId)
			myInf.UpdateToFirebase(alsoUpdateToPublic: true, completed: nil)
		}
		
	}
	
	func Unfollow(as myInf: Influencer) {
		self.followedBy.removeAll{$0 == myInf.userId}
		self.UpdateToFirebase(completed: nil)
        self.UpdateToFirebase(completed: nil)
		myInf.basic.followingBusinesses.removeAll{$0 == self.basicId}
		myInf.basic.UpdateToFirebase(completed: nil)
	}
	
	func isFollowing(as myInf: Influencer) -> Bool {
		return followedBy.contains(myInf.userId)
        //return myInf.basic.followingBusinesses.contains(self.basicId)
	}
	
	func GetAvaliableOffersFromBusiness() -> [PoolOffer] {
		return getFilteredOfferPool().filter{$0.basicId == basicId}
	}
}
