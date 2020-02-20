//
//  ViewOfferNC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/29/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class ViewOfferNC: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
		self.interactivePopGestureRecognizer?.delegate = self
    }
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		if(self.viewControllers.count > 1){
			return true
		} else {
			self.dismiss(animated: true, completion: nil)
			return false
		}
	}

}
