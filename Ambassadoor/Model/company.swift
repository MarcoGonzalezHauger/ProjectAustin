//
//  company.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 18/01/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase


func GetAllBusiness(completion:@escaping (_ result: [CompanyDetails])->()) {
    let usersRef = Database.database().reference().child("companies")
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
    //usersRef.observe(.value, with: { (snapshot) in
        
        if let snapDict = snapshot.value as? [String: [String: AnyObject]]{
            
            var companyList = [CompanyDetails]()
            
            for(key,value) in snapDict{
                for (_, companyValue) in value {
                    do {
                        let companyDetails = try CompanyDetails.init(dictionary: companyValue as! [String : AnyObject])
                        companyDetails.userId = key
                        companyList.append(companyDetails)
                    } catch {
                        print(companyValue)
                        print(error.localizedDescription)
                    }
                    
                }
            }
            
            completion(companyList)
        }
        
    }) { (error) in
        
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
        }
    }, withCancel: nil)
}
