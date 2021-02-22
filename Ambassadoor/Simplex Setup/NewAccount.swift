//
//  NewAccountVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/7/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol NewAccountListener {
	func AccountUpdated(NewAccount: NewAccountInfo)
}

struct NewAccountInfo {
	var email: String
	var password: String
	var categories: [String]
	var gender: String
	var zipCode: String
	var instagramKey: String
	var instagramUsername: String
    var authenticationToken: String
    var averageLikes: Double
    var followerCount: Int64
    var id: String
    var instagramName: String
    var profilePicture: String
    var referralCode: String
    var dob: String
    
}

func accInfoUpdate() {
	for p in NewAccountListeners {
		p.AccountUpdated(NewAccount: NewAccount)
	}
}
	
var NewAccount: NewAccountInfo = NewAccountInfo.init(email: "", password: "", categories: [], gender: "", zipCode: "", instagramKey: "", instagramUsername: "", authenticationToken: "", averageLikes: 0, followerCount: 0, id: "", instagramName: "", profilePicture: "", referralCode: "", dob: "")

var NewAccountListeners: [NewAccountListener] = []
