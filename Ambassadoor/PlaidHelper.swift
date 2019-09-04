//
//  PlaidHelper.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 22/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import LinkKit


class PlaidHelper {
    
    // plaid sandbox key for marco
    static let linkConfiguration = PLKConfiguration(key: "a5997e44c49652ae5141e1eb082ccc", env: .sandbox, product: [.auth, .transactions], selectAccount: true, longtailAuth:false, apiVersion: .PLKAPIv2)

    // plaid sandbox key for naveen
//    static let linkConfiguration = PLKConfiguration(key: "401af1410f180eb96ef05c283693c1", env: .sandbox, product: [.auth, .transactions], selectAccount: true, longtailAuth:false, apiVersion: .PLKAPIv2)
    
    
    // plaid live key
//    static let linkConfiguration = PLKConfiguration(key: "", env: .production, product: [.auth, .transactions], selectAccount: true, longtailAuth:false, apiVersion: .PLKAPIv2)
    
    
    
}
