//
//  offer.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 18/01/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

//Gets all offers relavent to the user via Firebase
func GetOffers(userId: String) -> [Offer] {
    let ref = Database.database().reference().child("offers")
    let offersRef = ref.child(userId)
    var offers: [Offer] = []
    offersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            for (_, offer) in dictionary{
                let offerDictionary = offer as? NSDictionary
                do {
                    let offerInstance = try Offer(dictionary: offerDictionary! as! [String : AnyObject])
                    offers.append(offerInstance)
                } catch let error {
                    print(error)
                }
                
            }
        }
    }, withCancel: nil)
    return offers
}

//Creates the offer and returns the newly created offer as an Offer instance
func CreateOffer() -> Offer {
    let ref = Database.database().reference().child("offers")
    let offerRef = ref.childByAutoId()
    let values: [String: AnyObject] = [:]
    offerRef.updateChildValues(values)
    
    var offerInstance = try! Offer(dictionary: [:])
    offerRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            do {
                offerInstance = try Offer(dictionary: dictionary)
            } catch let error {
                print(error)
            }
        }
    }, withCancel: nil)
    return offerInstance
    
    
}

func getOfferList(completion:@escaping (_ result: [Offer])->()) {
    var offers : [Offer] = []
    let ref = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id)
    ref.observeSingleEvent(of: .value, with: {(snapshot) in
        //print(snapshot.childrenCount)
        if let dictionary = snapshot.value as? [String: AnyObject] {
            for (_, offer) in dictionary{
                var offerDictionary = offer as? [String: AnyObject]
                
                
                
                //post detail fetch data
                if let posts = offerDictionary!["posts"] as? NSMutableArray{
                    var postfinal : [Post] = []
                    
                    for postv in posts {
                        var post = postv as! [String:AnyObject]
//                        var productfinal : [Product] = []
                        
//                        if let products = post["products"] as? NSMutableArray{
//                            for productDic in products {
//                                let product = productDic as! [String:AnyObject]
//                                productfinal.append(Product.init(image: (product["image"] as! String), name: product["name"] as! String, price: product["price"] as! Double, buy_url: product["buy_url"] as! String, color: product["color"] as! String, product_ID: product["product_ID"] as! String))
//                            }
//                            post["products"] = productfinal as AnyObject
//                        }
                        
                        
                        do {
                            let postValue = try Post.init(dictionary: post)
                            postfinal.append(postValue)
                        } catch let error {
                            print(error)
                        }
                        
                    }
                    offerDictionary!["posts"] = postfinal as AnyObject
                    do {
                        let userInstance = try Offer(dictionary: offerDictionary!)
                        offers.append(userInstance)
                        DispatchQueue.main.async {
                            
                            completion(offers)
                        }
                    } catch let error {
                        print(error)
                    }
                    
                    
                }else{
                    
                }
                
            }
        }
    }, withCancel: nil)
    
}

// update sentoutOffer to FIR
func SentOutOffersUpdate(offer:Offer, post_ID:String, status: String) {
    
    let prntRef  = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(offer.offer_ID).child("posts")
    prntRef.observeSingleEvent(of: .value) { (dataSnapshot) in
        if let posts = dataSnapshot.value as? NSMutableArray{
            var final: [[String : Any]] = []
            for value in posts{
                var obj = value as! [String : Any]
                if obj["post_ID"] as! String == post_ID {
                    obj["isConfirmed"] = true as Bool
                    let currentDate = Date.getStringFromSecondDate(date: Date())!
                    obj["confirmedSince"] = currentDate
                    obj["confirmedSince"] = getStringFromTodayDate()
                    
                    final.append(obj)
                    
                }else{
                    final.append(obj)
                }
            }
            
            let update  = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(offer.offer_ID)
            var isConfirmAllPost = true
            for (index,_) in final.enumerated(){
                if let checkConfirm = final[index]["isConfirmed"] as? Bool {
                    if !checkConfirm{
                        isConfirmAllPost = false
                    }
                }
            }
            if isConfirmAllPost {
                update.updateChildValues(["posts": final,"status": status,"allConfirmed":true])
            }else{
                update.updateChildValues(["posts": final,"status": "accepted","allConfirmed":false])
            }
            
            if offer.offer_ID == "XXXDefault" {
                update.updateChildValues(["allConfirmed":true])
                update.updateChildValues(["allPostsConfirmedSince":getStringFromTodayDate()])
                let updateUserData  = Database.database().reference().child("users").child(Yourself.id)
                updateUserData.updateChildValues(["isDefaultOfferVerify":true])
                Yourself.isDefaultOfferVerify = true
                
            }
            
            
        }
    }
    
}


