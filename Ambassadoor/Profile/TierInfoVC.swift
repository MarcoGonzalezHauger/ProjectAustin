//
//  TierInfoVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 10/29/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class TierCell: UITableViewCell {
	@IBOutlet weak var tierNumber: UILabel!
	@IBOutlet weak var treshholds: UILabel!
	@IBOutlet weak var tierBubble: UIView!
	@IBOutlet weak var YouLabel: UILabel!
	
	override func awakeFromNib() {
		tierBubble.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "tiergrad")!)
	}
}

class TierInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return TierThreshholds.count
	}
	
	@IBOutlet weak var isVerifiedSwitch: UISwitch!
	
	@IBAction func verifiedSwitch(_ sender: Any) {
		shelf.reloadData()
	}
	
	let myTier = GetTierForInfluencer(influencer: Yourself)
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = shelf.dequeueReusableCell(withIdentifier: "tierCell") as! TierCell
		let i = indexPath.row
		cell.YouLabel.isHidden = i != myTier
		cell.tierNumber.text = "\(isVerifiedSwitch.isOn ? i + 1 : i)"
		if i > TierThreshholds.count - 2 {
			cell.treshholds.text = "\(NumberToStringWithCommas(number: TierThreshholds.last!))+"
		} else {
			cell.treshholds.text = "\(NumberToStringWithCommas(number:TierThreshholds[i]))-\(NumberToStringWithCommas(number:TierThreshholds[i + 1] - 1))"
		}
		return cell
	}
	

	@IBOutlet weak var shelf: UITableView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		isVerifiedSwitch.isOn = Yourself.isDefaultOfferVerify
    }

	@IBAction func doneClicked(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
}
