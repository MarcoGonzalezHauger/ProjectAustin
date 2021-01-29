//
//  Social Sort Algorithms.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

func RefreshPublicData(finished: (() -> ())?) {
	let ref = Database.database().reference().child("Accounts/Public")
	ref.observeSingleEvent(of: .value) { (snapshot) in
		//Download and serialize the public accounts.
		let dictionary = snapshot.value as! [String: Any]
		SerializePublicData(dictionary: dictionary, finished: finished)
		
	}
}

func SerializePublicData(dictionary: [String: Any], finished: (() -> ())?) {
	
	var infs: [BasicInfluencer] = []
	var basicbu: [BasicBusiness] = []
	let influencers = dictionary["Influencers"] as! [String: Any]
	for i in influencers.keys {
		let inf = BasicInfluencer.init(dictionary: influencers[i] as! [String: Any], userId: i)
		if !inf.checkFlag("isForTesting") || thisUserIsForTesting {
			infs.append(inf)
		}
	}
	let businesses = dictionary["Businesses"] as! [String: Any]
	for b in businesses.keys {
		let bus = BasicBusiness.init(dictionary: businesses[b] as! [String: Any], businessId: b)
		if !bus.checkFlag("isForTesting") || thisUserIsForTesting {
			basicbu.append(bus)
		}
	}
	
	//sort both influencer and business accounts.
	
	infs = sortInfluencers(basicInfluencers: infs)
	basicbu = sortBusinesses(basicBusinesses: basicbu)
	
	//create list of both.
	
	globalBasicInfluencers = infs
	globalBasicBusinesses = basicbu
	globalBasicBoth = combineListsToBoth(basicBusinesses: basicbu, basicInfluencers: infs, withSort: false)
	finished?()
}

func sortInfluencers(basicInfluencers: [BasicInfluencer]) -> [BasicInfluencer] {
	return basicInfluencers.sorted(by: sortCompareInfluencers(influencer1:influencer2:))
}

func sortBusinesses(basicBusinesses: [BasicBusiness]) -> [BasicBusiness] {
	return basicBusinesses.sorted(by: sortCompareBusiness(business1:business2:))
	
}

func sortCompareBusiness(business1 bus1: BasicBusiness, business2 bus2: BasicBusiness) -> Bool {
	if bus1.followedBy.count == bus2.followedBy.count {
		return bus1.name > bus2.name
	} else {
		return bus1.followedBy.count > bus2.followedBy.count
	}
}

func sortCompareInfluencers(influencer1 inf1: BasicInfluencer, influencer2 inf2: BasicInfluencer) -> Bool {
	if inf1.engagmentRate == inf2.engagmentRate {
		if inf1.averageLikes == inf2.averageLikes {
			return inf1.username > inf2.username
		} else {
			return inf1.averageLikes > inf2.averageLikes
		}
	} else {
		return inf1.engagmentRate > inf2.engagmentRate
	}
}

func combineListsToBoth(basicBusinesses: [BasicBusiness], basicInfluencers: [BasicInfluencer], withSort: Bool) -> [Any] {
	var finallist: [Any] = []
	var tempinf = basicInfluencers
	var tempbus = basicBusinesses
	if withSort {
		tempinf	 = sortInfluencers(basicInfluencers: tempinf)
		tempbus	 = sortBusinesses(basicBusinesses: tempbus)
	}
	let totalCount = tempinf.count + tempbus.count
	while finallist.count < totalCount {
		for _ in 1...3 {
			if tempinf.count > 0 {
				finallist.append(tempinf[0])
				tempinf.remove(at: 0)
			}
		}
		if tempbus.count > 0 {
			finallist.append(tempbus[0])
			tempbus.remove(at: 0)
		}
	}
	return finallist
}

enum SearchFor: String {
	case influencers, businesses, both
}

func SearchSocialData(searchQuery: String, searchIn: SearchFor) -> [Any] {
	
	let query = searchQuery.lowercased()
	
	var listOfUsers: [Any] = []
	if searchIn == .influencers || searchIn == .both {
		listOfUsers.append(contentsOf: globalBasicInfluencers)
	}
	if searchIn == .businesses || searchIn == .both {
		listOfUsers.append(contentsOf: globalBasicBusinesses)
	}
	
	if query == "" {
		switch searchIn {
		case .both:
			return globalBasicBoth
		case .influencers:
			return globalBasicInfluencers
		default:
			return globalBasicBusinesses
		}
	}
	
	var results: [String: Double] = [:]
	
	for u in listOfUsers {
		if let u = u as? BasicBusiness {
			let businessName = u.name.lowercased()
			if businessName.contains(query) {
				results[u.businessId] = 60
			}
			if businessName.hasPrefix(query) {
				results[u.businessId] = 80
			}
		}
		if let u = u as? BasicInfluencer {
			let infName = u.name.lowercased()
			let infUsername = u.username.lowercased()
			
			if infName.contains(query) {
				results[u.userId] = 40
			}
			if infUsername.contains(query) {
				results[u.userId] = 70
			}
			
			if infName.hasPrefix(query) {
				results[u.userId] = 75
			}
			if infUsername.hasPrefix(query) {
				results[u.userId] = 90
			}
		}
	}
	
	listOfUsers = listOfUsers.filter {
		let id: String = ($0 as? BasicInfluencer)?.userId ?? ($0 as! BasicBusiness).businessId
		return results[id] != nil
	}
	
	listOfUsers.sort { (obj1, obj2) -> Bool in
		let idFor1: String = (obj1 as? BasicInfluencer)?.userId ?? (obj1 as! BasicBusiness).businessId
		let idFor2: String = (obj2 as? BasicInfluencer)?.userId ?? (obj2 as! BasicBusiness).businessId
		if results[idFor1]! == results[idFor2]! { // It is impossible for a business and influencer to be assigned the same Double.
			if let inf1 = obj1 as? BasicInfluencer {
				let inf2 = obj2 as! BasicInfluencer
				return sortCompareInfluencers(influencer1: inf1, influencer2: inf2)
			} else {
				let bus1 = obj1 as! BasicBusiness
				let bus2 = obj2 as! BasicBusiness
				return sortCompareBusiness(business1: bus1, business2: bus2)
			}
		} else {
			return results[idFor1]! > results[idFor2]!
		}
	}
	
	return listOfUsers
}





