//
//  SocialAlgorithms.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/1/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

func GetSameCategoryUsers() -> [User] {
	var allpossibleusers = global.SocialData
	allpossibleusers = allpossibleusers.filter{
		for x in $0.categories ?? [] {
			for y in Yourself!.categories ?? [] {
				if x == y {
					return true
				}
			}
		}
		return false
	}
	allpossibleusers.sort {
		if $0.zipCode == Yourself!.zipCode && $1.zipCode != Yourself.zipCode {
			return true
		}
		if $0.zipCode != Yourself!.zipCode && $1.zipCode == Yourself.zipCode {
			return false
		}
		if GetTierForInfluencer(influencer: $0) > GetTierForInfluencer(influencer: $1) {
			return true
		} else if GetTierForInfluencer(influencer: $0) < GetTierForInfluencer(influencer: $1) {
			return false
		} else {
			return $0.followerCount > $1.followerCount
		}
	}
	return allpossibleusers
}

func GetSameTierUsers() -> [User] {
	let myTier = GetTierForInfluencer(influencer: Yourself!)
	var allpossibleresults = global.SocialData
	allpossibleresults = allpossibleresults.filter { return GetTierForInfluencer(influencer: $0) == myTier }
	allpossibleresults.sort {
		if $0.zipCode == Yourself!.zipCode && $1.zipCode != Yourself.zipCode {
			return true
		}
		if $0.zipCode != Yourself!.zipCode && $1.zipCode == Yourself.zipCode {
			return false
		}
		return $0.followerCount > $1.followerCount
	}
	return allpossibleresults
}

func GetTrendingUsers() -> [User] {
	var allpossibleusers = global.SocialData.filter{$0.zipCode == Yourself!.zipCode}
	//		if Yourself!.followerCount >= minusers {
	//			allpossibleusers.append(Yourself!)
	//		}
	allpossibleusers.sort{return $0.followerCount > $1.followerCount}
	return allpossibleusers
}

func DoClassicSort(influencers: [User]) -> [User] {
	
	var editableInflunecers = influencers
	let distances = GetSocialZipDistances()
	
	editableInflunecers.sort {
		if $0.zipCode == Yourself!.zipCode && $1.zipCode != Yourself.zipCode {
			return true
		}
		if $0.zipCode != Yourself!.zipCode && $1.zipCode == Yourself.zipCode {
			return false
		}
		return $0.followerCount > $1.followerCount
	}
	
	return editableInflunecers
}
