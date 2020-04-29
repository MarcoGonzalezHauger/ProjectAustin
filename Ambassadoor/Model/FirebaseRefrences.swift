//
//  FirebaseRefrences.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/21/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
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
                let offerInstance = Offer(dictionary: offerDictionary! as! [String : AnyObject])
                offers.append(offerInstance)
            }
        }
    }, withCancel: nil)
    return offers
}

//Creates the offer and returns the newly created offer as an Offer instance
func CreateOffer() -> Offer {
    let ref = Database.database().reference().child("offers")
    let offerRef = ref.childByAutoId()
    /*
    let values = [
        "money": 0
        "company": Company,
        "posts": [Post],
        "offerdate": Date,
        "offer_ID": String,
        "expiredate": Date,
        "allPostsConfrimedSince": Date?,
        "allConfirmed": Bool,
        "areConfirmed": Bool,
        "isAccepted": Bool,
        "isExpired": Bool,
        ] as [String : Any]
 */
    let values: [String: AnyObject] = [:]
    offerRef.updateChildValues(values)
    var offerInstance = Offer(dictionary: [:])
    offerRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            offerInstance = Offer(dictionary: dictionary)
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
                                       var productfinal : [Product] = []
                                       
                                       if let products = post["products"] as? NSMutableArray{
                                           for productDic in products {
                                               let product = productDic as! [String:AnyObject]
                                               productfinal.append(Product.init(image: (product["image"] as! String), name: product["name"] as! String, price: product["price"] as! Double, buy_url: product["buy_url"] as! String, color: product["color"] as! String, product_ID: product["product_ID"] as! String))
                                           }
                                           post["products"] = productfinal as AnyObject
                                       }
                                    
                                    /*
                                     Post.init(image: post["image"] as? String, instructions: post["instructions"] as! String, captionMustInclude: "", products: post["products"] as? [Product], post_ID: post["post_ID"] as! String, PostType: post["PostType"] as! String, confirmedSince: post["confirmedSince"] as? Date, isConfirmed: post["isConfirmed"] as! Bool, hashCaption: post["hashCaption"] as? String ?? "", status: post["status"] as? String ?? "", hashtags: post["hashtags"] as? [String] ?? [], keywords: post["keywords"] as? [String] ?? [], isPaid: post["isPaid"] as? Bool, PayAmount: post["isPaid"] as? Double ?? 0.0, denyMessage: post["denyMessage"] as? String ?? "")
                                     */
                                     /*
                                       
                                    postfinal.append(Post.init(image: post["image"] as? String, instructions: post["instructions"] as! String, products: post["products"] as? [Product] , post_ID: post["post_ID"] as! String, PostType: TextToPostType(posttype: post["PostType"] as! String), confirmedSince: post["confirmedSince"] as? Date, isConfirmed: post["isConfirmed"] as! Bool,denyMessage: post["denyMessage"] as? String ?? "",status: post["status"] as? String ?? "",hashtags: post["hashtags"] as? [String] ?? [], keywords: post["keywords"] as? [String] ?? []))
                                    */
                                    
                                    postfinal.append(Post.init(image: post["image"] as? String, instructions: post["instructions"] as! String, captionMustInclude: "", products: post["products"] as? [Product], post_ID: post["post_ID"] as! String, PostType: post["PostType"] as! String, confirmedSince: post["confirmedSince"] as? Date, isConfirmed: post["isConfirmed"] as! Bool, hashCaption: post["hashCaption"] as? String ?? "", status: post["status"] as? String ?? "", hashtags: post["hashtags"] as? [String] ?? [], keywords: post["keywords"] as? [String] ?? [], isPaid: post["isPaid"] as? Bool, PayAmount: post["isPaid"] as? Double ?? 0.0, denyMessage: post["denyMessage"] as? String ?? ""))
                                       
                                   }
                                   offerDictionary!["posts"] = postfinal as AnyObject
                                   let userInstance = Offer(dictionary: offerDictionary!)
                                   offers.append(userInstance)
                                   DispatchQueue.main.async {

                                   completion(offers)
                                   }
                                   
                               }else{
                                   
                               }
                
                
                
                
                
//                print("company=\(offerDictionary!["company"] as! String)")
                //company detail fetch data
//                let compref = Database.database().reference().child("companies").child(offerDictionary!["ownerUserID"] as! String).child(offerDictionary!["company"] as! String)
//                compref.observeSingleEvent(of: .value, with: { (dataSnapshot) in
//                    if let company = dataSnapshot.value as? [String: AnyObject] {
//                        let companyDetail = Company.init(name: company["name"] as! String, logo:
//                            company["logo"] as? String, mission: company["mission"] as! String, website: company["website"] as! String, account_ID: company["account_ID"] as! String, instagram_name: company["name"] as! String, description: company["description"] as! String)
//
//                        offerDictionary!["company"] = companyDetail as AnyObject
//
//                        //post detail fetch data
//                        if let posts = offerDictionary!["posts"] as? NSMutableArray{
//                            var postfinal : [Post] = []
//
//                            for postv in posts {
//                                var post = postv as! [String:AnyObject]
//                                var productfinal : [Product] = []
//
//                                if let products = post["products"] as? NSMutableArray{
//                                    for productDic in products {
//                                        let product = productDic as! [String:AnyObject]
//                                        productfinal.append(Product.init(image: (product["image"] as! String), name: product["name"] as! String, price: product["price"] as! Double, buy_url: product["buy_url"] as! String, color: product["color"] as! String, product_ID: product["product_ID"] as! String))
//                                    }
//                                    post["products"] = productfinal as AnyObject
//                                }
//
//                                postfinal.append(Post.init(image: post["image"] as? String, instructions: post["instructions"] as! String, captionMustInclude: post["captionMustInclude"] as? String, products: post["products"] as? [Product] , post_ID: post["post_ID"] as! String, PostType: TextToPostType(posttype: post["PostType"] as! String), confirmedSince: post["confirmedSince"] as? Date, isConfirmed: post["isConfirmed"] as! Bool,denyMessage: post["denyMessage"] as? String ?? "",status: post["status"] as? String ?? "",keywords: post["keywords"] as? [String] ?? []))
//
//                            }
//                            offerDictionary!["posts"] = postfinal as AnyObject
//                            let userInstance = Offer(dictionary: offerDictionary!)
//                            offers.append(userInstance)
//                            DispatchQueue.main.async {
//
//                            completion(offers)
//                            }
//
//                        }else{
//
//                        }
//
//                    }else{
//
//                    }
//
//                }, withCancel: nil)
                
            }
        }
    }, withCancel: nil)
    
}

