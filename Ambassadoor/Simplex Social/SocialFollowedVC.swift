//
//  SocialFollowedVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 14/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class SocialFollowedVC: UIViewController,UITableViewDataSource, UITableViewDelegate, followUpdateDelegate, EasyRefreshDelegate {
	
	func wantsReload(stopRefreshing: @escaping () -> Void) {
		getFollowedByList { (status, users) in
			if status{
				self.influencerList = users
				DispatchQueue.main.async {
					self.followingTable.reloadData()
                    
				}
			}
            stopRefreshing()
			
		}
	}
	
	
	
	func followingUpdated() {
		followingTable.reloadData()
	}
	
    
    var influencerList = [User]()
    @IBOutlet weak var followingTable: EasyRefreshTV!
			
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(sender:)), name: Notification.Name("updatefollowedBy"), object: nil)
		followingTable.easyRefreshDelegate = self
        self.influencerList.removeAll()
		followingTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
		
        if global.influencerList.count != 0 {
            self.influencerList = global.influencerList
            DispatchQueue.main.async {
                self.followingTable.reloadData()
            }
        }else{
            getFollowedByList { (status, users) in
                
                if status{
                    
                    self.influencerList = users
                    DispatchQueue.main.async {
                        self.followingTable.reloadData()
                    }
                    
                }
                
            }
        }
        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(_ animated: Bool) {
		followingTable.reloadData()
	}
    
    @objc func reloadData(sender: NSNotification){
        followingTable.reloadData()
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
		return cell!
		
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		return 80.0
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
		let user = self.influencerList[indexPath.row]
		self.performSegue(withIdentifier: "FromSocialFollowed", sender: user)
		tableView.deselectRow(at: indexPath, animated: true)
		
	}

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FromSocialFollowed"{
            let view = segue.destination as! ViewProfileVC
            view.ThisUser = (sender as! User)
			view.delegate = self
        }
    }
    

}
