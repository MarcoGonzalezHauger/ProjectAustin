//
//  BusinessVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class BusinessUserTVC: UITableViewCell {
    @IBOutlet weak var businessLogo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mission: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    var businessDatail: CompanyDetails? {
        didSet{
            if let business = businessDatail{
                
                if let picurl = business.logo {
                    self.businessLogo.downloadAndSetImage(picurl)
                } else {
                    self.businessLogo.UseDefaultImage()
                }
                
                self.name.text = business.name
                self.mission.text = business.mission
                
                if (Yourself.businessFollowing?.contains(business.userId!))!{
                    
                    self.followBtn.setTitle("Unfollow", for: .normal)
                    
                }else{
                    
                    self.followBtn.setTitle("Follow", for: .normal)
                    
                }
                
            }
        }
    }
}

class BusinessVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchBarDelegate {
    func SearchTextIndex(text: String, segmentIndex: Int) {
        
        self.GetSearchedBusinessItems(query: text) { (businessusers) in
            self.businessTempArray = businessusers
            DispatchQueue.main.async {
                self.businessUserTable.reloadData()
            }
        }
        
    }
    
    @IBOutlet weak var businessUserTable: UITableView!
    
    var businessTempArray = [CompanyDetails]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        businessUserTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        SearchMenuVC.searchDelegate = self
        if global.BusinessUser.count == 0 {
        _ = GetAllBusiness(completion: { (business) in
            
            global.BusinessUser = business
            self.businessTempArray = business
            DispatchQueue.main.async {
                self.businessUserTable.reloadData()
            }
            
            
        })
        }else{
            self.businessTempArray = global.BusinessUser
            DispatchQueue.main.async {
                self.businessUserTable.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businessTempArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "BusinessResult"
        
        var cell = businessUserTable.dequeueReusableCell(withIdentifier: identifier) as? BusinessUserTVC

        if cell == nil {
            let nib = Bundle.main.loadNibNamed("BusinessUserTVC", owner: self, options: nil)
            cell = nib![0] as? BusinessUserTVC
        }
        cell!.businessDatail = self.businessTempArray[indexPath.row]
        cell!.followBtn.tag = indexPath.row
        cell!.followBtn.addTarget(self, action: #selector(self.followBusinessAction(_:)), for: .touchUpInside)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 150.0
    }
    
    func GetSearchedBusinessItems(query: String?, completed: @escaping (_ Results: [CompanyDetails]) -> ()) {
            //let predicate = NSPredicate(format: "SELF.username contains[c] %@", searchBar.text!)
            let userSearchedList = global.BusinessUser.filter { (businessuser) -> Bool in
                return businessuser.name.lowercased().hasPrefix(query!.lowercased())
            }
            completed(userSearchedList)
    }

    @IBAction func followBusinessAction(_ sender: UIButton){
        
        let ThisUser = self.businessTempArray[sender.tag]

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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
