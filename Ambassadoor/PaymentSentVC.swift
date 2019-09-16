//
//  PaymentSentVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 9/13/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class PaymentSentVC: UIViewController {

	@IBOutlet weak var moneyAmountLabel: UILabel!
	
	var MoneyAmount: Double = 0 {
		didSet {
			moneyAmountLabel.text = NumberToPrice(Value: MoneyAmount)
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		moneyAmountLabel.text = NumberToPrice(Value: MoneyAmount)
    }
	
	@IBAction func Dismissed(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
}
