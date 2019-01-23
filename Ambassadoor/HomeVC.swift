//
//  HomeVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/20/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate, OfferCellDelegate, GlobalListener, OfferResponse {
	
	func OfferAccepted(offer: Offer) {
		isQue = true
		if let ip : IndexPath = currentviewoffer {
			global.AvaliableOffers[ip.row].isAccepted = true
			global.AcceptedOffers.append(global.AvaliableOffers[ip.row])
			global.AvaliableOffers.remove(at: ip.row)
			shelf.deleteRows(at: [ip], with: .right)
		}
		isQue = false
	}
	
	var isQue: Bool = false
	
	func isQueued(isQue: Bool) {
		self.isQue = isQue
	}
	
	func AvaliableOffersChanged() {
		if isQue == false {
			shelf.reloadData()
		}
	}
	
	//Offer was rejected; Remove it from the list and add it to the rejected VCs List.
	func OfferRejected(sender: Any) {
		if let ip : IndexPath = shelf.indexPath(for: sender as! UITableViewCell) {
			global.RejectedOffers.append(global.AvaliableOffers[ip.row])
			global.AvaliableOffers.remove(at: ip.row)
			shelf.deleteRows(at: [ip], with: .left)
		}
	}

	var Pager: PageVC!
	var viewoffer: Offer?
	var currentviewoffer: IndexPath?
	
	//simply shows the offer.
	func ViewOffer(sender: Any) {
		if let sender = sender as? OfferCell {
			viewoffer = sender.ThisOffer
			currentviewoffer = shelf.indexPath(for: sender)
		}
		performSegue(withIdentifier: "viewOfferSegue", sender: self)
	}
	
	//makes sure the offer is showing in the segue.
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let newviewoffer = viewoffer else { return }
		let destination = segue.destination
		if segue.identifier == "viewOfferSegue" {
			if let destination = (destination as! UINavigationController).topViewController as? OfferVC {
				destination.delegate = self
				destination.ThisOffer = newviewoffer
			}
		}
	}
	
	//The Table view in which users are given offers
	@IBOutlet weak var shelf: UITableView!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return global.AvaliableOffers.count
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
		cell.ThisOffer = global.AvaliableOffers[indexPath.row]
		return cell
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		//First code to be executed when opening App
		
		//declare datasource & Delegates
		shelf.delegate = self
		shelf.dataSource = self
		global.delegates.append(self)
		
		//Debugging Fake Offers
		
		let fakeoffers: [Offer] = GetOffers()
		global.AvaliableOffers = fakeoffers.filter({$0.isAccepted == false})
		global.AcceptedOffers = fakeoffers.filter({$0.isAccepted == true})
		
		let fakeusers: [User] = GetRelevantPeople()
		global.SocialData = fakeusers
		
    }
}
