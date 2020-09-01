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
        var OffersHistory: [Offer] = [] { didSet {
            OffersHistory = OffersHistory.sorted{ (Offer1, Offer2) -> Bool in
                return (Offer1.money / Double(Offer1.posts.count)) > (Offer2.money / Double(Offer2.posts.count))    }
            EachListener(){ if let targetfunction = $0.OffersHistoryChanged { targetfunction()}}}}
    
	//The offers that are currently in the users inbox.
	var AvaliableOffers: [Offer] = [] { didSet {
        
//		UIApplication.shared.applicationIconBadgeNumber = AvaliableOffers.count
		AvaliableOffers = AvaliableOffers.sorted{ (Offer1, Offer2) -> Bool in
			return (Offer1.money / Double(Offer1.posts.count)) > (Offer2.money / Double(Offer2.posts.count))	}
		EachListener(){ if let targetfunction = $0.AvaliableOffersChanged { targetfunction()}}}}
	
	//The offers that the user has rejected.
	var RejectedOffers: [Offer] = [] { didSet { EachListener(){ if let targetfunction = $0.RejectedOffersChanged { targetfunction()}}}}
	
	//The offers that the user has accepted.
	var AcceptedOffers: [Offer] = [] { didSet {	EachListener() { if let targetfunction = $0.AcceptedOffersChanged { targetfunction()}}}
	}
	
	//The offers the user has completed.
	var CompletedOffers: [Offer] = [] {	didSet { EachListener(){ if let targetfunction = $0.CompletedOffersChanged { targetfunction()}}}}
	
	//The offers the user has completed.
	var SocialData: [User] = [] { didSet { EachListener(){ if let targetfunction = $0.SocialDataChanged{ targetfunction()}}}}
    
    //Offers tied to a User
    var OffersForUser: [Offer] = [] { didSet { EachListener(){ if let targetfunction = $0.OffersForUserChanged{ targetfunction()}}}}
    
    
	
	//Every VC that is connected to this global variable.
	func EachListener(updatefor: (_ Listener: GlobalListener) -> ()) {
		for x : GlobalListener in delegates {
			updatefor(x)
		}
	}	
	var delegates: [GlobalListener] = []
    
    var BusinessUser = [CompanyDetails]()
    
    
    
    var deviceFIRToken = ""
    var dwollaCustomerInformation = DwollaCustomerInformation()
    //Influencer worked Companies
    var influencerWrkCompany = [Comapny]()
    var inProgressOfferCount = [Int]()
    var cachedImageList = [CachedImages]()
    var identifySegment = ""
    var allInprogressOffer = [Offer]()
    var userList = [AnyObject]()
    var followerList = [FollowingInformation]()
    var influencerList = [User]()
    var followOfferList = [Offer]()
    var allOfferList = [Offer]()
    var InstagramAPI: APImode? = nil
    var appVersion: String? = nil
    
}

let global = CentralVariables()
