//
//  SocialFollowingVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 14/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class SocialFollowingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userList = [AnyObject]()
    @IBOutlet weak var followingTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
		followingTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
		
        if global.userList.count != 0 {
            self.userList = global.userList
            DispatchQueue.main.async {
                self.followingTable.reloadData()
            }
        }
        else{
        getFollowingList { (status, usersList) in
            
            if status{
                
                self.userList = usersList
                global.userList.removeAll()
                global.userList = usersList
                DispatchQueue.main.async {
                    self.followingTable.reloadData()
                }
                
            }
            
        }
    }
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if ((self.userList[indexPath.row] as? User) != nil){
            let identifier = "InfluencerResult"
            
            var cell = followingTable.dequeueReusableCell(withIdentifier: identifier) as? InfluencerTVC

            if cell == nil {
                let nib = Bundle.main.loadNibNamed("InfluencerTVC", owner: self, options: nil)
                cell = nib![0] as? InfluencerTVC
            }
            cell!.userData = (self.userList[indexPath.row] as! User)
            cell!.followBtn.tag = indexPath.row
            cell!.followBtn.addTarget(self, action: #selector(self.followUserAction(_:)), for: .touchUpInside)
            return cell!
        }else{
        
        let identifier = "BusinessResult"
        
        var cell = followingTable.dequeueReusableCell(withIdentifier: identifier) as? BusinessUserTVC

        if cell == nil {
            let nib = Bundle.main.loadNibNamed("BusinessUserTVC", owner: self, options: nil)
            cell = nib![0] as? BusinessUserTVC
        }
        cell!.businessDatail = (self.userList[indexPath.row] as! CompanyDetails)
        cell!.followBtn.tag = indexPath.row
        cell!.followBtn.addTarget(self, action: #selector(self.followBusinessAction(_:)), for: .touchUpInside)
        return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        let user = self.userList[indexPath.row]
        
        if ((user as? User) != nil){
        return 80.0
        }else{
        return 150.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let ThisUser = self.userList[indexPath.row] as? User{
            self.performSegue(withIdentifier: "FromSocialFollowing", sender: ThisUser)
        }
		tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func followUserAction(_ sender: UIButton){
        
        let ThisUser = self.userList[sender.tag] as! User

        if (Yourself.following?.contains(ThisUser.id))!{

            sender.setTitle("Follow", for: .normal)
            var followingList = Yourself.following
            if let i = followingList?.firstIndex(of: ThisUser.id){
                followingList?.remove(at: i)
                Yourself.following = followingList
                updateFollowingList(userID: ThisUser.id, ownUserID: Yourself)
                removeFollowingFollowerUser(user: ThisUser)
                self.userList.remove(at: sender.tag)
                self.followingTable.reloadData()
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
    
    @IBAction func followBusinessAction(_ sender: UIButton){
        
        let ThisUser = self.userList[sender.tag] as! CompanyDetails

        if (Yourself.businessFollowing?.contains(ThisUser.userId!))!{

            sender.setTitle("Follow", for: .normal)
            var followingList = Yourself.businessFollowing
            if let i = followingList?.firstIndex(of: ThisUser.userId!){
                followingList?.remove(at: i)
                Yourself.businessFollowing = followingList
                updateBusinessFollowingList(company: ThisUser, userID: ThisUser.userId!, ownUserID: Yourself)
                removeFollowingFollowerBusinessUser(user: ThisUser)
                self.userList.remove(at: sender.tag)
                self.followingTable.reloadData()
            }
        }else{
            sender.setTitle("Unfollow", for: .normal)
            var followingList = Yourself.businessFollowing
            followingList?.append(ThisUser.userId!)
            Yourself.businessFollowing = followingList
            updateBusinessFollowingList(company: ThisUser, userID: ThisUser.userId!, ownUserID: Yourself)
            updateFollowingFollowerBusinessUser(user: ThisUser, identifier: "business")
        }

    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FromSocialFollowing"{
            let view = segue.destination as! ViewProfileVC
            view.ThisUser = (sender as! User)
        }
    }
    

}
