//
//  YouVsThemViewerVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/30/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class YouVsThemViewerVC: UIViewController {

	@IBOutlet weak var heading1Label: UILabel!
	@IBOutlet weak var statistic1Label: UILabel!
	@IBOutlet weak var heading2Label: UILabel!
	@IBOutlet weak var statistic2Label: UILabel!
	
	@IBOutlet weak var differenceLabel: UILabel!
	@IBOutlet weak var differenceView: ShadowView!
	
	@IBAction func closeButtonPressed(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		heading1Label.text = "Your " + heading
		heading2Label.text = "Their " + heading
		differenceView.borderColor = GetColorForNumber(number: difference)
		
		if heading == "Engagement Rate" {
			statistic1Label.text = engagmentRateInDetail(engagmentRate: stat1, enforceSign: false)
			statistic2Label.text = engagmentRateInDetail(engagmentRate: stat2, enforceSign: false)
			differenceLabel.text = engagmentRateInDetail(engagmentRate: difference, enforceSign: true)
		} else {
			statistic1Label.text = NumberToStringWithCommas(number: stat1)
			statistic2Label.text = NumberToStringWithCommas(number: stat2)
			var diffText = NumberToStringWithCommas(number: difference)
			if difference > 0 {
				diffText = "+" + diffText
			}
			differenceLabel.text = diffText
		}
	}
    
	var stat1: Double = 0
	var stat2: Double = 0
	var difference: Double = 0
	var heading: String = "" //Average Likes, Folowers, Engagement Rate

}
