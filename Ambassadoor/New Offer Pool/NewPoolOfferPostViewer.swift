//
//  NewPoolOfferPostViewer.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/1/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewPoolOfferPostViewer: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		updateContents()
    }
	
	@IBOutlet weak var foreImage: UIImageView!
	@IBOutlet weak var backImage: UIImageView!
	
	@IBOutlet weak var indexLabel: UILabel!
	
	@IBOutlet weak var instructions: UILabel!
	@IBOutlet weak var captionLabel: UILabel!
	
	var thisPoolOffer: PoolOffer!
	var index: Int = 0
	
	@IBAction func backPressed(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	
	func updateContents() {
		foreImage.downloadAndSetImage(thisPoolOffer.BasicBusiness()!.logoUrl)
		backImage.downloadAndSetImage(thisPoolOffer.BasicBusiness()!.logoUrl)
		indexLabel.text = "\(index + 1)"
		instructions.text = thisPoolOffer.draftPosts[index].instructions
		var allItems: [String] = []
		for i in thisPoolOffer.draftPosts[index].requiredKeywords {
			allItems.append(" - " + i)
		}
		for i in thisPoolOffer.draftPosts[index].requiredHastags {
			allItems.append(" - #" + i)
		}
		captionLabel.text = allItems.joined(separator: "\n")
	}

}
