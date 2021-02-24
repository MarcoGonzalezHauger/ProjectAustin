//
//  NewSocialMenuVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 16/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewSocialMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource, myselfRefreshDelegate, publicDataRefreshDelegate {
    func myselfRefreshed() {
        if GetSocialScope() == .following{
           refreshItems()
        }
    }
    
    func publicDataRefreshed(userOrBusinessId: String) {
        refreshItems()
    }
    
    @IBOutlet weak var socialTable: UITableView!
    
    @IBOutlet weak var socialSegemnt: UISegmentedControl!
    
    @IBOutlet weak var noneFollowers: ShadowView!
    
    @IBOutlet weak var errorText: UILabel!
    
    var followingUsers = [Any]()
    
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
    
    @IBAction func refreshData(_sender: Any){
        self.refreshItems()
    }
    
    func refreshItems() {
        self.followingUsers.removeAll()
        if GetSocialScope() == .following {
            self.followingUsers = SocialFollowingUsers(influencer: Myself)
        }else{
            self.followingUsers = SocialFollowedByUsers(influencer: Myself)
            
        }
        self.noneCheck(array: self.followingUsers)
        self.socialTable.reloadData()
    }
    
    func noneCheck(array: [Any]) {
        DispatchQueue.main.async {
            print("glimse=",array.count)
            self.noneFollowers.isHidden = array.count == 0 ? false : true
            self.errorText.text = self.GetSocialScope() == .following ? "No Following Users" : "No FollowedBy Users"
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followingUsers.count
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
