//
//  NewBasicBusinessView.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/31/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewBasicBusinessView: UIViewController, UITableViewDelegate, UITableViewDataSource, FollowerButtonDelegete, publicDataRefreshDelegate, OfferPoolRefreshDelegate {
    
    /// OfferPoolRefreshDelegate delegate method. refresh offer pool data if any changes updated in firebase
    	func OfferPoolRefreshed(poolId: String) {
		for ao in avaliableOffers {
			if ao.poolId == poolId {
				refreshAvaliableOffers()
				return
			}
		}
	}
	
    
    /// Refreshed social data if any child added or edited in firebase
    /// - Parameter userOrBusinessId: edited or changed influencer id or business id
	func publicDataRefreshed(userOrBusinessId: String) {
		if userOrBusinessId == thisBusiness.basicId {
			thisBusiness = GetBasicBusiness(id: userOrBusinessId)
			LoadBasicBusinessInfo(refreshIsFollowing: false)
		}
	}
    
    /// FollowerButtonDelegete delegate method. give status of influencer follow and unfollow. refresh available offers.
    /// - Parameters:
    ///   - sender: Class referrance
    ///   - newValue: follow or unfollow bool value
	func isFollowingChanged(sender: AnyObject, newValue: Bool) {
		
		if newValue {
			thisBusiness.Follow(as: Myself)
		} else {
			thisBusiness.Unfollow(as: Myself)
		}
		
		refreshAvaliableOffers()
	}
//	MARK: offers list table delegate and datasource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		tableViewHeight.constant = CGFloat(avaliableOffers.count) * globalPoolOfferHeight
		tableView.layoutIfNeeded()
		return avaliableOffers.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return globalPoolOfferHeight
	}
	
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let thisOffer = avaliableOffers[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "PoolOffer") as! PoolOfferTVC
		cell.poolOffer = thisOffer
		cell.updateContents(expectedWidth: tableView.bounds.width)
		return cell
	}
	
	var thisBusiness: BasicBusiness!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var avaliableOffersLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var tableViewHeight: NSLayoutConstraint!
	
	@IBOutlet weak var backImage: UIImageView!
	@IBOutlet weak var regProfilePic: UIImageView!
	@IBOutlet weak var businessName: UILabel!
	@IBOutlet weak var businessMission: UILabel!
	
	@IBOutlet weak var regFollowButton: FollowButtonRegular!
	@IBOutlet weak var noAvaliableOffersView: ShadowView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		regFollowButton.delegate = self
		regFollowButton.isBusiness = false
		tableView.delegate = self
		tableView.dataSource = self
		
		offerPoolListeners.append(self)
		
		publicDataListeners.append(self)
		
		let xib = UINib.init(nibName: "PoolOfferTVC", bundle: Bundle.main)
		tableView.register(xib, forCellReuseIdentifier: "PoolOffer")
		
		LoadBasicBusinessInfo(refreshIsFollowing: true)
    }
	
	func displayBasicId(basicId: String) {
		thisBusiness = GetBasicBusiness(id: basicId)
	}
    
    /// Dismiss current view controller
    /// - Parameter sender: UIButton referrance
	@IBAction func closeButtonClicked(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
    
    /// Load basic business information.
    /// - Parameter rif: refresh true or false
	func LoadBasicBusinessInfo(refreshIsFollowing rif: Bool) {
		backImage.image = nil
		regProfilePic.image = nil
		downloadImage(thisBusiness.logoUrl) { (img) in
			self.backImage.image = img
			self.regProfilePic.image = img
		}
		businessName.text = thisBusiness.name
		if rif {
			regFollowButton.isFollowing = thisBusiness.isFollowing(as: Myself)
		}
		
		businessMission.text = thisBusiness.mission
		
		refreshAvaliableOffers()
		
	}
	
	var avaliableOffers: [PoolOffer] = []
    
    /// Refresh available offers.
	func refreshAvaliableOffers() {
		avaliableOffers = thisBusiness.GetAvaliableOffersFromBusiness()
		let noOffers = thisBusiness.avaliableOffers.count == 0
		tableView.isHidden = noOffers
		noAvaliableOffersView.isHidden = !noOffers
		
		tableView.reloadData()
		
	}
	
}
