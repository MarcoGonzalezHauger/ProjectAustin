//
//  offerpool.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 18/01/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

var currentOfferPool: [Offer] = []
var latestPull: Date?
var rememberOfferPoolFor: Double = 5


func updateUserIdOfferPool(offer: Offer) {
    
    let userRef = Database.database().reference().child("OfferPool").child(offer.ownerUserID).child(offer.offer_ID)
    
    var acceptedList = offer.accepted ?? [String]()
    acceptedList.append(Yourself.id)
    
    userRef.updateChildValues(["accepted": acceptedList])
    
}

func updateReservedOfferStatus(offer: Offer) {
    
    let offerRef = Database.database().reference().child("OfferPool").child(offer.companyDetails!.userId!).child(offer.offer_ID).child("reservedUsers")
    let reserve = offer.reservedUsers![Yourself.id]
    let date = reserve!["isReservedUntil"] as AnyObject
    let cash = reserve!["cashPower"] as AnyObject
    offerRef.updateChildValues([Yourself.id : ["isReserved":true,"isReservedUntil": date, "cashPower":cash]])
    
    let updateReserveOffer = Database.database().reference().child("ReservedOffers").child(offer.companyDetails!.userId!).child(Yourself.id).child(offer.offer_ID)
    updateReserveOffer.updateChildValues(["offerId":offer.offer_ID])
    
}

func updateCashPower(cash: Double, offer: Offer) {
    
    let updateCashPower = Database.database().reference().child("OfferPool").child(offer.companyDetails!.userId!).child(offer.offer_ID)
    updateCashPower.updateChildValues(["cashPower":cash])
    
}

func removeReservedOfferStatus(offer: Offer) {
    
    let offerRef = Database.database().reference().child("OfferPool").child(offer.companyDetails!.userId!).child(offer.offer_ID).child("reservedUsers").child(Yourself.id)
    
    offerRef.removeValue()
    
    let updateReserveOffer = Database.database().reference().child("ReservedOffers").child(offer.companyDetails!.userId!).child(Yourself.id).child(offer.offer_ID)
    updateReserveOffer.removeValue()
    
}

func GetOfferPool(completion: @escaping (_ offerList: [Offer])-> Void) {
    if let latest = latestPull {
        if latest.timeIntervalSinceNow > -(rememberOfferPoolFor - 0.1) {
            completion(currentOfferPool)
            return
        }
    }
    let ref = Database.database().reference().child("OfferPool")
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        if let totalDict = snapshot.value as? [String:[String: AnyObject]] {
            var offerList = [Offer]()
            for (_,value) in totalDict {
                for (_, OfferValue) in value {
                    do {
                        let offerData = try Offer.init(dictionary: OfferValue as! [String : AnyObject])
						if offerData.companyDetails!.isForTesting == false || API.isForTesting {
							offerList.append(offerData)
						}
                    } catch let error {
                        print(error)
                    }
                    
                }
            }
            offerList.sort { (offer1, offer2) -> Bool in
                if offer1.isDefaultOffer == offer2.isDefaultOffer {
                    return offer1.offerdate > offer2.offerdate
                } else {
                    return offer1.isDefaultOffer
                }
            }
            currentOfferPool = offerList
            latestPull = Date()
            completion(offerList)
        }
    }) { (error) in
    }
}

func getObserveAllOffer(completion: @escaping (_ status: Bool, _ offerList: [Offer])-> Void) {
    GetOfferPool { (offers) in
        let offerlist = offers.filter {
            if API.isForTesting == true{
                return $0.notAccepted && $0.isFiltered && $0.enoughCashForInfluencer && $0.isForTesting
            }else{
                return $0.notAccepted && $0.isFiltered && $0.enoughCashForInfluencer && !$0.isForTesting
            }
            
        }
        completion(true, offerlist)
    }
}

func getObserveFilteredOffer(completion: @escaping (_ status: Bool, _ offerList: [Offer])-> Void) {
    GetOfferPool { (offers) in
        let offerlist = offers.filter{
            
            if API.isForTesting == true{
                return $0.notAccepted && $0.enoughCashForInfluencer && $0.isFiltered && $0.isForTesting
            }else{
                return $0.notAccepted && $0.enoughCashForInfluencer && $0.isFiltered && !$0.isForTesting
            }
        }
        completion(true, offerlist)
    }
}

func getObserveFollowerCompaniesOffer(completion: @escaping (_ status: Bool, _ offerList: [Offer])-> Void) {
    
    GetOfferPool { (offers) in
        let offerlist = offers.filter{
            
            if API.isForTesting == true{
                return $0.notAccepted && ((Yourself.businessFollowing ?? []).contains($0.businessAccountID)) && $0.enoughCashForInfluencer && $0.isForTesting
            }else{
                return $0.notAccepted && ((Yourself.businessFollowing ?? []).contains($0.businessAccountID)) && $0.enoughCashForInfluencer && !$0.isForTesting
            }
            
            
        }
        completion(true, offerlist)
    }
    
}


func getOfferByBusiness(userId: String, completion:@escaping(_ status: Bool,_ returnoffers: [Offer])->()) {
    GetOfferPool { (offers) in
        let offerlist = offers.filter{
            if API.isForTesting == true{
                return $0.notAccepted && ($0.businessAccountID == userId) && $0.enoughCashForInfluencer && $0.isForTesting
            }else{
                return $0.notAccepted && ($0.businessAccountID == userId) && $0.enoughCashForInfluencer && !$0.isForTesting
            }
        }
        completion(true, offerlist)
    }
}
