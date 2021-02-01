//
//  PoolOfferNC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/1/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class PoolOfferNC: StandardNC {

    override func viewDidLoad() {
        super.viewDidLoad()
			
    }
	
	func SetPoolOffer(poolOffer: PoolOffer) {
		let vpo = self.topViewController as! NewViewPoolOfferVC
		   vpo.thisPoolOffer = poolOffer
	}

}