//naveen added func
func CreateAccount(instagramUser: User, completion:@escaping (_ Results: User , _ bool:Bool) -> ()) {
    // Pointer reference in Firebase to Users
    let ref = Database.database().reference().child("users")
    // Boolean flag to keep track if user is already in database
    var alreadyRegistered: Bool = false
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        //print(snapshot.childrenCount)
        for case let user as DataSnapshot in snapshot.children {
            if (user.childSnapshot(forPath: "username").value as? String == instagramUser.username) {
                alreadyRegistered = true
                if let dictionary = user.value as? [String: AnyObject] {
                    instagramUser.gender = TextToGender(gender: dictionary["gender"] as! String)
                    instagramUser.zipCode = dictionary["zipCode"] as? String
                    instagramUser.isBankAdded = dictionary["isBankAdded"] as! Bool
                    instagramUser.yourMoney = dictionary["yourMoney"] as! Double

                    if let joined = dictionary["joinedDate"] as? String {
                        instagramUser.joinedDate = joined
                    }else{
                        instagramUser.joinedDate = Date.getCurrentDate()
                    }
                    
                    if  let categories = dictionary["categories"] as? [String] {
                        instagramUser.categories = categories
                    }else{
                        instagramUser.categories = []
                    }
                    
                    if let referralcode = dictionary["referralcode"] as? String{
                        instagramUser.referralcode = referralcode
                    }else{
                        var referralcodeString = ""
                        //random four digit code
                        referralcodeString.append(randomString(length: 4))
                        
                        instagramUser.referralcode = referralcodeString.uppercased()
                        
                    }
                    
                    
                    if let isDefaultOfferVerify = dictionary["isDefaultOfferVerify"] as? Bool{
                        instagramUser.isDefaultOfferVerify = isDefaultOfferVerify
                    }else{
                        instagramUser.isDefaultOfferVerify = false
                    }
                    
                    if let lastPaidOSCDate = dictionary["lastPaidOSCDate"] as? String{
                        instagramUser.lastPaidOSCDate = lastPaidOSCDate
                    }else{
                        instagramUser.lastPaidOSCDate = Date.getCurrentDate()
                    }
                    
                    if let priorityValue = dictionary["priorityValue"] as? Int{
                        instagramUser.priorityValue = priorityValue
                    }else{
                        instagramUser.priorityValue = 0
                    }
                    
                    if let authenticationToken = dictionary["authenticationToken"] as? String{
                        if authenticationToken != "" {
                            instagramUser.authenticationToken = authenticationToken
                        }else{
                            instagramUser.authenticationToken = API.INSTAGRAM_ACCESS_TOKEN
                        }
                    }else{
                        instagramUser.authenticationToken = API.INSTAGRAM_ACCESS_TOKEN
                    }
                    
                }

            }
        }
        
        if alreadyRegistered {
            let userReference = ref.child(instagramUser.id)
            let userData = API.serializeUser(user: instagramUser, id: instagramUser.id)
            userReference.updateChildValues(userData)
            completion(instagramUser,true)
        } else {
            completion(instagramUser,false)
        }
    })

}

// Query all users in Firebase and to do filtering based on algorithm
//func GetAllUsers() -> [User] {
//    let usersRef = Database.database().reference().child("users")
//    var users: [User] = []
//    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
//        if let dictionary = snapshot.value as? [String: AnyObject] {
//            for (_, user) in dictionary{
//                let userDictionary = user as? NSDictionary
//                let userInstance = User(dictionary: userDictionary! as! [String : AnyObject])
//                users.append(userInstance)
//                global.SocialData.append(userInstance)
//            }
//        }
//    }, withCancel: nil)
//    return users
//}

//naveen added func
func GetAllUsers(completion:@escaping (_ result: [User])->())  {
    let usersRef = Database.database().reference().child("users")
    var users: [User] = []
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            for (_, user) in dictionary{
                let userDictionary = user as? NSDictionary
                let userInstance = User(dictionary: userDictionary! as! [String : AnyObject])
                users.append(userInstance)
            }
            completion(users)
        }
    }, withCancel: nil)
}

func GetAllBusiness(completion:@escaping (_ result: [CompanyDetails])->()) {
    let usersRef = Database.database().reference().child("companies")
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let snapDict = snapshot.value as? [String: [String: AnyObject]]{
            
            var companyList = [CompanyDetails]()
            
            for(key,value) in snapDict{
                for (_, companyValue) in value {
                    
                    let companyDetails = CompanyDetails.init(dictionary: companyValue as! [String : AnyObject])
                    companyDetails.userId = key
                    
                    companyList.append(companyDetails)
                    
                }
            }
            
            completion(companyList)
        }
        
    }) { (error) in
        
    }
    
}

