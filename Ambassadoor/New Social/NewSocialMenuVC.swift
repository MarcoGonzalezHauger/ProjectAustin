//
//  NewSocialMenuVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 16/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewSocialMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource, myselfRefreshDelegate, publicDataRefreshDelegate {
    
    /// Refresh followedby data if login user did any modification by himself
    func myselfRefreshed() {
		if GetSocialScope() == .followedby {
			refreshItems()
		}
    }
    
    /// Refreshed social data if any child added or edited in firebase
    /// - Parameter userOrBusinessId: edited or changed influencer id or business id
    func publicDataRefreshed(userOrBusinessId: String) {
        refreshItems()
    }
    
    @IBOutlet weak var socialTable: UITableView!
    @IBOutlet weak var socialSegemnt: UISegmentedControl!
    @IBOutlet weak var noneFollowers: ShadowView!
    @IBOutlet weak var errorText: UILabel!
    
    
    
    var followingUsers = [Any]()
    
    /// Get Social Selected Tab
    /// - Returns: selected SocialTabFor enum
    func GetSocialScope() -> SocialTabFor {
        switch socialSegemnt.selectedSegmentIndex {
        case 0:
            return .following
        default:
            return .followedby
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        myselfRefreshListeners.append(self)
        publicDataListeners.append(self)
        self.socialTable.dataSource = self
        self.socialTable.delegate = self
        refreshItems()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func segmentIndexChanged(_sender: Any){
        self.refreshItems()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		refreshItems()
	}
    
    /// Refresh social users list based on social scope
    func refreshItems() {
        if GetSocialScope() == .following {
            self.followingUsers = SocialFollowingUsers(influencer: Myself)
        } else {
            self.followingUsers = SocialFollowedByUsers(influencer: Myself)
        }
        self.socialTable.reloadData()
    }
    
//    MARK: Follower and Following list UITableview delegate and datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		self.noneFollowers.isHidden = self.followingUsers.count != 0
  
		self.errorText.text = self.GetSocialScope() == .following ? "You aren't following anyone" : "Nobody follows you yet"
		
        return self.followingUsers.count
    }
	
	var passId: String = ""
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let item = followingUsers[indexPath.row]
		if let inf = item as? BasicInfluencer {
			passId = inf.userId
			performSegue(withIdentifier: "toInf", sender: self)
		} else if let bus = item as? BasicBusiness {
			passId = bus.basicId
			performSegue(withIdentifier: "toBus", sender: self)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? NewBasicInfluencerView {
			view.displayInfluencerId(userId: passId)
		}
		if let view = segue.destination as? NewBasicBusinessView {
			view.displayBasicId(basicId: passId)
		}
        
        if let view = segue.destination as? WebViewVC {
            
        }
	}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let businessNibID = "BasicBusinessCell"
        let influencerNibID = "BasicInfluencerCell"
        
        if let business = self.followingUsers[indexPath.row] as? BasicBusiness {
            
            
            var cell = tableView.dequeueReusableCell(withIdentifier: businessNibID) as? BasicBusinessCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed(businessNibID, owner: self, options: nil)!
                cell = nib[0] as? BasicBusinessCell
            }
            cell!.represents = business
            return cell!
            
            
        } else {
            let influencer = self.followingUsers[indexPath.row] as! BasicInfluencer
            
            
            var cell = tableView.dequeueReusableCell(withIdentifier: influencerNibID) as? BasicInfluenerCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed(influencerNibID, owner: self, options: nil)!
                cell = nib[0] as? BasicInfluenerCell
            }
            cell!.represents = influencer
            return cell!
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.followingUsers[indexPath.row] is BasicBusiness  {
            return 150
        } else {
            return 80
        }
    }
    
    

}
