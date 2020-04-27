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
	var zipCode: Int?
	var instagramKey: String
	var instagramUsername: String
}

func accInfoUpdate() {
	for p in NewAccountListeners {
		p.AccountUpdated(NewAccount: NewAccount)
	}
}
	
var NewAccount: NewAccountInfo = NewAccountInfo.init(email: "", password: "", categories: [], gender: "", zipCode: 0, instagramKey: "", instagramUsername: "")

var NewAccountListeners: [NewAccountListener] = []
