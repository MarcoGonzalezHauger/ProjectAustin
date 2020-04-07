//
//  InfluencerListVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class InfluencerTVC: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tier: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var verifyLogo_img: UIImageView!
    
    @IBOutlet weak var leadingUserName: NSLayoutConstraint!
    var userData: User?{
        didSet{
            if let user = userData{
                
                if let picurl = user.profilePicURL {
                    self.userImage.downloadAndSetImage(picurl)
                } else {
                    self.userImage.image = defaultImage
                }
                
                self.userName.text = "@\(user.username)"
                
                self.tier.text = String(GetTierForInfluencer(influencer: user))
                
                if (Yourself.following?.contains(user.id))!{
                    self.followBtn.setTitle("Unfollow", for: .normal)
                }else{
                    
                    self.followBtn.setTitle("Follow", for: .normal)
                    
                }
                
                if user.isDefaultOfferVerify {
                    verifyLogo_img.image = UIImage(named: "verify_Logo")
                    self.leadingUserName.constant = 34
                    self.updateConstraints()
                    self.layoutIfNeeded()
                } else {
                    verifyLogo_img.image = nil
                    self.leadingUserName.constant = 8
                    self.updateConstraints()
                    self.layoutIfNeeded()
                }
                
                if blackIcons.contains(user.username) {
                      verifyLogo_img.image = UIImage.init(named: "verified_black")
                    self.leadingUserName.constant = 34
                    self.updateConstraints()
                    self.layoutIfNeeded()
                }
                
            }
        }
    }
    
    
}

class InfluencerListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var influencrTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return global.SocialData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "InfluencerResult"
        
        var cell = influencrTable.dequeueReusableCell(withIdentifier: identifier) as? InfluencerTVC

        if cell == nil {
            let nib = Bundle.main.loadNibNamed("InfluencerTVC", owner: self, options: nil)
            cell = nib![0] as? InfluencerTVC
        }
        cell!.userData = global.SocialData[indexPath.row]
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 80.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if global.SocialData.count == 0{
        _ = GetAllUsers(completion: { (users) in
            global.SocialData = users
            DispatchQueue.main.async {
                self.influencrTable.reloadData()
            }
            
            
        })
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
