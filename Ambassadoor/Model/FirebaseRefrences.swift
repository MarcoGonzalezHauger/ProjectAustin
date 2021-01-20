//
//  FirebaseRefrences.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/21/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import Foundation
import Firebase

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
            let userData = API.serializeUserWithOutMoney(user: user, id: user.id)
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

func checkIfInstagramExist(id: String, completion: @escaping(_ exist: Bool,_ user: InfluencerAuthenticationUser?)-> Void) {
    
    let ref = Database.database().reference().child("InfluencerAuthentication").child("17841430066849402")
    ref.observeSingleEvent(of: .value) { (snapshot) in
        
        if snapshot.exists(){
            
            
            if let userData = snapshot.value as? [String: AnyObject]{
                
                let user = InfluencerAuthenticationUser.init(dictionary: userData)
                
                completion(true, user)
                
            }else{
                
                completion(false, nil)
                
            }
        }else{
            
            completion(false, nil)
        }
        
    }
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

func updateFollowingFollowerUser(user: User, identifier: String) {
    
    // update Following & Follower
    
    let userFollowingRef = Database.database().reference().child("Following").child(Yourself.id)
    let userDetails = API.serializeUserWithOutMoney(user: user, id: user.id)
    userFollowingRef.updateChildValues([user.id: ["identifier": identifier,"user":userDetails,"startedAt": Date.getStringFromDate(date: Date()) as Any] ])
    
    let userFollowerRef = Database.database().reference().child("Follower").child(user.id)
    let followerDetails = API.serializeUserWithOutMoney(user: user, id: user.id)
    userFollowerRef.updateChildValues([Yourself.id: ["identifier": "influencer","user":followerDetails, "startedAt": Date.getStringFromDate(date: Date()) as Any]])
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
    userFollowingRef.updateChildValues([user.userId!: ["identifier": identifier,"user":userDetails,"startedAt":Date.getStringFromDate(date: Date()) as Any] ])
}

func removeFollowingFollowerBusinessUser(user: CompanyDetails) {
    
    // Remove Following & Follower
    
    let userFollowingRef = Database.database().reference().child("Following").child(Yourself.id).child(user.userId!)
    userFollowingRef.removeValue()
    
}


func updatePassword(userID: String,password: String){
    
    let ref = Database.database().reference().child("InfluencerAuthentication").child(userID)
    ref.updateChildValues(["password":password])
    
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
                
                if let user = follower.user {
                    if Yourself.following?.contains(follower.user?.id ?? "X") ?? false && API.isForTesting == true ? user.isForTesting : !user.isForTesting{
                        
                        let checkVersionStatus = global.appVersion!.compare(follower.user!.version!, options: .numeric)
                        
                        if checkVersionStatus == .orderedDescending || checkVersionStatus == .orderedSame {
                            print("This version is 2.0.0 or above")
                            followers.append(follower)
                        }
                        
                        
                    }
                }
            }
            
            completion(true, followers)
            
        }
        
        
    }) { (error) in
        
    }
    
}