//Added by ram

func getDwollaFundingSource(completion: @escaping([DwollaCustomerFSList]?,String,Error?) -> Void) {
    
    let ref = Database.database().reference().child("DwollaCustomers").child(Yourself.id)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let totalValues = snapshot.value as? NSDictionary{
            
            var objects = [DwollaCustomerFSList]()
            
            for value in totalValues.allKeys {
                
                let fundSource = DwollaCustomerFSList.init(dictionary: totalValues[value] as! [String: Any])
                objects.append(fundSource)
                
            }
            completion(objects, "success", nil)
        }
        
        
    }) { (error) in
        completion(nil, "success", error)
    }
    
}

func fundTransferAccount(transferURL: String,accountID: String,Obj: DwollaCustomerFSList, currency: String, amount: String, date:String) {
    
    let ref = Database.database().reference().child("FundTransfer").child(Yourself.id).child(accountID)
    let fundTransfer: [String: Any] = ["accountID":accountID,"transferURL":transferURL,"currency":currency,"amount":amount,"name":Obj.name,"mask":Obj.mask,"customerURL":Obj.customerURL,"FS":Obj.customerFSURL,"firstname":Obj.firstName,"lastname":Obj.lastName,"date":date]
    ref.updateChildValues(fundTransfer)

    
}

func withdrawUpdate(amount: Double, fee: Double,from: String,to: String, id: String, status: String, type:String, date:String) {
    
    let ref = Database.database().reference().child("InfluencerTransactions").child(Yourself.id)
    ref.observeSingleEvent(of: .value) { (snapshot) in
        if var transaction = snapshot.value as? [[String:Any]] {
            
            let fundTransfer: [String: Any] = ["Amount":amount,"fee":fee,"from":from,"To":to,"id":id,"status":status,"type":type,"createdAt":date]
            transaction.append(fundTransfer)
            
            let updateref = Database.database().reference().child("InfluencerTransactions")
            let finalTrans = [Yourself.id:transaction] as [String:Any]
            updateref.updateChildValues(finalTrans)
        }else{
            
        }
        
    }
    
    
}

// added instagram post to FIR. after verified the offer post and instagram post
func instagramPostUpdate(offerID:String, post:[String:Any]) {
    
    let ref = Database.database().reference().child("InfluencerInstagramPost").child(Yourself.id).child(offerID)
    ref.updateChildValues(post)

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

func transactionInfo(completion: @escaping([TransactionInfo]?,String,Error?) -> Void) {
    
    let ref = Database.database().reference().child("FundTransfer").child(Yourself.id)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let totalValues = snapshot.value as? NSDictionary{
            
            var objects = [TransactionInfo]()
            
            for value in totalValues.allKeys {
                
                let transactionInfo = TransactionInfo.init(dictionary: totalValues[value] as! [String: Any])
                objects.append(transactionInfo)
                
            }
            completion(objects, "success", nil)
        }
        
        
    }) { (error) in
        completion(nil, "success", error)
    }
    
}

//stripe
func createStripeAccToFIR(AccDetail:[String:Any] ) {
        let ref = Database.database().reference().child("InfluencerStripeAccount").child(Yourself.id).child("AccountDetail")
        ref.updateChildValues(AccDetail)
    
    let prntRef  = Database.database().reference().child("users").child(Yourself.id)
    prntRef.updateChildValues(["isBankAdded":true])
    Yourself.isBankAdded = true
}

//Get influencer worked Companies

func getInfluencerWorkedCompanies(influencer: User, completion: @escaping([Comapny]?,String,Error?)-> Void) {
    
    let ref = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id)
    
    var cmpObject = [Comapny]()
    
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let totalValues = snapshot.value as? NSDictionary{
            
            let allOfferKeys = totalValues.allKeys
            
            var companyPathArray = [String]()
            
            for offerKey in allOfferKeys {
                
                let offKey = offerKey as! String
                
                if offKey != "XXXDefault"{
                    
                    let offerValues = totalValues[offKey] as! [String: AnyObject]
                    
                    if let statusValue = offerValues["status"] as? String {
                        if statusValue == "accepted" {
                            
                            if let ownerCompany = offerValues["ownerUserID"] as? String {
                                
                                if let companyID = offerValues["company"] as? String {
                                    
                                    let appendedCompanyPath = ownerCompany + "/" + companyID
                                    companyPathArray.append(appendedCompanyPath)
                                }
                                
                            }
                            
                        }
                    }
                    
                }
            }
            
            if companyPathArray.count != 0 {
                
                let serialQueue = DispatchQueue.init(label: "serialQueue")
                
                for (index,compayPath) in companyPathArray.enumerated() {
                    
                    let refCompany = Database.database().reference().child("companies").child(compayPath)
                    
                    serialQueue.async {
                    
                    refCompany.observeSingleEvent(of: .value) { (snap) in
                        
                        if let companyDetails = snap.value as? [String: AnyObject]{
                            
                            let cmyDetail = Comapny.init(dictionary: companyDetails)
                            cmpObject.append(cmyDetail)
                            
                        }
                        
                        if index == companyPathArray.count - 1 {
                            
                            completion(cmpObject, "success", nil)
                            
                        }
                        
                    }
                    
                }
                    
                }
                
            }else{
                completion(nil, "success", nil)
            }
            
        }
        
    }) { (error) in
        
        completion(nil, "failure", error)
        
    }
        
}

