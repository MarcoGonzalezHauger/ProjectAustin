//
//  NewBasicBusinessView.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/31/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewBasicBusinessView: UIViewController, UITableViewDelegate, UITableViewDataSource, FollowerButtonDelegete, publicDataRefreshDelegate, OfferPoolRefreshDelegate {
	
	func OfferPoolRefreshed(poolId: String) {
		for ao in avaliableOffers {
			if ao.poolId == poolId {
				refreshAvaliableOffers()
				return
			}
		}
	}
	
	func publicDataRefreshed(userOrBusinessId: String) {
		if userOrBusinessId == thisBusiness.basicId {
			thisBusiness = GetBasicBusiness(id: userOrBusinessId)
			LoadBasicBusinessInfo(refreshIsFollowing: false)
		}
	}
	
	func isFollowingChanged(sender: AnyObject, newValue: Bool) {
		
		if newValue {
			thisBusiness.Follow(as: Myself)
		} else {
			thisBusiness.Unfollow(as: Myself)
		}
		
		refreshAvaliableOffers()
	}
	
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
    
    @IBOutlet weak var website: UIButton!
    @IBOutlet weak var websiteImg: UIButton!
	
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

	@IBAction func closeButtonClicked(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
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
        
        if thisBusiness.website != nil && thisBusiness.website != "" {
            websiteImg.isHidden = false
            self.website.setTitle(thisBusiness.website, for: .normal)
        }else{
            websiteImg.isHidden = true
            self.website.setTitle("", for: .normal)
        }
        
		
		refreshAvaliableOffers()
		
	}
	
	var avaliableOffers: [PoolOffer] = []
	
	func refreshAvaliableOffers() {
		avaliableOffers = thisBusiness.GetAvaliableOffersFromBusiness()
		let noOffers = thisBusiness.avaliableOffers.count == 0
		tableView.isHidden = noOffers
		noAvaliableOffersView.isHidden = !noOffers
		
		tableView.reloadData()
		
	}
    
    @IBAction func openWebsite(button: UIButton){
        if let basic = thisBusiness{
            let sharedApps = UIApplication.shared
            if let url = URL.init(string: basic.website){
                if sharedApps.canOpenURL(url) {
                sharedApps.open(url)
                }
            }
            
        }
    }
	
}
