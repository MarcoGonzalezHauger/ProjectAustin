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


func updateNewTransLog(transID: String, userID: String, log: [String: Any]) {
    let ref = Database.database().reference().child("Accounts/Private/Influencers").child(userID).child("finance").child("log").child(transID)
    ref.updateChildValues(log)
}



func addStripeAccountInfoToFIR(stripeInfo:[String:Any]) {
    
    let ref = Database.database().reference().child("Accounts/Private/Influencers").child(Myself.userId).child("finance")
    ref.updateChildValues(["stripeAccount": stripeInfo])
}


func checkNewIfInstagramExist(id: String, completion: @escaping(_ exist: Bool,_ user: Influencer?)-> Void) {
    var isExist = false
    var userID = ""
    let ref = Database.database().reference().child("Accounts/Private/Influencers")
    let query = ref.queryOrdered(byChild: "instagramAccountId").queryEqual(toValue: id)
    query.observeSingleEvent(of: .value, with: { (snapshot) in
        
        //if let _ = snapshot.value as? [String: AnyObject] {
        if snapshot.exists() {
            
            if let snapValue = snapshot.value as? [String: AnyObject]{
                for (key,_) in snapValue {
                    userID = key
                }
                isExist = true
                if let valueData = snapValue[userID] as? [String: Any] {
                    let user = Influencer.init(dictionary: valueData, userId: userID)
                    completion(isExist,user)
                }
                
                
            }
            
            
        }else{
            completion(isExist, nil)
        }
        
    }) { (error) in
        completion(isExist, nil)
    }

}

func checkNewIfEmailExist(email: String, completion: @escaping(_ exist: Bool)-> Void) {
    var isExist = false
    //let ref = Database.database().reference().child("InfluencerAuthentication")
    let ref = Database.database().reference().child("Accounts/Private/Influencers")
    let query = ref.queryOrdered(byChild: "email").queryEqual(toValue: email)
    query.observeSingleEvent(of: .value, with: { (snapshot) in
        
        //if let _ = snapshot.value as? [String: AnyObject] {
        if snapshot.exists() {
            isExist = true
            completion(isExist)
            
        }else{
            completion(isExist)
        }
        
    }) { (error) in
        completion(isExist)
    }
}

func filterNewQueryByField(email: String, completion:@escaping(_ exist: Bool, _ userData: [String: AnyObject]?)->Void){
    
    let ref = Database.database().reference().child("Accounts/Private/Influencers")
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

