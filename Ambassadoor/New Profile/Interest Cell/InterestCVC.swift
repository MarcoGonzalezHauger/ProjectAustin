//
//  InterestCVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/29/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class InterestCVC: UICollectionViewCell {

	@IBOutlet weak var interestLabel: UILabel!
	//@IBOutlet weak var interestImage: UIImageView!
	@IBOutlet weak var mainView: ShadowView!
	
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	var i: String = ""
	
	var interest: String {
		get {
			return i
		}
		set {
			i = newValue
			UpdateInterestImage()
		}
	}
	
	func UpdateInterestImage() {
		
		
		if interest != "" {
			interestLabel.text = EmojiInterests[interest]
			
			//interestImage.downloadAndSetImage(GetInterestUrl(interest: interest), forceDownload: false)
		} else {
			interestLabel.text = "➕" //🟥🟧🟩🟪🟨🟦⬛️⬜️🟫
//			if #available(iOS 13.0, *) {
//				//interestImage.image = .add
//			} else {
//				//interestImage.image = UIImage(named: "Add Interest")!
//			}
		}
	}
	
}