func getStripeAccDetails(completion: @escaping([StripeAccDetail]?,String,Error?) -> Void) {
    
    let ref = Database.database().reference().child("InfluencerStripeAccount").child(Yourself.id).child("AccountDetail")
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let totalValues = snapshot.value as? NSDictionary{
            
            var objects = [StripeAccDetail]()
            let accDetail = StripeAccDetail.init(dictionary: totalValues as! [String: Any])
            objects.append(accDetail)
            
            completion(objects, "success", nil)
        }
        
        
    }) { (error) in
        completion(nil, "success", error)
    }
    
}

func getTransactionHistory(completion: @escaping([TransactionHistory]?,String,Error?) -> Void) {
    
    let ref = Database.database().reference().child("InfluencerTransactions").child(Yourself.id)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let totalValues = snapshot.value as? [[String:Any]]{
            
            var objects = [TransactionHistory]()
            for transaction in totalValues {
                let accDetail = TransactionHistory.init(dictionary: transaction )
                objects.append(accDetail)
            }
            
            
            completion(objects, "success", nil)
        }
        
        
    }) { (error) in
        completion(nil, "success", error)
    }
    
}

//Update UserData to firebase
func updateUserDataToFIR(user: User, completion:@escaping (_ Results: User) -> ()) {
    
        var referralCode = ""
    
        let ref = Database.database().reference().child("InfluencerReferralCodes")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.childrenCount)

			if let referralCodeList = snapshot.value as? [String] {
				
				print("referral code list loaded.")
                
                var final = referralCodeList
                referralCode = randomString(length: 6).uppercased()
                while final.contains(referralCode) {
                    referralCode = randomString(length: 6).uppercased()
                }
                
                user.referralcode = referralCode
				
				print("Referral Code Set.")

                let userReference = Database.database().reference().child("users").child(user.id)
                let userData = API.serializeUser(user: user, id: user.id)
				print("User Data Serialized")
                userReference.updateChildValues(userData)
				print("User Data Uploaded")
                
                final.append(referralCode)
                //update referral code
                let refCode = Database.database().reference()
                refCode.updateChildValues(["InfluencerReferralCodes":final])
				print("Updated list of taken referral codes.")
                
                completion(user)
			} else {
				print("Referral Code List could not be converted into [String]")
			}


        })
}

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
                //                print(Offers.count)
                youroffers = Offers
                //                                global.AvaliableOffers = youroffers.filter({$0.isAccepted == false})
                //                                global.AcceptedOffers = youroffers.filter({$0.isAccepted == true})
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

func checkIfEmailExist(email: String, completion: @escaping(_ exist: Bool)-> Void) {
    var isExist = false
    //let ref = Database.database().reference().child("InfluencerAuthentication")
    let ref = Database.database().reference().child("InfluencerAuthentication")
    let query = ref.queryOrdered(byChild: "email").queryEqual(toValue: email)
    query.observeSingleEvent(of: .value, with: { (snapshot) in
        
        //if let _ = snapshot.value as? [String: AnyObject] {
        if snapshot.exists() {
            isExist = true
            completion(isExist)
            
//            if snapValue.count == 0 {
//
//                completion(isExist)
//
//            }else{
//
//                for (_,object) in snapValue {
//                    if let checkValue = object as? [String: AnyObject] {
//
//                        if let emailString = checkValue["email"] as? String {
//
//                            if emailString == email {
//                                isExist = true
//                            }
//
//                        }
//
//                    }
//                }
//                completion(isExist)
//
//            }
            
        }else{
            completion(isExist)
        }
        
    }) { (error) in
        completion(isExist)
    }
}

func checkIfUserExists(userID: String,completion: @escaping(_ exist: Bool, _ user: User?)-> Void) {
    //var isAlreadyRegistered: Bool = false
    let ref = Database.database().reference().child("users").child(userID)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        //if let _ = snapshot.value as? [String: AnyObject]{
        if snapshot.exists(){
            completion(true, nil)
            
        }else{
            createNewInfluencerAuthentication(info: NewAccount)
            let userData = API.serializeRawUserData(details: NewAccount)
            ref.updateChildValues(userData)
            let userRef = User.init(dictionary: userData)
            completion(false, userRef)
        }
        
    }) { (error) in
         createNewInfluencerAuthentication(info: NewAccount)
         let userData = API.serializeRawUserData(details: NewAccount)
         ref.updateChildValues(userData)
        let userRef = User.init(dictionary: userData)
        completion(false, userRef)
    }
}

func updateUserDetails(userID: String, userData:[String: Any]){
    
    let ref = Database.database().reference().child("users").child(userID)
     ref.updateChildValues(userData)
}

func updateUserIdOfferPool(offer: Offer) {
    
    let userRef = Database.database().reference().child("OfferPool").child(offer.ownerUserID).child(offer.offer_ID)
    
    var acceptedList = offer.accepted ?? [String]()
    acceptedList.append(Yourself.id)
    
   userRef.updateChildValues(["accepted": acceptedList])
    
}

func updateIsAcceptedOffer(offer: Offer) {
    
    let prntRef  = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id)
    //let prntRef  = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(ThisOffer.offer_ID)
    let dayCount = offer.posts.count * 2
    //var expireDateString = Date.getStringFromDate(date: Date().afterDays(day: dayCount))!
    var expireDate = Date().afterDays(day: dayCount)
    if offer.offer_ID == "XXXDefault" {
        let foreverDate = 365 * 1000
        //expireDateString = Date.getStringFromDate(date: Date().afterDays(day: foreverDate))!
        expireDate = Date().afterDays(day: foreverDate)
    }
    
    
    offer.expiredate = expireDate
    offer.isAccepted = true
    offer.status = "accepted"
    offer.updatedDate = Date()
    
    for(index,_) in offer.posts.enumerated() {
        offer.posts[index].status = "accepted"
    }
    
    let offerDict = API.serializeOffer(offer: offer)
    
    //prntRef.updateChildValues(["expiredate":expireDate])
    //prntRef.updateChildValues(["isAccepted":true])
    prntRef.updateChildValues([offer.offer_ID : offerDict])
    NotificationCenter.default.post(name: Notification.Name("updateinprogresscount"), object: nil, userInfo: ["userinfo":"1"])
    
}

