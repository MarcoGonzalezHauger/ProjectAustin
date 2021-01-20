//
//  InfluencerListVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class InfluencerListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchBarDelegate, followUpdateDelegate, EasyRefreshDelegate {
	
	func wantsReload(stopRefreshing: @escaping () -> Void) {
		influencerTable.reloadData()
		stopRefreshing()
	}
	
	
	func followingUpdated() {
		influencerTable.reloadRows(at: [IndexPath.init(row: activeView!, section: 0)], with: .none)
	} 
    func SearchTextIndex(text: String, segmentIndex: Int) {
        self.GetSearchedInfluencerItems(query: text) { (users) in
            self.influencerTempArray.removeAll()
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
    @IBOutlet weak var influencerTable: EasyRefreshTV!
    
    var influencerTempArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        influencerTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
		influencerTable.easyRefreshDelegate = self
		
		
		if global.SocialData.count == 0{
			_ = GetAllUsers(completion: { (users) in
                global.SocialData.removeAll()
				global.SocialData = users
				self.influencerTempArray = GetInfluencersInOrder()
				DispatchQueue.main.async {
					self.influencerTable.reloadData()
				}
				
				
			})
		}else{
			self.influencerTempArray = GetInfluencersInOrder()
			DispatchQueue.main.async {
				self.influencerTable.reloadData()
			}
		}
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadUserData), name: Notification.Name("reloadusers"), object: nil)
		SearchMenuVC.searchDelegate = self
	}
	
    @objc func reloadUserData() {
        self.influencerTempArray = GetViewableSocialData()
        DispatchQueue.main.async {
            self.influencerTable.reloadData()
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
				return User1.averageLikes ?? 0 > User2.averageLikes ?? 0
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
