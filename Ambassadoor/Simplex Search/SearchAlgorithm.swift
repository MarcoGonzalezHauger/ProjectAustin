//
//  SearchAlgorithm.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/20/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

func GetViewableSocialData() -> [User] {
	var data = global.SocialData
	data = data.filter({ (usr) -> Bool in
		let goodVersion = usr.version != "0.0.0"
		if API.isForTesting {
			return goodVersion
		} else {
			return goodVersion && !usr.isForTesting
		}
	})
	return data
}

func GetViewableBusinessData() -> [CompanyDetails] {
	var data = global.BusinessUser
	data = data.filter({ (bus) -> Bool in
		return !bus.isForTesting
	})
	return data
}

func GetInfluencersInOrder() -> [User] {
	return GetViewableSocialData().sorted{
		if $0.averageLikes != $1.averageLikes {
			return $0.averageLikes ?? 0 > $1.averageLikes ?? 0
		} else {
			return $0.name! > $1.name!
		}
	}
}

func GetBusinessInOrder() -> [CompanyDetails] {
	return GetViewableBusinessData().sorted{
		if ($0.followers ?? []).count != ($1.followers ?? []).count {
			return ($0.followers ?? []).count > ($1.followers ?? []).count
		} else {
			return $0.name > $1.name
		}
	}
}

func GetBothInOrder() -> [AnyObject] {
	var finallist: [AnyObject] = []
	var influencers = GetInfluencersInOrder()
	var businesses = GetBusinessInOrder()
	let ogCount = influencers.count + businesses.count
	while finallist.count < ogCount {
		for index in 1...3 {
			if influencers.count > 0 {
				finallist.append(influencers[0])
				influencers.remove(at: 0)
			}
		}
		if businesses.count > 0 {
			finallist.append(businesses[0])
			businesses.remove(at: 0)
		}
	}
	return finallist
}
