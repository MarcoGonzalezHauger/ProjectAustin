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
	allpossibleusers = DoClassicSort(influencers: allpossibleusers)
	return allpossibleusers
}

func GetSameTierUsers() -> [User] {
	let myTier = GetTierForInfluencer(influencer: Yourself!)
	var allpossibleresults = global.SocialData
	allpossibleresults = allpossibleresults.filter { return GetTierForInfluencer(influencer: $0) == myTier }
	allpossibleresults = DoClassicSort(influencers: allpossibleresults)
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
		let influencer1distance = distances[$0.zipCode ?? "_"] ?? 100 //The reson I used a underscore is beacuse there is NO WAY that that is a possible zip code, ensuring the number will be 100.
		let influencer1Score: Double = Double((1/((influencer1distance+5)*0.1))/5) + Double(GetTierForInfluencer(influencer: $0)/4)
		let influencer2distance = distances[$1.zipCode ?? "_"] ?? 100
		let influencer2Score: Double = Double((1/((influencer2distance+5)*0.1))/5) + Double(GetTierForInfluencer(influencer: $1)/4)
		return influencer1Score > influencer2Score
	}
	
	return editableInflunecers
}
