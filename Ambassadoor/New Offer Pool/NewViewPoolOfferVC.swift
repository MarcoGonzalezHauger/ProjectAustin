//
//  NewViewPoolOffer.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/1/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class PostTVC: UITableViewCell {
	@IBOutlet weak var postLabel: UILabel!
	@IBOutlet weak var amountForPostLabel: UILabel!
}

class NewViewPoolOfferVC: UIViewController, UITableViewDelegate, UITableViewDataSource, OfferPoolRefreshDelegate {
	
	func OfferPoolRefreshed(poolId: String) {
		if poolId == thisPoolOffer.poolId {
			thisPoolOffer = offerPool.filter{$0.poolId == thisPoolOffer.poolId}.first
			updatePoolOffer()
		}
	}
	
	var heightForPostCell: CGFloat = 60
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableViewHeight.constant = CGFloat(thisPoolOffer.draftPosts.count) * heightForPostCell - 1
		return thisPoolOffer.draftPosts.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return heightForPostCell
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostTVC
		cell.postLabel.text = "Post \(indexPath.row + 1)"
		cell.amountForPostLabel.text = NumberToPrice(Value: thisPoolOffer.pricePerPost(forInfluencer: Myself.basic), enforceCents: true)
		return cell
	}
	
	@IBAction func closeButtonPressed(_ sender: Any) {
		self.navigationController?.dismiss(animated: true, completion: nil)
	}
    
    @IBAction func openMapView(sender: UIButton){
        self.performSegue(withIdentifier: "fromDrafttoMap", sender: self)
    }
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var backImage: UIImageView!
	@IBOutlet weak var foreImage: UIImageView!
	
	@IBOutlet weak var offerByLabel: UILabel!
	@IBOutlet weak var totalForLabel: UILabel!
	@IBOutlet weak var totalMoneyLabel: UILabel!
	@IBOutlet weak var totalMoneyView: ShadowView!
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var tableViewHeight: NSLayoutConstraint!
	
	@IBOutlet weak var acceptButton: UIButton!
	@IBOutlet weak var acceptView: ShadowView!
	@IBOutlet weak var acceptActivityIndicator: UIActivityIndicatorView!
	
	@IBOutlet weak var cannotBeAcceptedView: ShadowView!
	@IBOutlet weak var cannotReasonLabel: UILabel!
	
	@IBAction func acceptButtonPressed(_ sender: Any) {
		if thisPoolOffer.canBeAccepted(forInfluencer: Myself) {
			acceptActivityIndicator.isHidden = false
			acceptButton.isHidden = true
			thisPoolOffer.acceptThisOffer(asInfluencer: Myself) { (err) in
				self.acceptActivityIndicator.isHidden = true
				if err == "" {
					//success
                    self.dismiss(animated: true, completion: nil)
				} else {
					MakeShake(viewToShake: self.acceptView)
					self.showStandardAlertDialog(title: "Offer Couldn't be Accpeted", msg: err, handler: .none)
				}
				self.updatePoolOffer()
			}
		} else {
			MakeShake(viewToShake: acceptView)
			updatePoolOffer()
		}
	}
	
	var thisPoolOffer: PoolOffer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		offerPoolListeners.append(self)
		updatePoolOffer()
		scrollView.alwaysBounceVertical = false
		
		tableView.delegate = self
		tableView.dataSource = self
    }
	
	var passIndex = 0
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? NewPoolOfferPostViewer {
			view.index = passIndex
			view.thisPoolOffer = thisPoolOffer
		}
        if let view = segue.destination as? NewBasicBusinessView {
            view.displayBasicId(basicId: sender as! String)
        }
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		passIndex = indexPath.row
		performSegue(withIdentifier: "toPostView", sender: self)
	}
    
    @IBAction func tapBusinessProfile(sender: UITapGestureRecognizer){
        if let bb = thisPoolOffer.BasicBusiness() {
            self.performSegue(withIdentifier: "fromOffertoBusinessView", sender: bb.basicId)
        }
    }
	
	func updatePoolOffer() {
		if let bb = thisPoolOffer.BasicBusiness() {
			offerByLabel.text = "Offer by \(bb.name)"
			backImage.downloadAndSetImage(bb.logoUrl)
			foreImage.downloadAndSetImage(bb.logoUrl)
		} else {
			offerByLabel.text = "[Couldn't find business name.]"
		}
		
		totalMoneyLabel.text = NumberToPrice(Value: thisPoolOffer.totalCost(forInfluencer: Myself.basic), enforceCents: true)
		
		
		acceptView.isHidden = !thisPoolOffer.canBeAccepted(forInfluencer: Myself)
		cannotBeAcceptedView.isHidden = thisPoolOffer.canBeAccepted(forInfluencer: Myself)
		
		if !thisPoolOffer.canBeAccepted(forInfluencer: Myself) {
			var listOfReasons: [String] = []
			if thisPoolOffer.hasInfluencerAccepted(influencer: Myself) {
				listOfReasons.append("You already accepted this Offer.")
			} else {
				if !thisPoolOffer.canAffordInflunecer(forInfluencer: Myself.basic) {
					listOfReasons.append("Not enough money left in this Offer for you.")
				}
				if !thisPoolOffer.filter.DoesInfluencerPassFilter(basicInfluencer: Myself.basic) {
					listOfReasons.append("You don't meet the requirements set by the Business.")
				}
			}
			if listOfReasons.count > 1 {
				var newList: [String] = []
				for l in listOfReasons  {
					newList.append(" - " + l)
				}
				cannotReasonLabel.text = newList.joined(separator: "\n")
			} else {
				if listOfReasons.count == 1 {
					cannotReasonLabel.text = listOfReasons.first
				} else {
					cannotReasonLabel.text = ""
				}
			}
		}
		
		if !thisPoolOffer.canAffordInflunecer(forInfluencer: Myself.basic) {
			totalForLabel.text = "Not enough money in offer."
			totalMoneyView.backgroundColor = .systemRed
		} else {
			totalMoneyView.backgroundColor = .systemGreen
			if thisPoolOffer.draftPosts.count == 1 {
				totalForLabel.text = "Total for one Instagram Post"
			} else {
				totalForLabel.text = "Total for \(thisPoolOffer.draftPosts.count) Instagram Posts"
			}
		}
		tableView.reloadData()
	}

}
