//
//  BusinessVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class BusinessUserTVC: UITableViewCell, FollowerButtonDelegete {
	
	func isFollowingChanged(sender: AnyObject, newValue: Bool) {
		
		if let ThisUser = businessDatail {
			if !newValue {
				//UNFOLLOWING
				var followingList = Yourself.businessFollowing
				if let i = followingList?.firstIndex(of: ThisUser.userId!){
					followingList?.remove(at: i)
					Yourself.businessFollowing = followingList
					updateBusinessFollowingList(company: ThisUser, userID: ThisUser.userId!, ownUserID: Yourself)
					removeFollowingFollowerBusinessUser(user: ThisUser)
					
				}
			}else{
				//FOLLOWING
				var followingList = Yourself.businessFollowing ?? []
				if !followingList.contains(ThisUser.userId!) {
					followingList.append(ThisUser.userId!)
				}
				Yourself.businessFollowing = followingList
				updateBusinessFollowingList(company: ThisUser, userID: ThisUser.userId!, ownUserID: Yourself)
				updateFollowingFollowerBusinessUser(user: ThisUser, identifier: "business")
			}
		}
	}
	
    @IBOutlet weak var businessLogo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mission: UILabel!
	@IBOutlet weak var BusinessButton: FollowButtonSmall!
	
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
                
				BusinessButton.isFollowing = (Yourself.businessFollowing?.contains(business.userId!))!
				BusinessButton.isBusiness = true
				BusinessButton.delegate = self
                
            }
        }
    }
}

class BusinessVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchBarDelegate, followUpdateDelegate {
	
	func followingUpdated() {
		businessUserTable.reloadData()
	}
	
    func SearchTextIndex(text: String, segmentIndex: Int) {
        self.GetSearchedBusinessItems(query: text) { (businessusers) in
            self.businessTempArray = businessusers
            DispatchQueue.main.async {
                self.businessUserTable.reloadData()
				if businessusers.count != 0 {
					self.businessUserTable.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: false)
				}
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
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let business = self.businessTempArray[indexPath.row]
        self.performSegue(withIdentifier: "FromBusinessSearchToBV", sender: business)
		businessUserTable.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 150.0
    }
    
    func GetSearchedBusinessItems(query: String?, completed: @escaping (_ Results: [CompanyDetails]) -> ()) {
		//let predicate = NSPredicate(format: "SELF.username contains[c] %@", searchBar.text!)
		
		if query == "" {
			completed(global.BusinessUser)
			return
		}
		
		var strengthDic: [CompanyDetails:Int] = [:]
		var allowed: [CompanyDetails] = []
		
		if let query = query?.lowercased() {
			for co in global.BusinessUser {
				if co.name.lowercased().starts(with: query) {
					allowed.append(co)
					strengthDic[co] = 100
				} else if co.name.contains(query) {
					allowed.append(co)
					strengthDic[co] = 90
				}
			}
		}
		
		allowed.sort { (co1, co2) -> Bool in
			if strengthDic[co1] == strengthDic[co2] {
				return co1.name > co2.name
			} else {
				return strengthDic[co1] ?? 0 > strengthDic[co2] ?? 0
			}
		}
		
		completed(allowed)
	}
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FromBusinessSearchToBV"{
            let view = segue.destination as! ViewBusinessVC
            view.fromSearch = true
            view.businessDatail = (sender as! CompanyDetails)
            view.getFollowing(businessData: (sender as! CompanyDetails))
			view.delegate = self
        }
    }
    

}