func createNewInfluencerAuthentication(info: NewAccountInfo) {
    // Create New Influencer In InfluencerAuthentication Table
    let ref = Database.database().reference().child("InfluencerAuthentication").child(info.id)
    let serializedInfo = API.serializeInfluencerAuthentication(details: info)
    ref.updateChildValues(serializedInfo)
    
    // Create New User In users table
}

func filterQueryByField(email: String, completion:@escaping(_ exist: Bool, _ userData: [String: AnyObject]?)->Void){
    
    let ref = Database.database().reference().child("InfluencerAuthentication")
    let query = ref.queryOrdered(byChild: "email").queryEqual(toValue: email)
    query.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let snapValue = snapshot.value as? [String: AnyObject]{
            
            completion(true, snapValue)
        }else{
            completion(false, nil)
        }
        
    }) { (error) in
        
    }
    
}

func fetchSingleUserDetails(userID: String, completion: @escaping(_ status: Bool, _ user: User)->Void) {
    let usersRef = Database.database().reference().child("users").child(userID)
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            let userInstance = User(dictionary: dictionary )
            //Yourself = userInstance
            completion(true,userInstance)
//            print("Appdelegate gender = \(Yourself.gender)")

        }
    }, withCancel: nil)
}

func updateFollowingList(userID: String, ownUserID: User) {
    let usersRef = Database.database().reference().child("users").child(ownUserID.id)
    usersRef.updateChildValues(["following":ownUserID.following!])
}

func updateBusinessFollowingList(company: CompanyDetails,userID: String, ownUserID: User) {
    let usersRef = Database.database().reference().child("users").child(ownUserID.id)
    usersRef.updateChildValues(["businessFollowing":ownUserID.businessFollowing!])
    
    let businessRef = Database.database().reference().child("companies").child(userID).child(company.account_ID!)
    var followers = company.followers
    followers?.append(ownUserID.id)
    businessRef.updateChildValues(["followers":followers!])
}

func updateFollowingFollowerUser(user: User, identifier: String) {
    
    // update Following & Follower
    
    let userFollowingRef = Database.database().reference().child("Following").child(Yourself.id)
    let userDetails = API.serializeUser(user: user, id: user.id)
    userFollowingRef.updateChildValues([user.id: ["identifier": identifier,"user":userDetails,"startedAt": Date().toString(dateFormat: "MMM dd YYYY")] ])
    
    let userFollowerRef = Database.database().reference().child("Follower").child(user.id)
    let followerDetails = API.serializeUser(user: user, id: user.id)
    userFollowerRef.updateChildValues([Yourself.id: ["identifier": "influencer","user":followerDetails, "startedAt": Date().toString(dateFormat: "MMM dd YYYY")]])
}

func removeFollowingFollowerUser(user: User) {
    
    // Remove Following & Follower
    
    let userFollowingRef = Database.database().reference().child("Following").child(Yourself.id).child(user.id)
    userFollowingRef.removeValue()
    
    let userFollowerRef = Database.database().reference().child("Follower").child(user.id).child(Yourself.id)
    userFollowerRef.removeValue()
    
}

func updateFollowingFollowerBusinessUser(user: CompanyDetails, identifier: String) {

    let userFollowingRef = Database.database().reference().child("Following").child(Yourself.id)
    let userDetails = API.serializeCompanyDetails(company: user)
    userFollowingRef.updateChildValues([user.userId!: ["identifier": identifier,"user":userDetails,"startedAt": Date().toString(dateFormat: "MMM dd YYYY")] ])
}

func removeFollowingFollowerBusinessUser(user: CompanyDetails) {
    
    // Remove Following & Follower
    
    let userFollowingRef = Database.database().reference().child("Following").child(Yourself.id).child(user.userId!)
    userFollowingRef.removeValue()
    
}

func getFilteredUsers(userIDs: [String], completion: @escaping(_ status: Bool, _ users: [User]?, _ deveiceTokens: [String]?)-> Void) {
    
    let usersRef = Database.database().reference().child("users")
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let dictValue = snapshot.value as? [String: AnyObject] {
            
            let filteredData = dictValue.filter { (value) -> Bool in
                return userIDs.contains(value.key)
            }
            
            var usersList = [User]()
            var tokens = [String]()
            
            for (_,value) in filteredData {
                
                if let valueDict = value as? [String: Any] {
                    
                    let user = User.init(dictionary: valueDict)
                    usersList.append(user)
                    if let token = valueDict["tokenFIR"] as? String {
                    tokens.append(token)
                    }
                    
                }
                
            }
            completion(true,usersList,tokens)
        }
        
    }) { (error) in
        completion(false,nil, nil)
    }
    
}

