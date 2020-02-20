//
//  StatVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/25/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class StatVC: UIViewController {

	func SetStat(Statistic: Stat) {
		headerLabel.text = Statistic.name
		var num: String = NumberToStringWithCommas(number: Statistic.delta)
		if Statistic.delta == 0 {
			Value.textColor = UIColor(red: 185/255, green: 185/255, blue: 185/255, alpha: 1)
			shdwView.ShadowColor = UIColor(red: 185/255, green: 185/255, blue: 185/255, alpha: 1)
		} else if Statistic.delta > 0 {
			Value.textColor = UIColor(red: 42/255, green: 160/255, blue: 88/255, alpha: 1)
			shdwView.ShadowColor = UIColor(red: 42/255, green: 160/255, blue: 88/255, alpha: 1)
			num = "+\(num)"
		} else {
			Value.textColor = UIColor(red: 200/255, green: 0, blue: 0, alpha: 1)
			shdwView.ShadowColor = UIColor(red: 200/255, green: 0, blue: 0, alpha: 1)
		}
		theirValue.text = "\(NumberToStringWithCommas(number: Statistic.value2))"
		yourValue.text = "\(NumberToStringWithCommas(number: Statistic.value1))"
		Value.text = num
	}
	
	@IBOutlet weak var shdwView: ShadowView!
	
	var ThisStat: Stat? {
		didSet {
			if isViewLoaded {
				if let thisStat = ThisStat {
					SetStat(Statistic: thisStat)
				}
			}
		}
	}
	
	@IBOutlet weak var headerLabel: UILabel!
	@IBOutlet weak var Value: UILabel!
	@IBOutlet weak var theirValue: UILabel!
	@IBOutlet weak var yourValue: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		if let thisStat = ThisStat {
			SetStat(Statistic: thisStat)
		}
		
    }
	
	@IBAction func dissmiss(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
		self.dismiss(animated: true, completion: nil)
	}
	
}
