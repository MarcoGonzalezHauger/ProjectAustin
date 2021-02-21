//
//  SocialAlgorithms.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/1/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation


func isValidEmail(emailStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: emailStr)
}

func isMeetingComplexity(password: String) -> Int {
    switch password {
    case _ where password.count < 7:
        return 1
//    case _ where password.uppercased() == password:
//        return 1
//    case _ where password.lowercased() == password:
//        return 1
    case _ where password.lowercased().contains("ambassadoor"):
		return 2
    default:
        return 0
    }
    
}
