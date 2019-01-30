//
//  HomeVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/20/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit
import Firebase

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
		if segue.identifier == "viewOfferSegue" {
			guard let newviewoffer = viewoffer else { return }
			let destination = segue.destination
			if let destination = (destination as! UINavigationController).topViewController as? OfferVC {
				destination.delegate = self
				destination.ThisOffer = newviewoffer
			}
		} else {
			debugPrint("Segue to sign up is being prepared.")
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
	
	func GetSortedAvaliableOffers() -> [Offer] {
		var sortedavaliableoffers: [Offer] = global.AvaliableOffers
		sortedavaliableoffers.sort{ (Offer1, Offer2) -> Bool in
			return (Offer1.money / Double(Offer1.posts.count)) > (Offer2.money / Double(Offer2.posts.count))
		}
		return sortedavaliableoffers
	}
	
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = shelf.dequeueReusableCell(withIdentifier: "HomeOfferCell")  as! OfferCell
		cell.delegate = self
		cell.ThisOffer = GetSortedAvaliableOffers()[indexPath.row]
		return cell
	}
    
    var ref: DatabaseReference!
	
	override func viewDidAppear(_ animated: Bool) {
		performSegue(withIdentifier: "showSignUpVC", sender: self)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		debugPrint("Home VC started to load.")
		
		//First code to be executed when opening App
		
		//declare datasource & Delegates
		shelf.delegate = self
		shelf.dataSource = self
		global.delegates.append(self)
		
		//Debugging Fake Offers
		
		let fakeoffers: [Offer] = GetFakeOffers()
		global.AvaliableOffers = fakeoffers.filter({$0.isAccepted == false})
		global.AcceptedOffers = fakeoffers.filter({$0.isAccepted == true})
		
		let fakeusers: [User] = GetRelevantPeople()
		global.SocialData = fakeusers
        
        ref = Database.database().reference()
        
        // Creating account with call to function (uncomment to for new data to appear in Firebase)
        //let accountCreated: Bool = CreateAccount(instagramUsername: "czar_chomicki", ref: ref)
        
        // Gets offers by on userId, will need to test data in firebase to test this, but pointer connection works
        //let offers = GetOffers(userId: "test", ref: ref)
		
		
		debugPrint("Home VC has been loaded.")
		
    }
}
