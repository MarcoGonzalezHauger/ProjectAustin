//
//  HomeVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/20/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

//Protocol for interactions with indivisual Offer Cells
@objc protocol OfferCellDelegate {
	@objc optional func OfferRejected(sender: Any) -> ()
	func ViewOffer(sender: Any) -> ()
	func isQueued(isQue: Bool) -> ()
}



class OfferCell: UITableViewCell, SyncTimerDelegate {
	
	
	//Handles all offer experation display information.
	func Tick() {
		if let o : Offer = ThisOffer {
			
			//Ago label.
			agolabel.text = DateToAgo(date: o.offerdate)
			
			//If the reject button exists, it lets the program know if the offer is rejected or not.
			if rejectbutton != nil {
				
				//If the offer HASN'T been rejected yet, but is expired, it will reject the offer. When the user sees it, it will be expired there.
				if DateToCountdown(date: o.expiredate) == nil {
					reject(self)
					return
				}
				if o.expiredate.timeIntervalSinceNow < 3600 {
					agolabel.textColor = UIColor.red
				}
			} else {
				
				//Offers that have already been rejected will not show the view button, instead a countdown to when they're expired. Which is usually in 1 hour since rejection.
				if let expiresin = expiresInLabel {
					//if experation date is more than "now" (which will return NIL), say "expired" in red.
					if let leftstring : String = DateToCountdown(date: o.expiredate)  {
						expiresin.text = "Expires " + leftstring
						expiresin.textColor = UIColor.black
					} else {
						viewbutton.isHidden = true
						agolabel.isHidden = true
						expiresin.text = "Expired"
						expiresin.textColor = UIColor.red
					}
				}
				
			}
		}
	}
	
	@IBOutlet weak var viewbutton: UIButton!
	@IBOutlet weak var rejectbutton: UIButton!
	@IBOutlet weak var View: UIView!
	@IBOutlet weak var moneylabel: UILabel!
	@IBOutlet weak var postsLabel: UILabel!
	@IBOutlet weak var companylabel: UILabel!
	@IBOutlet weak var agolabel: UILabel!
	@IBOutlet weak var expiresInLabel: UILabel!
	
	//Clicks view on offer
	@IBAction func view(_ sender: Any) {
		if let dlg = delegate {
			dlg.isQueued(isQue: true)
			dlg.ViewOffer(sender: self)
			dlg.isQueued(isQue: false)
		}
	}
	
	override func awakeFromNib() {
		globalTimer.delegates.append(self)
		Tick()
	}
	
	//User rejects offer :(
	@IBAction func reject(_ sender: Any) {
		if let dlg = delegate {
			dlg.isQueued(isQue: true)
			dlg.OfferRejected?(sender: self)
			dlg.isQueued(isQue: false)
		}
	}
	
	//delegate for offer
	var delegate: OfferCellDelegate?
	
	//Creates PageVC in order to interact with it (not yet used Dec 5)
	var Pager: PageVC!
	
	//Current offer of the cell
	var ThisOffer: Offer! {
		didSet {
			moneylabel.text = NumberToPrice(Value: ThisOffer.money)
			companylabel.text = ThisOffer.company.name
			postsLabel.text = ThisOffer.posts.count == 1 ? "For 1 post" : "For \(ThisOffer.posts.count) posts"
		}
	}
}



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
		//declare datasource & Delegates
		shelf.delegate = self
		shelf.dataSource = self
		global.delegates.append(self)
		
		//Debugging Fake Offers
		var fakeoffers : [Offer] = []
		for x : Double in [50, 1245, 28421, 812472, 12581238, 40, 240, 7029] {
			fakeoffers.append(Offer.init(money: 23, company: Company.init(name: "Pharoah Attire", logo: nil, mission: "Inspire confidence.", website: "https://pharaohattirestore.com", account_ID: "", instagram_name: "@pharaoh_attire", description: "Based out a New York, a company that creates shirts and apparel that inspires confidence."), posts: [Post.init(image: nil, instructions: "Post an image using a pharoah attire shirt", caption: nil, products: [Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: ""), Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: ""), Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: "")], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: Bool.random()), Post.init(image: nil, instructions: "Post an image to your story with a pharoah attire shirt and mention there is a sale.", caption: nil, products: [Product.init(image: nil, name: "Pharoah Attire Black T-Shirt", price: 20, buy_url: "https://pharaohattirestore.com/products/pharaoh-attire-t-shirt", color: "Black or Red", product_ID: "")], post_ID: "", PostType: .Story, confirmedSince: nil, isConfirmed: Bool.random())], offerdate: Date().addingTimeInterval(x * -1), offer_ID: "", expiredate: Date(timeIntervalSinceNow: x / 4), allPostsConfrimedSince: nil, isAccepted: Bool.random()))
		}
		global.AvaliableOffers = fakeoffers.filter({$0.isAccepted == false})
		global.AcceptedOffers = fakeoffers.filter({$0.isAccepted == true})
    }
}
