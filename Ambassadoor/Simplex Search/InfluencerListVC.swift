//
//  InfluencerListVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class InfluencerTVC: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tier: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var verifyLogo_img: UIImageView!
    
    @IBOutlet weak var leadingUserName: NSLayoutConstraint!
    var userData: User?{
        didSet{
            if let user = userData{
                
                if let picurl = user.profilePicURL {
                    self.userImage.downloadAndSetImage(picurl)
                } else {
                    self.userImage.UseDefaultImage()
                }
                
                //self.userName.text = "@\(user.username)"
				self.userName.text = user.name
                
                self.tier.text = String(GetTierForInfluencer(influencer: user))
                
                if (Yourself.following?.contains(user.id))!{
                    self.followBtn.setTitle("Unfollow", for: .normal)
                }else{
                    
                    self.followBtn.setTitle("Follow", for: .normal)
                    
                }
                
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

class InfluencerListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchBarDelegate {
    func SearchTextIndex(text: String, segmentIndex: Int) {
        
        self.GetSearchedInfluencerItems(query: text) { (users) in
            self.influencerTempArray = users
            DispatchQueue.main.async {
                self.influencrTable.reloadData()
            }
        }
        
    }
    
    
    @IBOutlet weak var influencrTable: UITableView!
    
    var influencerTempArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.influencerTempArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "InfluencerResult"
        
        var cell = influencrTable.dequeueReusableCell(withIdentifier: identifier) as? InfluencerTVC

        if cell == nil {
            let nib = Bundle.main.loadNibNamed("InfluencerTVC", owner: self, options: nil)
            cell = nib![0] as? InfluencerTVC
        }
        cell!.userData = self.influencerTempArray[indexPath.row]
        cell!.followBtn.tag = indexPath.row
        cell!.followBtn.addTarget(self, action: #selector(self.followAction(_:)), for: .touchUpInside)
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let user = self.influencerTempArray[indexPath.row]
        self.performSegue(withIdentifier: "FromInfluencerList", sender: user)
        influencrTable.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func followAction(_ sender: UIButton){
        
        let ThisUser = self.influencerTempArray[sender.tag]

        if (Yourself.following?.contains(ThisUser.id))!{

            sender.setTitle("Follow", for: .normal)
            var followingList = Yourself.following
            if let i = followingList?.firstIndex(of: ThisUser.id){
                followingList?.remove(at: i)
                Yourself.following = followingList
                updateFollowingList(userID: ThisUser.id, ownUserID: Yourself)
                removeFollowingFollowerUser(user: ThisUser)
                
            }
        }else{
            sender.setTitle("Unfollow", for: .normal)
            var followingList = Yourself.following
            followingList?.append(ThisUser.id)
            Yourself.following = followingList
            updateFollowingList(userID: ThisUser.id, ownUserID: Yourself)
            updateFollowingFollowerUser(user: ThisUser, identifier: "influencer")
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        SearchMenuVC.searchDelegate = self
        if global.SocialData.count == 0{
        _ = GetAllUsers(completion: { (users) in
            global.SocialData = users
            self.influencerTempArray = users
            DispatchQueue.main.async {
                self.influencrTable.reloadData()
            }
            
            
        })
        }else{
            self.influencerTempArray = global.SocialData
            DispatchQueue.main.async {
                self.influencrTable.reloadData()
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
        }
    }
    

}
