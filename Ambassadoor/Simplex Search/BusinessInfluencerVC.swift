//
//  BusinessInfluencerVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit



class BusinessInfluencerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchBarDelegate {
    func SearchTextIndex(text: String, segmentIndex: Int) {
        
        self.GetSearchedTotalItems(query: text) { (users) in
            self.totalUserTempData = users
            DispatchQueue.main.async {
                self.UserTable.reloadData()
            }
        }
        
    }
    
    
    @IBOutlet weak var UserTable: UITableView!
    
    var totalUserData = [AnyObject]()
    var totalUserTempData = [AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        UserTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        SearchMenuVC.searchDelegate = self
        self.totalUserData.removeAll()
        self.totalUserTempData.removeAll()
        if global.SocialData.count != 0 {
            if global.BusinessUser.count != 0 {
                
                self.totalUserData.append(contentsOf: global.BusinessUser)
                self.totalUserData.append(contentsOf: global.SocialData)
                self.totalUserData.shuffle()
                self.totalUserTempData = self.totalUserData
                DispatchQueue.main.async {
                    self.UserTable.reloadData()
                }
            }else{
                
                _ = GetAllUsers(completion: { (users) in
                    global.SocialData = users
                    
                    self.totalUserData.append(contentsOf: global.BusinessUser)
                    self.totalUserData.append(contentsOf: global.SocialData)
                    self.totalUserData.shuffle()
                    self.totalUserTempData = self.totalUserData
                    DispatchQueue.main.async {
                        self.UserTable.reloadData()
                    }
                    
                })
                
            }
        }else{
            
            _ = GetAllBusiness(completion: { (business) in
                
                global.BusinessUser = business
                
                _ = GetAllUsers(completion: { (users) in
                    global.SocialData = users
                    
                    self.totalUserData.append(contentsOf: global.BusinessUser)
                    self.totalUserData.append(contentsOf: global.SocialData)
                    self.totalUserData.shuffle()
                    self.totalUserTempData = self.totalUserData
                    DispatchQueue.main.async {
                        self.UserTable.reloadData()
                    }
                    
                    
                })
                
            })
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalUserTempData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if ((self.totalUserTempData[indexPath.row] as? User) != nil){
            let identifier = "InfluencerResult"
            
            var cell = UserTable.dequeueReusableCell(withIdentifier: identifier) as? InfluencerTVC

            if cell == nil {
                let nib = Bundle.main.loadNibNamed("InfluencerTVC", owner: self, options: nil)
                cell = nib![0] as? InfluencerTVC
            }
            cell!.userData = (self.totalUserTempData[indexPath.row] as! User)
            cell!.followBtn.tag = indexPath.row
            cell!.followBtn.addTarget(self, action: #selector(self.followUserAction(_:)), for: .touchUpInside)
            return cell!
        }else{
        
        let identifier = "BusinessResult"
        
        var cell = UserTable.dequeueReusableCell(withIdentifier: identifier) as? BusinessUserTVC

        if cell == nil {
            let nib = Bundle.main.loadNibNamed("BusinessUserTVC", owner: self, options: nil)
            cell = nib![0] as? BusinessUserTVC
        }
        cell!.businessDatail = (self.totalUserTempData[indexPath.row] as! CompanyDetails)
        cell!.followBtn.tag = indexPath.row
        cell!.followBtn.addTarget(self, action: #selector(self.followBusinessAction(_:)), for: .touchUpInside)
        return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        let user = self.totalUserTempData[indexPath.row]
        
        if ((user as? User) != nil){
        return 80.0
        }else{
        return 150.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let user = self.totalUserTempData[indexPath.row]
        
        if ((user as? User) != nil){
            
            self.performSegue(withIdentifier: "FromBusinessInfluencer", sender: user)
            UserTable.deselectRow(at: indexPath, animated: true)
        }else{
            
        }
        
    }
    
    func GetSearchedTotalItems(query: String?, completed: @escaping (_ Results: [AnyObject]) -> ()) {
            //let predicate = NSPredicate(format: "SELF.username contains[c] %@", searchBar.text!)
        let userSearchedList = self.totalUserData.filter { (user) -> Bool in
            
            if let inflencer = user as? User{
                return inflencer.name!.lowercased().hasPrefix(query!.lowercased())
            }else{
                let businessUser = user as! CompanyDetails
                return businessUser.name.lowercased().hasPrefix(query!.lowercased())
            }
            
        
    }
        completed(userSearchedList)
        
    }
    
    @IBAction func followUserAction(_ sender: UIButton){
        
        let ThisUser = self.totalUserTempData[sender.tag] as! User

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
    
    @IBAction func followBusinessAction(_ sender: UIButton){
        
        let ThisUser = self.totalUserTempData[sender.tag] as! CompanyDetails

        if (Yourself.businessFollowing?.contains(ThisUser.userId!))!{

            sender.setTitle("Follow", for: .normal)
            var followingList = Yourself.businessFollowing
            if let i = followingList?.firstIndex(of: ThisUser.userId!){
                followingList?.remove(at: i)
                Yourself.businessFollowing = followingList
                updateBusinessFollowingList(company: ThisUser, userID: ThisUser.userId!, ownUserID: Yourself)
                removeFollowingFollowerBusinessUser(user: ThisUser)
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
    
    //FromBusinessInfluencer
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FromBusinessInfluencer"{
            let view = segue.destination as! ViewProfileVC
            view.ThisUser = (sender as! User)
        }
    }
    

}
