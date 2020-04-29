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
					} else {
						self.userDes.text = "accepted an offer"
					}
					self.socialBar.backgroundColor = UIColor.systemPurple
				}else if offerDetails.tag == "follow" {
					self.userDes.text = "started following you"
					self.socialBar.backgroundColor = UIColor.systemBlue
				}
				self.dateText.text = offerDetails.startedAt?.toString(dateFormat: "MMM dd YYYY")
			}
        }
    }
    
}

class SocialFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
    
    @IBOutlet weak var socialFeedTable: UITableView!
    
    var followerList = [FollowingInformation]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
		socialFeedTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
		
		
        if global.followerList.count != 0 {
            self.followerList = global.followerList
            DispatchQueue.main.async {
                self.socialFeedTable.reloadData()
            }
        }
        else{
        getFollowerList { (status, followerList) in
            if status{
                self.followerList.append(contentsOf: followerList)
                
            }
            
            getFollowingAcceptedOffers { (status, offers) in
                
                if status{
                    
                    self.followerList.append(contentsOf: offers)
                    let sorted = self.followerList.sorted { (objOne, objTwo) -> Bool in
                    return (objOne.startedAt!.compare(objTwo.startedAt!) == .orderedDescending)
                    }
                    self.followerList = sorted
                    global.followerList.removeAll()
                    global.followerList = sorted
                    DispatchQueue.main.async {
                        self.socialFeedTable.reloadData()
                    }
                }
                
            }
        }
    }
        
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
