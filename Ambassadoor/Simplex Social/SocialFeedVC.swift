//
//  SocialFeedVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 13/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class SocialCell: UITableViewCell {
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userDes: UILabel!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var socialBar: ShadowView!
    
    var follower: Follower?{
        didSet{
            if let followerDetails = follower{
				self.userName.text = followerDetails.user?.name
                //self.userName.text = "@\(followerDetails.user?.username ?? "")"
                self.userDes.text = "started following you"
                self.dateText.text = followerDetails.startedAt
                self.socialBar.backgroundColor = UIColor.systemBlue
            }
        }
    }
    
    var followingOffer: FollowingInformation?{
        didSet{
            if let offerDetails = followingOffer{
                
				self.userName.text = offerDetails.user?.name ?? ""
                //self.userName.text = "@\(offerDetails.user?.username ?? "")"
				
				if offerDetails.tag == "offer"{
					if let company = offerDetails.offer?.companyDetails {
						self.userDes.text = "accepted an offer from \(company.name)"
						self.socialBar.backgroundColor = UIColor.systemPurple
					} else {
						if offerDetails.offer?.offer_ID == "XXXDefault" {
							self.userDes.text = "is getting verified"
							self.socialBar.backgroundColor = UIColor.systemOrange
						} else {
							self.userDes.text = "accepted an offer"
							self.socialBar.backgroundColor = UIColor.systemPurple
						}
					}
				}else if offerDetails.tag == "follow" {
					self.userDes.text = "started following you"
					self.socialBar.backgroundColor = UIColor.systemBlue
				}
				self.dateText.text = offerDetails.startedAtString!
			}
        }
    }
    
}

class SocialFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, EasyRefreshDelegate {
    func wantsReload(stopRefreshing: @escaping () -> Void) {
        
        var templist = [FollowingInformation]()
        getFollowerList { (status, followerList) in
            if status{
                templist.append(contentsOf: followerList)
            }
            
            getFollowingAcceptedOffers { (status, offers) in
                
                if status{
                    
                    templist.append(contentsOf: offers)
                    self.followerList = templist
                    self.followerList.sort { (objOne, objTwo) -> Bool in
                        return objOne.startedAt.compare(objTwo.startedAt) == .orderedDescending
                    }
                    global.followerList = templist
                    DispatchQueue.main.async {
                        self.socialFeedTable.reloadData()
                    }
                }
                stopRefreshing()
                
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "socialcell"
        var cell = socialFeedTable.dequeueReusableCell(withIdentifier: identifier) as? SocialCell
        
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("SocialCell", owner: self, options: nil)
            cell = nib![0] as? SocialCell
        }
        cell?.followingOffer = followerList[indexPath.row]
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 82.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let obj = followerList[indexPath.row]
        self.performSegue(withIdentifier: "FromSocialFeed", sender: obj.user)
		tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBOutlet weak var socialFeedTable: EasyRefreshTV!
    
    var followerList = [FollowingInformation]()
               

    @objc func reloadSocialData() {
		var templist = [FollowingInformation]()
		getFollowerList { (status, followerList) in
            if status{
                templist.append(contentsOf: followerList)
            }
            
            getFollowingAcceptedOffers { (status, offers) in
                
                if status{
                    
                    templist.append(contentsOf: offers)
					self.followerList = templist
                    self.followerList.sort { (objOne, objTwo) -> Bool in
                        return objOne.startedAt.compare(objTwo.startedAt) == .orderedDescending
                    }
                    global.followerList = templist
                    DispatchQueue.main.async {
                        self.socialFeedTable.reloadData()
                    }
                }
                
            }
        }
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
		socialFeedTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        socialFeedTable.easyRefreshDelegate = self
		
		if global.followerList.count != 0 {
            self.followerList = global.followerList
			DispatchQueue.main.async {
				self.socialFeedTable.reloadData()
			}
		}
		reloadSocialData()
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadSocialData), name: Notification.Name("followaction"), object: nil)
		reloadSocialData()
	}
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FromSocialFeed"{
            let view = segue.destination as! ViewProfileVC
            view.ThisUser = (sender as! User)
        }
    }
    

}