//Get influencer worked Companies
//func getInfluencerWorkedCompanies(influencer: User, completion: @escaping([Comapny]?,String,Error?)-> Void) {
//
//    let ref = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id)
//
//    var cmpObject = [Comapny]()
//
//    ref.observeSingleEvent(of: .value, with: { (snapshot) in
//
//        if let totalValues = snapshot.value as? NSDictionary{
//
//            let allOfferKeys = totalValues.allKeys
//
//            var companyPathArray = [String]()
//
//            for offerKey in allOfferKeys {
//
//                let offKey = offerKey as! String
//
//                if offKey != "XXXDefault"{
//
//                    let offerValues = totalValues[offKey] as! [String: AnyObject]
//
//                    if let statusValue = offerValues["status"] as? String {
//                        if statusValue == "accepted" {
//
//                            if let ownerCompany = offerValues["ownerUserID"] as? String {
//
//                                if let companyID = offerValues["company"] as? String {
//
//                                    let appendedCompanyPath = ownerCompany + "/" + companyID
//                                    companyPathArray.append(appendedCompanyPath)
//                                }
//
//                            }
//
//                        }
//                    }
//
//                }
//            }
//
//            if companyPathArray.count != 0 {
//                
//                let serialQueue = DispatchQueue.init(label: "serialQueue")
//
//                for (index,compayPath) in companyPathArray.enumerated() {
//
//                    let refCompany = Database.database().reference().child("companies").child(compayPath)
//
//                    serialQueue.async {
//
//                        refCompany.observeSingleEvent(of: .value) { (snap) in
//
//                            if let companyDetails = snap.value as? [String: AnyObject]{
//
//                                let cmyDetail = Comapny.init(dictionary: companyDetails)
//                                cmpObject.append(cmyDetail)
//
//                            }
//
//                            if index == companyPathArray.count - 1 {
//
//                                completion(cmpObject, "success", nil)
//
//                            }
//
//                        }
//
//                    }
//
//                }
//
//            }else{
//                completion(nil, "success", nil)
//            }
//
//        }
//
//    }) { (error) in
//
//        completion(nil, "failure", error)
//
//    }
//
//}

func createDefaultOffer(userID:String, completion:@escaping (_ isdone:Bool) -> ()) {
    //insertd Default offers
    let refDefaultOffer = Database.database().reference().child("SentOutOffersToUsers").child(userID)
    let postID = refDefaultOffer.childByAutoId().key
    let offerData = API.serializeDefaultOffer(offerID:"XXXDefault", postID: postID! ,userID:userID)
    
    
    /*
     READ : NOTE BY MARCO
     I have edited this section of code so that the getOfferList function will only be activated after the default offer as been created by putting the code in the Completion Block. This was probably the "button not working" error.
     */
    refDefaultOffer.updateChildValues(["XXXDefault":offerData], withCompletionBlock: { (error, databaseref) in
        var youroffers: [Offer] = []
        // ****
        //naveen added
        getOfferList { (Offers) in
            youroffers = Offers
            global.AvaliableOffers = youroffers.filter({$0.status == "available"})
            global.AvaliableOffers = GetSortedOffers(offer: global.AvaliableOffers)
            //Ambver update
            global.AcceptedOffers = youroffers.filter({$0.status == "accepted" || $0.status == "denied"})
            global.OffersHistory = youroffers.filter({$0.status == "paid"})
            global.AcceptedOffers = GetSortedOffers(offer: global.AcceptedOffers)
            global.RejectedOffers = youroffers.filter({$0.status == "rejected"})
            
            completion(true)
            
        }
    })
}

