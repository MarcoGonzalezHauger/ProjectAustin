//
//  Social Sort Algorithms.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

func RefreshPublicData() {
	let ref = Database.database().reference().child("Accounts/Public")
	ref.observeSingleEvent(of: .value) { (snapshot) in
		//Download and serialize the public accounts.
		let dictionary = snapshot.value as! [String: Any]
		SerializePublicData(dictionary: dictionary)
		
	}
}

func SerializePublicData(dictionary: [String: Any]) {
	var infs: [BasicInfluencer] = []
	var basicbu: [BasicBusiness] = []
	let influencers = dictionary["influencers"] as! [String: Any]
	for i in influencers.keys {
		let inf = BasicInfluencer.init(dictionary: influencers[i] as! [String: Any], userId: i)
		infs.append(inf)
	}
	let businesses = dictionary["businesses"] as! [String: Any]
	for b in businesses.keys {
		let bus = BasicBusiness.init(dictionary: businesses[b] as! [String: Any], businessId: b)
		basicbu.append(bus)
	}
	
	//sort both influencer and business accounts.
	
	infs.sort { (inf1, inf2) -> Bool in
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
	basicbu.sort { (bus1, bus2) -> Bool in
		if bus1.followedBy.count == bus2.followedBy.count {
			return bus1.name > bus2.name
		} else {
			return bus1.followedBy.count > bus2.followedBy.count
		}
	}
	
	//create list of both.
	
	var finallist: [Any] = []
	var tempinf = infs
	var tempbus = basicbu
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
}
