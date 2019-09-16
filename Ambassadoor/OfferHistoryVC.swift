//
//  OfferHistoryVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 9/11/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class OldOfferCell: UITableViewCell {
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var completedLabel: UILabel!
	@IBOutlet weak var infoLabel: UILabel!
}

class OfferHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var shelf: UITableView!
	
	var PreviousOffers: [Offer] = [] {
		didSet {
			shelf.reloadData()
		}
	}
	
	@IBAction func dismissed(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		//TODO: NAVEEN TO-DO
		//Load offers that have already been completed into PreviousOffers: [Offer] = []
		
		shelf.delegate = self
		shelf.dataSource = self
    }
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let thisOffer = PreviousOffers[indexPath.row]
		let cell = shelf.dequeueReusableCell(withIdentifier: "oldOffer") as! OldOfferCell
		cell.nameLabel.text = thisOffer.company.name
		cell.completedLabel.text = DateToAgo(date: thisOffer.allPostsConfrimedSince!)
		cell.infoLabel.text = "\(thisOffer.posts.count) post\(thisOffer.posts.count == 1 ? "" : "s") for \(NumberToPrice(Value: thisOffer.money))"
		return cell
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return PreviousOffers.count
	}

}
