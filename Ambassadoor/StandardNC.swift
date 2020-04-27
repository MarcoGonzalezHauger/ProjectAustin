//
//  StandardNC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 4/26/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

protocol NCDelegate {
	func shouldAllowBack() -> Bool
}

class StandardNC: UINavigationController, UIGestureRecognizerDelegate {
	
	var tempDelegate: NCDelegate?
	var shouldDismissOnLastSlide = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.interactivePopGestureRecognizer?.delegate = self
	}
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		if(self.viewControllers.count > 1){
			if let td = tempDelegate {
				return td.shouldAllowBack()
			}
			return true
		} else {
			if shouldDismissOnLastSlide {
				self.dismiss(animated: true, completion: nil)
			}
			return false
		}
	}
	
}
