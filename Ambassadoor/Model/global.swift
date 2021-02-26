//
//  global.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/23/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import Foundation
import UserNotifications
import UIKit

//Allows any ViewController to add itself to the global as a delegate,
//and get updated whenever there is a change to any of the global variables.
//This is used in the offers and social pages.
@objc protocol GlobalListener {
	@objc optional func AvaliableOffersChanged() -> ()
	@objc optional func RejectedOffersChanged() -> ()
	@objc optional func AcceptedOffersChanged() -> ()
	@objc optional func CompletedOffersChanged() -> ()
	@objc optional func SocialDataChanged() -> ()
    @objc optional func OffersForUserChanged() -> ()
    @objc optional func OffersHistoryChanged() -> ()

}

class CentralVariables {
        
	var delegates: [GlobalListener] = []
    var deviceFIRToken = ""
    var dwollaCustomerInformation = DwollaCustomerInformation()
    //Influencer worked Companies
    var inProgressOfferCount = [Int]()
    var cachedImageList = [CachedImages]()
    var identifySegment = ""
    var appVersion: String? = nil
    var allTimers = [Timer]()
    var isClickedUserFollow = false
    var isClickedBusinesFollow = false
    var otpData = 0
}

let global = CentralVariables()
