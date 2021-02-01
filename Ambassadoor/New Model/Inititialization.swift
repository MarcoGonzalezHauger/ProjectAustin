//
//  Inititialization.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/31/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

func InitilizeAmbassadoor() {
	
	let email = "brunognzalez@gmail.com"
	
	let ref = Database.database().reference().child("Accounts/Private/Influencers")
	let query = ref.queryOrdered(byChild: "email").queryEqual(toValue: email)
	query.observeSingleEvent(of: .value, with: { (snapshot) in
		
		if let snapValue = snapshot.value as? [String: Any] {
			let userId = snapValue.keys.first!
			let userValue = snapValue.values.first as! [String: Any]
			
			print(snapValue)
			Myself = Influencer.init(dictionary: userValue, userId: userId)
			
			print("Myself variable has been set to \(Myself.basic.name)")
			StartListening()
		} else {
			print("Could find stuff.")
		}
		
	}, withCancel: { (err) in
		print("ERROR WITH FINDING EMAIL: " + err.localizedDescription)
	})
	
}

func StartListening() {
	
	RefreshPublicData {
		print("Public data downloaded.")
	}
	
	startListeningToMyself(userId: Myself.userId)
	
	StartListeningToPublicData()
	
	startListeningToOfferPool()
	
}
