//
//  RejectedOffersVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/23/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class RejectedOffersVC: UIViewController, UITableViewDataSource, UITableViewDelegate, OfferCellDelegate, GlobalListener {
	
	var isQue: Bool = false
	
	func isQueued(isQue: Bool) {
		self.isQue = isQue
	}
	
	func RejectedOffersChanged() {
		if isQue == false {
			shelf.reloadData()
		}
	}
	
	@IBOutlet weak var backBtn: UIButton!
	
	func OfferRejected(sender: Any) {
	}
	
	@IBAction func back(_ sender: Any) {
		Pager.goToPage(index: 1, sender: self)
	}
	
	var Pager: PageVC!
	
	func ViewOffer(sender: Any) {
		//Actually the put back function in this case.
		if let ip : IndexPath = shelf.indexPath(for: sender as! UITableViewCell) {
			global.AvaliableOffers.append(global.RejectedOffers[ip.row])
			global.RejectedOffers.remove(at: ip.row)
			shelf.deleteRows(at: [ip], with: .right)
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return global.RejectedOffers.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return 120
		}
		return 110
	}
	
	@IBOutlet weak var shelf: UITableView!
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = shelf.dequeueReusableCell(withIdentifier: "HomeOfferCell")  as! OfferCell
		cell.delegate = self
		cell.ThisOffer = global.RejectedOffers[indexPath.row]
		return cell
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		shelf.delegate = self
		shelf.dataSource = self
		global.delegates.append(self)
		backBtn.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
	}

}