func getFollowedByList(completion: @escaping(_ status: Bool, _ users: [User])->()) {
    
    let userRef = Database.database().reference().child("Follower").child(Yourself.id)
    //userRef.observeSingleEvent(of: .value, with: { (snapshot) in
    userRef.observe(.value, with: { (snapshot) in
        
        if let snapDict = snapshot.value as? [String: AnyObject]{
            
            let keys = snapDict.keys
            
            var usersList = [User]()
            
            var indexInc = 0
            
            
            for (index,key) in keys.enumerated() {
                
                
                
                let singleUserRef = Database.database().reference().child("users").child(key)
                singleUserRef.observeSingleEvent(of: .value, with: { (singleSnap) in
                    
                    indexInc += 1
                    
                    if let singleSnapDict = singleSnap.value as? [String: Any]{
                        
                        
                        do {
                            let user = try User.init(dictionary: singleSnapDict)
                            
                            if API.isForTesting == true ? user.isForTesting : !user.isForTesting{
                                
                                let checkVersionStatus = global.appVersion!.compare(user.version!, options: .numeric)
                                
                                if checkVersionStatus == .orderedDescending || checkVersionStatus == .orderedSame{
                                    usersList.append(user)
                                    print("version is 2.0.0 or above")
                                }
                                
                            }
                            
                        } catch let error {
                            print(error)
                        }
                        
                    }
                    
                    if indexInc == keys.count {
                        
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
                            
                            let checkVersionStatus = global.appVersion!.compare(offer.user!.version!, options: .numeric)
                            
                            if let user = offer.user{
                                
                                if Yourself.following?.contains(offer.user?.id ?? "X") ?? false && API.isForTesting == true ? user.isForTesting : !user.isForTesting {
                                    if checkVersionStatus == .orderedDescending || checkVersionStatus == .orderedSame{
                                        allOfferList.append(offer)
                                    }
                                }
                                
                            }
                            
                            
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
    //userRef.observe(.value, with: { (snapshot) in
        
        if let snapDict = snapshot.value as? [String: AnyObject]{
            
            var usersList = [AnyObject]()
            
            for (key,value) in snapDict {
                
                if let identifier = value["identifier"] as? String{
                    
                    if identifier == "influencer"{
                        
                        if let influencer = value["user"] as? [String: Any]{
                            
                            
                            do {
                                let user = try User.init(dictionary: influencer)
                                
                                if API.isForTesting == true ? user.isForTesting : !user.isForTesting{
                                
                                let checkVersionStatus = global.appVersion!.compare(user.version!, options: .numeric)
                                
                                if checkVersionStatus == .orderedAscending || checkVersionStatus == .orderedSame{
                                    if (Yourself.following?.contains(user.id))! {
                                        usersList.append(user)
                                    }
                                }
                                
                            }
                                
                                
                            } catch let error {
                                print(error)
                            }
                            
                            
                        }
                        
                    }else{
                        if let businessUser = value["user"] as? [String: AnyObject]{
                            let business = businessUser
                            do {
                                let company = try CompanyDetails.init(dictionary: business)
                                if API.isForTesting == true ? company.isForTesting : !company.isForTesting {
                                    company.userId = key
                                    usersList.append(company)
                                }
                                
                            } catch let error {
                                print(error)
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
            }
            
            usersList.sort { (item1, item2) -> Bool in
                let isOneBusiness = (item1 as? User) == nil
                let isTwoBusiness = (item2 as? User) == nil
                if isOneBusiness != isTwoBusiness {
                    return isOneBusiness
                }
                
                if isOneBusiness == true {
                    let business1 = item1 as! CompanyDetails
                    let business2 = item2 as! CompanyDetails
                    return business1.name > business2.name
                } else {
                    let influencer1 = item1 as! User
                    let influencer2 = item2 as! User
                    return influencer1.averageLikes ?? 0 > influencer2.averageLikes ?? 0
                }
            }
            completion(true, usersList)
            
        }
        
    }) { (error) in
        
    }
    
}

func uploadImageToFIR(image: UIImage, childName: String, path: String, completion: @escaping (String,Bool) -> ()) {
    let data = image.jpegData(compressionQuality: 0.2)
    let fileName = path + ".png"
    let ref = Storage.storage().reference().child(childName).child(fileName)
    ref.putData(data!, metadata: nil, completion: { (metadata, error) in
        if error != nil {
            debugPrint(error!)
            completion("", true)
            return
        }else {
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                completion("", true)
                return
            }
            // You can also access to download URL after upload.
            ref.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    completion("", true)
                    return
                }
                completion(downloadURL.absoluteString, false)
            }
        }
        debugPrint(metadata!)
    })
    //return id
}

func getDownloadedLink() {
    
    let ref = Storage.storage().reference().child("profile").child("17841430066849401.jpeg")
    ref.downloadURL { (url, error) in
        guard let downloadURL = url else {
            // Uh-oh, an error occurred!
            return
        }
        print("aaaaa",downloadURL)
    }
}

func addDevelopmentSettings() {
    
    let ref = Database.database().reference().child("developmentSettings")
    ref.updateChildValues(["development":"dontUseInstagramBasicDisplay"])
}

func GetDevelopmentSettings(completion: @escaping (_ developmentSettings: String?)-> ()) {
    let ref = Database.database().reference().child("developmentSettings")
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let snapValue = snapshot.value as? [String: AnyObject]{
            if let developmentSettingValue = snapValue["development"] as? String{
                completion(developmentSettingValue)
            }else{
                completion(nil)
            }
        }
        
    }) { (error) in
        completion(nil)
    }
}

