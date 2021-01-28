//
//  New Globals.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

var Myself: Influencer!

var globalBasicInfluencers: [BasicInfluencer] = []
var globalBasicBusinesses: [BasicBusiness] = []
var globalBasicBoth: [Any] = []
var offerPool: [PoolOffer] = []

func GetNewID() -> String {
	return Date().toString(dateFormat: "yyyy-MM-dd HH:mm:ss") + ", " + randomString(length: 15)
}
