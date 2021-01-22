//
//  BusinessInfluencerVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit



class BusinessInfluencerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchBarDelegate, followUpdateDelegate, EasyRefreshDelegate {
	
	func wantsReload(stopRefreshing: @escaping () -> Void) {
		
		DispatchQueue.main.async {
			self.UserTable.reloadData()
		}
		stopRefreshing()
	}
	
	
	func followingUpdated() {
		UserTable.reloadData()
	}
	
    func SearchTextIndex(text: String, segmentIndex: Int) {
        self.GetSearchedTotalItems(query: text) { (users) in
            self.totalUserTempData.removeAll()
            self.totalUserTempData = users
            DispatchQueue.main.async {
                self.UserTable.reloadData()
				if users.count != 0 {
					self.UserTable.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: false)
				}
            }
        }
        
    }
    
    
    @IBOutlet weak var UserTable: EasyRefreshTV!
    
    var totalUserData = [AnyObject]()
    var totalUserTempData = [AnyObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        UserTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
		UserTable.easyRefreshDelegate = self
		self.totalUserData = GetBothInOrder()
        self.totalUserTempData.removeAll()
        if global.SocialData.count != 0 {
            if global.BusinessUser.count != 0 {
                
                self.totalUserTempData = GetBothInOrder()
                DispatchQueue.main.async {
                    self.UserTable.reloadData()
                }
            }else{
                
                _ = GetAllUsers(completion: { (users) in
                    global.SocialData.removeAll()
                    global.SocialData = users
                    
                    self.totalUserTempData = GetBothInOrder()
                    DispatchQueue.main.async {
                        self.UserTable.reloadData()
                    }
                    
                })
                
            }
        }else{
            
            _ = GetAllBusiness(completion: { (business) in
                
                global.BusinessUser = business
                
                _ = GetAllUsers(completion: { (users) in
					self.totalUserData = GetBothInOrder()
                    self.totalUserTempData.removeAll()
                    global.SocialData = users
                    
                    self.totalUserTempData = GetBothInOrder()
					DispatchQueue.main.async {
                        self.UserTable.reloadData()
                    }
                    
                    
                })
                
            })
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadUserData), name: Notification.Name("reloadusers"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadUserData), name: Notification.Name("reloadbusinessusers"), object: nil)
        SearchMenuVC.searchDelegate = self

    }
    
    @objc func reloadUserData() {
        
        self.totalUserData = GetBothInOrder()
        self.totalUserTempData = GetBothInOrder()
        DispatchQueue.main.async {
            self.UserTable.reloadData()
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
			return cell!
        }else{
        
        let identifier = "BusinessResult"
        
        var cell = UserTable.dequeueReusableCell(withIdentifier: identifier) as? BusinessUserTVC

        if cell == nil {
            let nib = Bundle.main.loadNibNamed("BusinessUserTVC", owner: self, options: nil)
            cell = nib![0] as? BusinessUserTVC
        }
        cell!.businessDatail = (self.totalUserTempData[indexPath.row] as! CompanyDetails)
        return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        let user = self.totalUserTempData[indexPath.row]
        
        if ((user as? User) != nil) {
			return 80.0
        } else {
			return 150.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let user = self.totalUserTempData[indexPath.row]
        
        if ((user as? User) != nil) {
            
            self.performSegue(withIdentifier: "FromBusinessInfluencer", sender: user)
            UserTable.deselectRow(at: indexPath, animated: true)
        }else{
            self.performSegue(withIdentifier: "FromSearchToBV", sender: user)
            UserTable.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    func GetSearchedTotalItems(query: String?, completed: @escaping (_ Results: [AnyObject]) -> ()) {
		//let predicate = NSPredicate(format: "SELF.username contains[c] %@", searchBar.text!)
		
		//let predicate = NSPredicate(format: "SELF.username contains[c] %@", searchBar.text!)
		
		if query == "" {
			completed(totalUserData)
			return
		}
		
		var strengthDic: [String:Int] = [:]
		var allowed: [AnyObject] = []
		
		if let query = query?.lowercased() {
			for item in totalUserData {
				if let co = item as? CompanyDetails {
					if co.name.lowercased().starts(with: query) {
						allowed.append(co)
						strengthDic[co.account_ID ?? "business"] = 100
					} else if co.name.contains(query) {
						allowed.append(co)
						strengthDic[co.account_ID ?? "business"] = 70
					}
				} else if let x = item as? User {
					var isDone = false
					if let urname = x.name {
						if urname.lowercased().hasPrefix(query.lowercased()) {
							allowed.append(x)
							strengthDic[x.id] = 90
							isDone = true
						} else if urname.lowercased().contains(query.lowercased()) {
							allowed.append(x)
							strengthDic[x.id] = 60
							isDone = true
						}
					}
					if isDone == false {
						if x.username.lowercased().hasPrefix(query.lowercased()) {
							allowed.append(x)
							strengthDic[x.id] = 80
						} else if x.username.lowercased().contains(query.lowercased()) {
							allowed.append(x)
							strengthDic[x.id] = 50
						}
					}
				}
			}
		}
		
		allowed.sort { (item1, item2) -> Bool in
			var i1 = 0
			var name1 = ""
			var i2 = 0
			var name2 = ""
			if let item1 = item1 as? CompanyDetails {
				name1 = item1.name
				i1 = strengthDic[item1.account_ID ?? "business"]!
			} else if let item1 = item1 as? User {
				name1 = item1.name!
				i1 = strengthDic[item1.id]!
			}
			if let item2 = item2 as? CompanyDetails {
				name2 = item2.name
				i2 = strengthDic[item2.account_ID ?? "business"]!
			} else if let item2 = item2 as? User {
				name2 = item2.name!
				i2 = strengthDic[item2.id]!
			}
			if i1 == i2 {
				return name1 > name2
			} else {
				return i1 > i2
			}
		}
		
		completed(allowed)
		
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
			view.delegate = self
        }else if segue.identifier == "FromSearchToBV"{
            let view = segue.destination as! ViewBusinessVC
            view.fromSearch = true
			view.businessDatail = (sender as! CompanyDetails)
			view.delegate = self
        }
    }
    

}
