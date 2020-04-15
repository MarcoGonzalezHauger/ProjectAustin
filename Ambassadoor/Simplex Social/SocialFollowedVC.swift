//
//  SocialFollowedVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 14/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class SocialFollowedVC: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var influencerList = [User]()
    @IBOutlet weak var followingTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getFollowedByList { (status, users) in
            
            if status{
                
                self.influencerList = users
                DispatchQueue.main.async {
                    self.followingTable.reloadData()
                }
                
            }
            
        }
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return self.influencerList.count
            
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let identifier = "InfluencerResult"
            
            var cell = followingTable.dequeueReusableCell(withIdentifier: identifier) as? InfluencerTVC

            if cell == nil {
                let nib = Bundle.main.loadNibNamed("InfluencerTVC", owner: self, options: nil)
                cell = nib![0] as? InfluencerTVC
            }
            cell!.userData = self.influencerList[indexPath.row]
            cell!.followBtn.tag = indexPath.row
            cell!.followBtn.addTarget(self, action: #selector(self.followAction(_:)), for: .touchUpInside)
            return cell!
            
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
            return 80.0
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
            let user = self.influencerList[indexPath.row]
            self.performSegue(withIdentifier: "FromSocialFollowed", sender: user)
   
        }
        
        @IBAction func followAction(_ sender: UIButton){
            
            let ThisUser = self.influencerList[sender.tag]

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FromSocialFollowed"{
            let view = segue.destination as! ViewProfileVC
            view.ThisUser = (sender as! User)
        }
    }
    

}