func getCompanyDetails(id: String, completion: @escaping (_ status: Bool,_ companyDeatails: Company?)->Void) {
    
    let usersRef = Database.database().reference().child("companies").child(id)
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let dict = snapshot.value as? [String: [String: Any]] {
            
            if let dictValue = dict.values.first {
                
                let company = Company.init(name: dictValue["name"] as! String, logo: "", mission: "", website: "", account_ID: "", instagram_name: "", description: "")
                
                completion(true, company)
                
            }else{
                completion(false, nil)
            }
            
            
            
        }
        
    }) { (error) in
        
        completion(false, nil)
        
    }
    
}

func fetchBusinessUserDetails(userID: String, completion: @escaping(_ status: Bool, _ deviceFIR: String?)->Void) {
    let usersRef = Database.database().reference().child("CompanyUser").child(userID)
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            if let deviceToken = dictionary["deviceFIRToken"] as? String {
               completion(true,deviceToken)
            }else{
               completion(false,nil)
            }
            //Yourself = userInstance
            
//            print("Appdelegate gender = \(Yourself.gender)")

        }
    }, withCancel: nil)
}

func updatePassword(userID: String,password: String){
    
    let ref = Database.database().reference().child("InfluencerAuthentication").child(userID)
    ref.updateChildValues(["password":password])
    
}

func getFilteredOffer(completion: @escaping (_ status: Bool, _ offerList: [allOfferObject]?)-> Void) {
    let ref = Database.database().reference().child("OfferPool")
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let totalDict = snapshot.value as? [String:[String: AnyObject]] {
            
            var offerList = [allOfferObject]()
            
            for (key,value) in totalDict {
                
                for (offerKey, OfferValue) in value {
                    
                    let offerFilter = OfferValue["influencerFilter"] as! [String: AnyObject]
                    
                    let offerFilterKeys = offerFilter.keys
                    
                    var categoryMatch = !offerFilterKeys.contains("categories")
                    var genderMatch = !offerFilterKeys.contains("gender")
                    var locationMatch = !offerFilterKeys.contains("zipCode")
                    
                    if !genderMatch {
                        let gender: [String] = offerFilter["gender"] as! [String]
                        if let userGender = Yourself.gender!.rawValue as? String {
                            if gender.contains(userGender) {
                                genderMatch = true
                            }
                        }
                    }
                    
                    if !locationMatch && genderMatch {
                        let zips: [String] = offerFilter["zipCode"] as! [String]
                        if let userZip = Yourself.zipCode as? String {
                            if zips.contains(userZip) {
                                locationMatch = true
                            }
                        }
                    }
                    
                    if !categoryMatch && locationMatch && genderMatch {
                        let businessCats: [String] = offerFilter["categories"] as! [String]
                        if let userCats = Yourself.categories as? [String] {
                            //cats = Checks if user is a crazy cat person.
                            //Okay maybe I shouldn't joke when commenting.
                            for userCat in userCats {
                                let catExistsInBusinessFilter = businessCats.contains(userCat)
                                if catExistsInBusinessFilter {
                                    categoryMatch = true
                                    break
                                }
                            }
                        }
                    }
                    
                    if categoryMatch && genderMatch && locationMatch {
                        let offerData = Offer.init(dictionary: OfferValue as! [String : AnyObject])
                        //Check If already accepted this offer
                        if let offer = offerData.accepted {
                        if !offer.contains(Yourself.id){
                            let allOfferIns = allOfferObject.init(offer: offerData, isFiltered: true, isAccepted: false)
                            offerList.append(allOfferIns)
                        }else{
//                           let allOfferIns = allOfferObject.init(offer: offerData, isFiltered: true, isAccepted: true)
//                            offerList.append(allOfferIns)
                        }
                        }else{
                        let allOfferIns = allOfferObject.init(offer: offerData, isFiltered: true, isAccepted: false)
                        offerList.append(allOfferIns)
                        }
                        
                    }
                    
                }
                
            }
            
            completion(true,offerList)
            
        }
        
    }) { (error) in
        
    }
}

func getFollowerCompaniesOffer(followers: [String],completion: @escaping (_ status: Bool, _ offerList: [allOfferObject]?)-> Void) {
    
    var offerList = [allOfferObject]()
    
    for (index, userID) in followers.enumerated() {
        
        
        let ref = Database.database().reference().child("OfferPool").child(userID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let totalDict = snapshot.value as? [String: AnyObject] {
                
                //allOfferObject
                                    
                    for (_, OfferValue) in totalDict {
                        
                        
                        
                        let offerData = Offer.init(dictionary: OfferValue as! [String : AnyObject])
                            //Check If already accepted this offer
                            //offerData.companyDetails!.userId = userID
                            if let offer = offerData.accepted {
                            if !offer.contains(Yourself.id){
                            //offerList.append(offerData)
                            let allObj = allOfferObject.init(offer: offerData, isFiltered: true, isAccepted: false)
                            offerList.append(allObj)
                            }else{
//                            let allObj = allOfferObject.init(offer: offerData, isFiltered: true, isAccepted: true)
//                            offerList.append(allObj)
                            }
                            }else{
                            let allObj = allOfferObject.init(offer: offerData, isFiltered: true, isAccepted: false)
                            offerList.append(allObj)
                            }
                    }
                    
                
                
                
                
            }
            
            if index == (followers.count - 1){
               completion(true,offerList)
            }
            
        }) { (error) in
            
        }
        
        
        
    }
    

}

