//
//  inProgressVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/30/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class inProgressVC: UIViewController, UITableViewDataSource, UITableViewDelegate, OfferCellDelegate, GlobalListener {
	
	@IBOutlet weak var shelf: UITableView!
	
	//This "isQue" is to ensure that animations can happen before a globallistener is triggered.
	var isQue: Bool = false
	func isQueued(isQue: Bool) {
		self.isQue = isQue
	}
	func AcceptedOffersChanged() {
		if isQue == false {
			shelf.reloadData()
		}
	}
	
	//No offer rejected because it will be hidden.
	func OfferRejected(sender: Any) {
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		debugPrint("cell selected at \(indexPath.row) (within InProgress Tab)")
		ViewOfferFromCell(sender: shelf.cellForRow(at: indexPath) as! OfferCell)
		shelf.deselectRow(at: indexPath, animated: false)
	}
	
	//Offer to be viewed when segue to OfferVC is called.
	var viewoffer: Offer?
	
	func ViewOfferFromCell(sender: Any) {
		if let sender = sender as? OfferCell {
			viewoffer = sender.ThisOffer
		}
		self.performSegue(withIdentifier: "viewOfferInProgress", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let newviewoffer = viewoffer else { return }
		let destination = segue.destination
		if segue.identifier == "viewOfferInProgress" {
			if let destination = (destination as! UINavigationController).topViewController as? OfferVC {
				destination.isCloseButton = true
				destination.ThisOffer = newviewoffer
			}
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return global.AcceptedOffers.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return 120
		}
		return 110
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = shelf.dequeueReusableCell(withIdentifier: "HomeOfferCell")  as! OfferCell
		cell.delegate = self
		cell.ThisOffer = global.AcceptedOffers[indexPath.row]
		cell.rejectbutton.isHidden = true
		return cell
	}
	
	@IBOutlet weak var backBtn: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		shelf.delegate = self
		shelf.dataSource = self
		global.delegates.append(self)
		backBtn.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    }
	
	var Pager: PageVC!
	
	@IBAction func returntoHome(_ sender: Any) {
		Pager.goToPage(index: 1, sender: self)
	}

}