func updateIsAcceptedOffer(offer: Offer, money: Double) {
    
    let prntRef  = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(offer.offer_ID)
    print("userid: \(Yourself.id)\nOffer ID: \(offer.offer_ID)")
    //let prntRef  = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(ThisOffer.offer_ID)
    let dayCount = offer.posts.count * 2
    
    let payEachPost = (money/Double(offer.posts.count))
    
    //var expireDateString = Date.getStringFromDate(date: Date().afterDays(day: dayCount))!
    var expireDate = Date().afterDays(numberOfDays: dayCount)
    if offer.isDefaultOffer {
        let foreverDate = 365 * 1000
        //expireDateString = Date.getStringFromDate(date: Date().afterDays(day: foreverDate))!
        expireDate = Date().afterDays(numberOfDays: foreverDate)
        offer.allConfirmed = false
    }
    
    
    offer.expiredate = expireDate
    offer.isAccepted = true
    offer.status = "accepted"
    
    let curDateStr = Date.getStringFromDate(date: Date())
    if let currentDate = Date.getDateFromString(date: curDateStr!){
        offer.acceptedDate = currentDate
    }
    offer.money = money
    
    for(index,_) in offer.posts.enumerated() {
        offer.posts[index].status = "accepted"
        offer.posts[index].PayAmount = payEachPost
        
        if offer.isDefaultOffer {
            offer.posts[index].isConfirmed = false
        }
        
    }
    
    let offerDict = API.serializeOffer(offer: offer)
    
    //prntRef.updateChildValues(["expiredate":expireDate])
    //prntRef.updateChildValues(["isAccepted":true])
    prntRef.updateChildValues(offerDict)
    NotificationCenter.default.post(name: Notification.Name("updateinprogresscount"), object: nil, userInfo: ["userinfo":"1"])
    
}

func getAcceptedOffers(completion: @escaping(_ status: Bool,_ offer: [Offer])->()) {
    
    let userRef = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id)
    
    userRef.observe(.value) { (snapshot) in
        
        if let snapDict = snapshot.value as? [String: [String: AnyObject]] {
            
            var offerList = [Offer]()
            
            for (_, offervalue) in snapDict {
                
                do {
                    let offer = try Offer.init(dictionary: offervalue)
                    
                    if API.isForTesting{
                        
                        if offer.isForTesting == true{
                            offerList.append(offer)
                        }
                        
                    }else{
                        
                        if offer.isForTesting == false{
                            offerList.append(offer)
                        }
                        
                    }
                } catch let error {
                    print(error)
                }
                
            }
            
            offerList.sort { (offer1, offer2) -> Bool in
                
                let o1 = CheckIfOferIsActive(offer: offer1)
                let o2 = CheckIfOferIsActive(offer: offer2)
                
                if o1 == o2 {
                    if offer1.acceptedDate ?? Date() != offer1.acceptedDate ?? Date() {
                        return offer1.acceptedDate ?? Date() > offer1.acceptedDate ?? Date()
                    } else {
                        return offer1.offerdate > offer2.offerdate
                    }
                } else {
                    return o1
                }
                
            }
            
            completion(true, offerList)
            
        } else {
            completion(true, [])
            
        }
        
    }
}

func getAcceptedSimplexOffer(offer: Offer,completion: @escaping(_ status: Bool, _ offer: Offer)->()) {
    
    let offerRef = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(offer.offer_ID)
    
    offerRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let snapOffer = snapshot.value as? [String: AnyObject]{
            
            do {
                let offer = try Offer.init(dictionary: snapOffer)
                completion(true,offer)
            } catch let error {
                print(error)
            }
            
        }
        
    }) { (error) in
        
    }
    
}