func getOfferByBusiness(userId: String, completion:@escaping(_ status: Bool,_ offers: [allOfferObject])->()) {
    
    var offerList = [allOfferObject]()
    let ref = Database.database().reference().child("OfferPool").child(userId)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let totalDict = snapshot.value as? [String: AnyObject] {
            
            //allOfferObject
                                
                for (_, OfferValue) in totalDict {
                    
                    
                    
                    let offerData = Offer.init(dictionary: OfferValue as! [String : AnyObject])
                        //Check If already accepted this offer
                        //offerData.companyDetails!.userId = userID
                    let pay = calculateCostForUser(offer: offerData, user: Yourself)
                        if let offer = offerData.accepted {
                        if !offer.contains(Yourself.id){
                        //offerList.append(offerData)
                        
                        if pay <= offerData.money{
                        let allObj = allOfferObject.init(offer: offerData, isFiltered: true, isAccepted: false)
                        offerList.append(allObj)
                        }
                        }else{
//                            let allObj = allOfferObject.init(offer: offerData, isFiltered: true, isAccepted: true)
//                            offerList.append(allObj)
                        }
                        }else{
                        if pay <= offerData.money{
                        let allObj = allOfferObject.init(offer: offerData, isFiltered: true, isAccepted: false)
                        offerList.append(allObj)
                        }
                        }
                }
            completion(true,offerList)
            
        }else{
            completion(false,offerList)
        }
        
        
    }) { (error) in
        
    }
}

func getAcceptedOffers(completion: @escaping(_ status: Bool,_ offer: [Offer])->()) {
    
    let userRef = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id)
    
    userRef.observe(.value) { (snapshot) in
        
        if let snapDict = snapshot.value as? [String: [String: AnyObject]] {
            
            var offerList = [Offer]()
            
            for (_, offervalue) in snapDict {
                
                if let isAccepted = offervalue["status"] as? String{
                    //if isAccepted == "accepted" || isAccepted == "posted" {
                        
                        let offer = Offer.init(dictionary: offervalue)
                        
                        offerList.append(offer)
                    //}
                }
                
            }
            
            completion(true, offerList)
            
        }
        
    }
    
//    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
//
//        if let snapDict = snapshot.value as? [String: [String: AnyObject]] {
//
//            var offerList = [Offer]()
//
//            for (_, offervalue) in snapDict {
//
//                if let isAccepted = offervalue["status"] as? String{
//                    //if isAccepted == "accepted" || isAccepted == "posted" {
//
//                        let offer = Offer.init(dictionary: offervalue)
//
//                        offerList.append(offer)
//                    //}
//                }
//
//            }
//
//            completion(true, offerList)
//
//        }
//
//    }) { (error) in
//
//    }
    
}

func getFollowerList(completion:@escaping(_ status: Bool,_ users: [FollowingInformation])->()) {
    
    let userRef = Database.database().reference().child("Follower").child(Yourself.id)
    
    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let snapDict = snapshot.value as? [String: [String: AnyObject]]{
            
            var followers = [FollowingInformation]()
            
            for (_, value) in snapDict {
                var followerDetails = value
                followerDetails["tag"] = "follow" as AnyObject
                let follower = FollowingInformation.init(dictionary: followerDetails)
                followers.append(follower)
            }
            
            completion(true, followers)
            
        }
        
        
    }) { (error) in
        
    }
    
}

func getAcceptedSimplexOffer(offer: Offer,completion: @escaping(_ status: Bool, _ offer: Offer)->()) {
    
    let offerRef = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(offer.offer_ID)
    
    offerRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let snapOffer = snapshot.value as? [String: AnyObject]{
            
            let offer = Offer.init(dictionary: snapOffer)
            completion(true,offer)
            
        }
        
    }) { (error) in
        
    }
    
}

func updateReservedOfferStatus(offer: Offer) {
    
    let offerRef = Database.database().reference().child("OfferPool").child(offer.companyDetails!.userId!).child(offer.offer_ID).child("reservedUsers")
    let reserve = offer.reservedUsers![Yourself.id]
    let date = reserve!["isReservedUntil"] as AnyObject
    offerRef.updateChildValues([Yourself.id : ["isReserved":true,"isReservedUntil": date]])
    
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

func getFollowedByList(completion: @escaping(_ status: Bool, _ users: [User])->()) {
    
    let userRef = Database.database().reference().child("Follower").child(Yourself.id)
    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let snapDict = snapshot.value as? [String: AnyObject]{
            
            let keys = snapDict.keys
            
            var usersList = [User]()
            
            for (index,key) in keys.enumerated() {
                let singleUserRef = Database.database().reference().child("users").child(key)
                
                singleUserRef.observeSingleEvent(of: .value, with: { (singleSnap) in
                    
                    if let singleSnapDict = singleSnap.value as? [String: Any]{
                        let user = User.init(dictionary: singleSnapDict)
                        usersList.append(user)
                    }
                    
                    if index == keys.count - 1 {
                        completion(true, usersList)
                    }
                    
                }) { (error) in
                    
                }
            }
            
        }
        
    }) { (error) in
        
    }
    
}

func getFollowingAcceptedOffers(completion: @escaping(_ status: Bool, _ offers: [FollowingInformation])->()) {
    
    let userRef = Database.database().reference().child("Following").child(Yourself.id)
    
    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let snapDict = snapshot.value as? [String: AnyObject]{
            
            var allOfferList = [FollowingInformation]()
            let allKeys = snapDict.keys
            for (index,key) in allKeys.enumerated() {
                
                var followingInformation = [String: AnyObject]()
                
                let offerPath = Database.database().reference().child("SentOutOffersToUsers").child(key).queryOrdered(byChild: "status").queryEqual(toValue: "accepted")
                
                offerPath.observeSingleEvent(of: .value, with: { (snapOffer) in
                    
                    if let offerDict = snapOffer.value as? [String: [String:AnyObject]]{
                        
                        for (_, offerValue) in offerDict {
                           
                            followingInformation = snapDict[key] as! [String : AnyObject]
                            followingInformation["offer"] = offerValue as AnyObject
                            followingInformation["tag"] = "offer" as AnyObject
                            let offer = FollowingInformation.init(dictionary: followingInformation)
                            allOfferList.append(offer)
                        }
                        
                    }
                    
                    if index == allKeys.count - 1{
                       completion(true,allOfferList)
                    }
                    
                }) { (error) in
                    
                }
                
                
            }
        }
        
    }) { (error) in
        
    }
    
}

