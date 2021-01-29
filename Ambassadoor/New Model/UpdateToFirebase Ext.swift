//
//  UpdateToFirebase Ext.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

extension PoolOffer {
	var poolPath: String {
		get {
			return "Pool/\(self.poolId)"
		}
	}
	
	func UpdateToFirebase(completed: ((_ success: Bool) -> ())?) {
		let ref = Database.database().reference().child(poolPath)
		ref.updateChildValues(self.toDictionary()) { (err, dataref) in
			completed?(err != nil)
		}
	}
}

extension Business {
	
	var privatePath: String {
		get {
			return "Accounts/Private/Businesses/\(self.businessId)"
		}
	}
	
	func UpdateToFirebase(completed: ((_ success: Bool) -> ())?) {
		let ref = Database.database().reference().child(privatePath)
		ref.updateChildValues(self.toDictionary()) { (err, dataref) in
			completed?(err != nil)
		}
		self.basic?.UpdateToFirebase(completed: {_ in })
	}
}

extension BasicBusiness {
	func UpdateToFirebase(completed: ((_ success: Bool) -> ())?) {
		let ref = Database.database().reference().child(publicPath)
		ref.updateChildValues(self.toDictionary()) { (err, dataref) in
			completed?(err != nil)
		}
	}
	
	var publicPath: String {
		get {
			return "Accounts/Public/Businesses/\(self.businessId)"
		}
	}
}

extension Influencer {
	
	var privatePath: String {
		get {
			return "Accounts/Private/Influencers/\(self.userId)"
		}
	}
	
	func UpdateToFirebase(completed: ((_ success: Bool) -> ())?) {
		let ref = Database.database().reference().child(privatePath)
		ref.updateChildValues(self.toDictionary()) { (err, dataref) in
			completed?(err != nil)
		}
		self.basic.UpdateToFirebase(completed: {_ in })
	}
	
	func setUpAsync() {
		let ref = Database.database().reference().child(basic.publicPath)
		ref.observe(.childChanged) { (snap) in
			let dict = snap.value as! [String: Any]
			self.basic = BasicInfluencer.init(dictionary: dict, userId: self.userId)
		}

	}
}

extension BasicInfluencer {
	
	var publicPath: String {
		get {
			return "Accounts/Public/Influencers/\(self.userId)"
		}
	}
	
	func UpdateToFirebase(completed: ((_ success: Bool) -> ())?) {
		let ref = Database.database().reference().child(publicPath)
		ref.updateChildValues(self.toDictionary()) { (err, dataref) in
			completed?(err != nil)
		}
	}
}