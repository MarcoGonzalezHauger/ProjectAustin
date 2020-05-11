//
//  InfluencerListVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol followUpdateDelegate {
	func followingUpdated()
}

class InfluencerTVC: UITableViewCell, FollowerButtonDelegete {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tier: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var verifyLogo_img: UIImageView!
	@IBOutlet weak var tierBox: ShadowView!
	@IBOutlet weak var followButton: FollowButtonSmall!
	
    @IBOutlet weak var leadingUserName: NSLayoutConstraint!
	
	func isFollowingChanged(sender: AnyObject, newValue: Bool) {
		if let ThisUser = userData {
			if newValue {
				//FOLLOW
				var followingList = Yourself.following
				if !followingList!.contains(ThisUser.id) {
					followingList?.append(ThisUser.id)
				}
				Yourself.following = followingList
				updateFollowingList(userID: ThisUser.id, ownUserID: Yourself)
				updateFollowingFollowerUser(user: ThisUser, identifier: "influencer")
			} else {
				//UNFOLLOW
				var followingList = Yourself.following
				if let i = followingList?.firstIndex(of: ThisUser.id){
					followingList?.remove(at: i)
					Yourself.following = followingList
					updateFollowingList(userID: ThisUser.id, ownUserID: Yourself)
					removeFollowingFollowerUser(user: ThisUser)
					
				}
			}
		}
	}
	
    var userData: User?{
        didSet{
            if let user = userData{
                tierBox.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "tiergrad")!)
                if let picurl = user.profilePicURL {
                    self.userImage.downloadAndSetImage(picurl)
                } else {
                    self.userImage.UseDefaultImage()
                }
                
                //self.userName.text = "@\(user.username)"
				self.userName.text = user.name
                
                self.tier.text = String(GetTierForInfluencer(influencer: user))
                
				followButton.isFollowing = (Yourself.following?.contains(user.id))!
				followButton.isBusiness = false
				followButton.delegate = self
                
                self.followerCount.text = CompressNumber(number: Double(user.followerCount))
                self.likeCount.text = CompressNumber(number: Double(user.averageLikes ?? 0))
                
                if user.isDefaultOfferVerify {
                    verifyLogo_img.image = UIImage(named: "verify_Logo")
                    self.leadingUserName.constant = 34
                    self.updateConstraints()
                    self.layoutIfNeeded()
                } else {
                    verifyLogo_img.image = nil
                    self.leadingUserName.constant = 8
                    self.updateConstraints()
                    self.layoutIfNeeded()
                }
                
                if blackIcons.contains(user.username) {
                      verifyLogo_img.image = UIImage.init(named: "verified_black")
                    self.leadingUserName.constant = 34
                    self.updateConstraints()
                    self.layoutIfNeeded()
                }
                
            }
        }
    }
    
    
}

class InfluencerListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchBarDelegate, followUpdateDelegate {
	
	func followingUpdated() {
		influencerTable.reloadRows(at: [IndexPath.init(row: activeView!, section: 0)], with: .none)
	}
		
    func SearchTextIndex(text: String, segmentIndex: Int) {
        self.GetSearchedInfluencerItems(query: text) { (users) in
            self.influencerTempArray = users
            DispatchQueue.main.async {
                self.influencerTable.reloadData()
				if users.count != 0 {
					self.influencerTable.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: false)
				}
            }
        }
        
    }
    
	var activeView: Int?
    @IBOutlet weak var influencerTable: UITableView!
    
    var influencerTempArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        influencerTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        // Do any additional setup after loading the view.
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.influencerTempArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "InfluencerResult"
        
        var cell = influencerTable.dequeueReusableCell(withIdentifier: identifier) as? InfluencerTVC

        if cell == nil {
            let nib = Bundle.main.loadNibNamed("InfluencerTVC", owner: self, options: nil)
            cell = nib![0] as? InfluencerTVC
        }
        cell!.userData = self.influencerTempArray[indexPath.row]
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let user = self.influencerTempArray[indexPath.row]
        self.performSegue(withIdentifier: "FromInfluencerList", sender: user)
		activeView = indexPath.row
        influencerTable.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        SearchMenuVC.searchDelegate = self
        if global.SocialData.count == 0{
        _ = GetAllUsers(completion: { (users) in
            global.SocialData = users
            self.influencerTempArray = users
            DispatchQueue.main.async {
                self.influencerTable.reloadData()
            }
            
            
        })
        }else{
            self.influencerTempArray = global.SocialData
            DispatchQueue.main.async {
                self.influencerTable.reloadData()
            }
        }
    }
	
	
	
    func GetSearchedInfluencerItems(query: String?, completed: @escaping (_ Results: [User]) -> ()) {
        guard let query = query else { return }
        var metusers: [User] = []
        var strengthdict: [User: Int] = [:]
        for x : User in global.SocialData {
            var isDone = false
            if let urname = x.name {
                if urname.lowercased().hasPrefix(query.lowercased()) {
                    metusers.append(x)
                    strengthdict[x] = 100
                    isDone = true
                } else if urname.lowercased().contains(query.lowercased()) {
                    metusers.append(x)
                    strengthdict[x] = 80
                    isDone = true
                }
            }
            if isDone == false {
                if x.username.lowercased().hasPrefix(query.lowercased()) {
                    metusers.append(x)
                    strengthdict[x] = 90
                } else if x.username.lowercased().contains(query.lowercased()) {
                    metusers.append(x)
                    strengthdict[x] = 70
                }
            }
        }
        metusers.sort { (User1, User2) -> Bool in
            if strengthdict[User1]! == strengthdict[User2]! {
                return User1.followerCount > User2.followerCount
            } else {
                return strengthdict[User1]! > strengthdict[User2]!
            }
        }
        completed(metusers)
    }
    
//FromInfluencerList
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "FromInfluencerList"{
            let view = segue.destination as! ViewProfileVC
            view.ThisUser = (sender as! User)
			view.delegate = self
        }
    }
    

}
