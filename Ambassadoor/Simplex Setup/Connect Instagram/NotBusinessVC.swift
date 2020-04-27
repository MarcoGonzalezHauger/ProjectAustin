//
//  NotBusinessVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/16/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NotBusinessVC: UIViewController {
	
	//[RAM] I can not get the scroll view to work, can you take a look at it?
	
	@IBOutlet weak var scrollView: UIScrollView!
	var delegate: VerificationReturned?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		delegate?.ThatsNotMe()
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
		scrollView.alwaysBounceVertical = false
    }
	@IBAction func closeButtonPressed(_ sender: Any) {
		delegate?.ThatsNotMe()
		dismiss(animated: true, completion: nil)
	}
	
}