func getFollowingList(completion: @escaping(_ status: Bool, _ users: [AnyObject])->()) {
    
    let userRef = Database.database().reference().child("Following").child(Yourself.id)
    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let snapDict = snapshot.value as? [String: AnyObject]{
            
            var usersList = [AnyObject]()
            
            for (key,value) in snapDict {
                
                if let identifier = value["identifier"] as? String{
                    
                    if identifier == "influencer"{
                        
                        if let influencer = value["user"] as? [String: Any]{
                            let user = User.init(dictionary: influencer)
                            usersList.append(user)
                        }
                        
                    }else{
                        if let businessUser = value["user"] as? [String: AnyObject]{
                            var business = businessUser
                            business["userId"] = key as AnyObject
                            let company = CompanyDetails.init(dictionary: business)
                            usersList.append(company)
                            
                        }
                        
                    }
                    
                }
                
            }
            
            completion(true,usersList)
            
        }
        
    }) { (error) in
        
    }
    
}

func getAllOffer(completion: @escaping (_ status: Bool, _ offerList: [allOfferObject]?)-> Void) {
    let ref = Database.database().reference().child("OfferPool")
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let totalDict = snapshot.value as? [String:[String: AnyObject]] {
            
            var offerList = [allOfferObject]()
            
            for (_,value) in totalDict {
                
                for (_, OfferValue) in value {
                    
                    let offerFilter = OfferValue["influencerFilter"] as! [String: AnyObject]
                    
                    let offerFilterKeys = offerFilter.keys
                    
                    var categoryMatch = !offerFilterKeys.contains("categories")
                    var genderMatch = !offerFilterKeys.contains("gender")
                    var locationMatch = !offerFilterKeys.contains("zipCode")
                    
                    if !genderMatch {
                        let gender: [String] = offerFilter["gender"] as! [String]
                        if let userGender = Yourself.gender!.rawValue as? String {
                            if gender.contains(userGender) {
                                genderMatch = true
                            }
                        }
                    }
                    
                    if !locationMatch && genderMatch {
                        let zips: [String] = offerFilter["zipCode"] as! [String]
                        if let userZip = Yourself.zipCode {
                            if zips.contains(userZip) {
                                locationMatch = true
                            }
                        }
                    }
                    
                    if !categoryMatch && locationMatch && genderMatch {
                        let businessCats: [String] = offerFilter["categories"] as! [String]
                        if let userCats = Yourself.categories as? [String] {
                            //cats = Checks if user is a crazy cat person.
                            //Okay maybe I shouldn't joke when commenting.
                            for userCat in userCats {
                                let catExistsInBusinessFilter = businessCats.contains(userCat)
                                if catExistsInBusinessFilter {
                                    categoryMatch = true
                                    break
                                }
                            }
                        }
                    }
                    
                    if categoryMatch && genderMatch && locationMatch {
                        let offerData = Offer.init(dictionary: OfferValue as! [String : AnyObject])
                        //Check If already accepted this offer
                        if let offer = offerData.accepted {
                        if !offer.contains(Yourself.id){
                            let allOfferObj = allOfferObject.init(offer: offerData, isFiltered: true, isAccepted: false)
                        offerList.append(allOfferObj)
                        }else{
//                        let allOfferObj = allOfferObject.init(offer: offerData, isFiltered: true, isAccepted: true)
//                        offerList.append(allOfferObj)
                        }
                        }else{
                            let allOfferObj = allOfferObject.init(offer: offerData, isFiltered: true, isAccepted: false)
                        offerList.append(allOfferObj)
                        }
                        
                        
                        
                    }else{
                        let offerData = Offer.init(dictionary: OfferValue as! [String : AnyObject])
                        //Check If already accepted this offer
                        if let offer = offerData.accepted {
                        if !offer.contains(Yourself.id){
                            let allOfferObj = allOfferObject.init(offer: offerData, isFiltered: false, isAccepted: false)
                        offerList.append(allOfferObj)
                        }else{
                            let allOfferObj = allOfferObject.init(offer: offerData, isFiltered: false, isAccepted: true)
                            offerList.append(allOfferObj)
                        }
                        }else{
                            let allOfferObj = allOfferObject.init(offer: offerData, isFiltered: false, isAccepted: false)
                        offerList.append(allOfferObj)
                        }
                        
                        //let allOfferObj = allOfferObject.init(offer: offerData, isFiltered: false)
                        //offerList.append(allOfferObj)
                    }
                    
                }
                
            }
            
            completion(true,offerList)
            
        }
        
    }) { (error) in
        
    }
}



//func authenticateUser(email: String, password: String, completion: @escaping(_ success: Bool)-> Void) {
//
//}

/*
 for (key,_) in snapValue {
 //
 //                if key == userID {
 //                    isAlreadyRegistered = true
 //                }
 //            }
 //
 //            if !isAlreadyRegistered{
 //                createNewInfluencerAuthentication(info: NewAccount)
 //                let userData = API.serializeRawUserData(details: NewAccount)
 //                ref.updateChildValues(userData)
 //                completion(false)
 //            }else{
 //                completion(true)
 //            }
 */
