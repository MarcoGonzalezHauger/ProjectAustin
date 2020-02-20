//
//  StringExtention.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 19/02/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import CommonCrypto

extension String{
    
    func md5() -> String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0..<digestLength {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize(count: digestLength)
        return String(format: hash as String)
    }
    
}
