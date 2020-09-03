//
//  SocialFollowingVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 14/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class SocialFollowingVC: UIViewController, UITableViewDelegate, UITableViewDataSource, followUpdateDelegate, EasyRefreshDelegate {
    func wantsReload(stopRefreshing: @escaping () -> Void) {
        
        getFollowingList { (status, usersList) in
        
        if status{
            
            self.userList = usersList
            global.userList.removeAll()
            global.userList = usersList
            DispatchQueue.main.async {
                self.followingTable.reloadData()
            }
            
        }
        stopRefreshing()
        
    }
        
    }
    
	
	func followingUpdated() {
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
	
    var userList = [AnyObject]()
    @IBOutlet weak var followingTable: EasyRefreshTV!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		followingTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        followingTable.easyRefreshDelegate = self
		
		if global.userList.count != 0 {
			self.userList = global.userList
			DispatchQueue.main.async {
				self.followingTable.reloadData()
			}
		} else {
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
	
	override func viewDidAppear(_ animated: Bool) {
		followingUpdated()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		followingUpdated()
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
			cell!.followButton.tag = indexPath.row
			return cell!
		}else{
			
			let identifier = "BusinessResult"
			
			var cell = followingTable.dequeueReusableCell(withIdentifier: identifier) as? BusinessUserTVC
			
			if cell == nil {
				let nib = Bundle.main.loadNibNamed("BusinessUserTVC", owner: self, options: nil)
				cell = nib![0] as? BusinessUserTVC
			}
			cell!.businessDatail = (self.userList[indexPath.row] as! CompanyDetails)
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
		} else if let ThisUser = self.userList[indexPath.row] as? CompanyDetails {
            self.performSegue(withIdentifier: "FromSearchToBV", sender: ThisUser)
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FromSocialFollowing"{
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
