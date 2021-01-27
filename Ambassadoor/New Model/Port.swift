//
//  Port.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase






/*
So this function will take everything in the current database and port it all to Ambassadoor 3.0 Update database.
No Loss.
*/

func ConvertEntireDatabase(iUnderstandWhatThisFunctionDoes ok: Bool) {
	if ok {
		let ref = Database.database().reference().child("/")
		ref.observeSingleEvent(of: .value) { (snap) in
			let od = snap.value as! [String: Any]
			print("DATABASE HAS BEEN DOWNLOADED\n====================================")
			DoStuff(od: od)
		}
	}
}

func DoStuff(od: [String: Any]) {
	let usersdb = od["users"] as! [String: Any]
	var users: [User] = []
	for u in usersdb.keys {
		do {
			try users.append(User.init(dictionary: usersdb[u] as! [String: Any]))
		} catch {
			
		}
	}
	for u in users {
		if u.version != "0.0.0" {
			print("Updating User: \(u.username)")
			var flags: [String] = []
			if u.isForTesting {
				flags.append("isForTesting")
			}
			if u.isDefaultOfferVerify {
				flags.append("isVerified")
			}
			
			let authDict: [String: Any] = (od["InfluencerAuthentication"] as! [String: Any])[u.id] as! [String: Any]
			print(authDict)
			
			//https://amassadoor.firebaseio.com/InfluencerStripeAccount/a/AccountDetail
			
			let stripeDict: [String: Any] = ((od["InfluencerStripeAccount"] as! [String: Any])[u.id] as! [String: Any])["AccountDetail"] as! [String : Any]
			
			let NewUserID = u.username + "." + randomString(length: 15)
			
			
			let stripeAcc = StripeAccountInformation.init(dictionary: stripeDict, userOrBusinessId: NewUserID)
			
			let tgender = u.gender?.rawValue ?? "Other"
			
			let tbday = Date.init(timeIntervalSince1970: 123)
			
			let basic = BasicInfluencer.init(name: u.name!, username: u.username, followerCount: u.followerCount, averageLikes: u.averageLikes ?? 0, profilePicURL: u.profilePicURL ?? "", zipCode: u.zipCode ?? "0", gender: tgender, joinedDate: u.joinedDate?.toUDate() ?? Date(), categories: u.categories!, referralCode: u.referralcode, flags: flags, followingInfluencers: [], followingBusinesses: [], followedBy: [], birthday: tbday, userId: NewUserID)
			
			let inffin = InfluencerFinance.init(balance: u.yourMoney, userId: NewUserID, stripeAccount: stripeAcc)
			
			let influener = Influencer.init(basic: basic, finance: inffin, email: authDict["email"] as! String, password: authDict["password"] as! String, instagramAuthToken: u.authenticationToken, instagramAccountId: u.id, tokenFIR: u.tokenFIR ?? "", userId: NewUserID)
			
			influener.UpdateToFirebase(completed: nil)
		}
	}
	print("SUCCESSFULLY DOWNLOADED ENTIRE DATABASE.")

}
