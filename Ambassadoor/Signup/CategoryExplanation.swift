//
//  CategoryExplanation.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 10/24/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class CategoryExplanation: UIViewController {

	@IBOutlet weak var Box: ShadowView!
	@IBOutlet weak var okayButton: UIButton!
	@IBOutlet weak var Slider: UIView!
	@IBOutlet weak var sliderWidth: NSLayoutConstraint!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		sliderWidth.constant = 0
    }
    
	override func viewDidAppear(_ animated: Bool) {
		sliderWidth.constant = 0
		
		view.layoutIfNeeded()
		sliderWidth.constant = Box.bounds.width

		UIView.animate(withDuration: 5.0, animations: {
			 self.view.layoutIfNeeded()
		})
		DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
			self.okayButton.setTitle("OKAY", for: .normal)
		}
	}

	@IBAction func okayCilcked(_ sender: Any) {
		dismiss(animated: false) {
			self.delegate?.Explained()
		}
	}
	
	var delegate: CategoryExplainedDelegate?

}
