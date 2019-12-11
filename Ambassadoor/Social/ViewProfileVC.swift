//
//  ViewProfileVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/14/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class StatisticCell: UITableViewCell {
	@IBOutlet weak var Name: UILabel!
	@IBOutlet weak var Value: UILabel!
	
	func SetData(Statistic: Stat) {
		Name.text = Statistic.name
		var num: String = NumberToStringWithCommas(number: Statistic.delta)
		if Statistic.delta == 0 {
			Value.textColor = UIColor(red: 185/255, green: 185/255, blue: 185/255, alpha: 1)
		} else if Statistic.delta > 0 {
			Value.textColor = UIColor(red: 42/255, green: 160/255, blue: 88/255, alpha: 1)
			num = "+\(num)"
		} else {
			Value.textColor = UIColor(red: 200/255, green: 0, blue: 0, alpha: 1)
		}
		Value.text = num
	}
}

struct Stat {
	let name: String
	var delta: Double {
		return Double(value1 - value2)
	}
	let value1: Double
	let value2: Double
}

class ViewProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet var swdView: UIView!
	@IBOutlet weak var verifiedView: UIView!
	@IBOutlet weak var infLogo: UIImageView!
	@IBOutlet weak var infLabel: UILabel!
	@IBOutlet weak var tierBubble: ShadowView!
	
	var ThisUser: User! {
		didSet {
			if self.isViewLoaded {
				ShowUser()
			}
		}
	}
	
	func ShowUser() {
//		print("(new) ViewProfile activated, YOURSELF=")
//		print(Yourself!)
//		print("THISUSER=")
//		print(ThisUser)
		
		if blackIcons.contains(ThisUser.username) {
			infLogo.image = UIImage.init(named: "verified_black")
			infLabel.text = "Ambassadoor Executive"
			infLabel.textColor = .label
		} else {
			verifiedView.isHidden = !ThisUser.isDefaultOfferVerify
		}
		
		stats = [Stat.init(name: "Follower Count", value1: Yourself!.followerCount, value2: ThisUser.followerCount)]
		let youraverage = Yourself!.averageLikes ?? 0
		let theiraverage = ThisUser.averageLikes ?? 0
		stats.append(Stat.init(name: "Average Likes", value1: youraverage, value2: theiraverage))
		if let shelf = shelf {
			shelf.reloadData()
		}
//		catLabel.text = ThisUser.primaryCategory.
		catLabel.text = GetCategoryStringFromlist(categories: (ThisUser.categories) ?? [])
        
		if let joinedDate = ThisUser.joinedDate {
			sinceLabel.text = "Ambassador Since \(String(joinedDate.prefix(4)))"
		} else {
			sinceLabel.text = ""
		}
		
		followerLabel.text = NumberToStringWithCommas(number: ThisUser.followerCount) + " followers"
        var tier: Int? = GetTierForInfluencer(influencer: ThisUser)
		tierNum.text = String(tier ?? 0)
		nameLabel.text = ThisUser.name ?? ThisUser.username
		usernameLabel.text = "@\(ThisUser.username)"
		if let picurl = ThisUser.profilePicURL {
			profilePic.downloadedFrom(url: URL.init(string: picurl)!, makeImageCircular: true)
		} else {
//			print(defaultImage)
//			print(profilePic)
			profilePic.image = defaultImage
		}
	}
	
	@IBOutlet weak var profilePic: UIImageView!
	@IBOutlet weak var tierNum: UILabel!
	
	var stats: [Stat] = []
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stats.count
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let statistic = statToPass {
			if let destination = segue.destination as? StatVC {
				destination.ThisStat = statistic
			}
		}
	}
	
	var statToPass: Stat?
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		statToPass = stats[indexPath.row]
		performSegue(withIdentifier: "ToStatisticView", sender: self)
		shelf.deselectRow(at: indexPath, animated: true)
	}
	
	@IBAction func dismiss(_ sender: Any) {
		print("Attempted to dismiss ViewProfileVC")
		self.navigationController?.popViewController(animated: true)
		self.dismiss(animated: true, completion: nil)	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = shelf.dequeueReusableCell(withIdentifier: "StatisticCell") as! StatisticCell
		cell.SetData(Statistic: stats[indexPath.row])
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 45
	}
	
	@IBAction func viewOnInstagram(_ sender: Any) {
		
		//checks if the instagram app is avaliable, if it is it will open the app, if it isn't it will open the ambassador's account in safari.
		
		let user = ThisUser.username
        // open user instagram page
		let instaURL = URL(string: "instagram://user?username=\(user)")!
		print(instaURL)
		let sharedApps = UIApplication.shared
		
		if sharedApps.canOpenURL(instaURL) {
			sharedApps.open(instaURL)
		} else {
			sharedApps.open(URL(string: "https://instagram.com/\(user)")!)
		}
	}
	
	@IBOutlet weak var shelf: UITableView!
	@IBOutlet weak var catLabel: UILabel!
	@IBOutlet weak var sinceLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var followerLabel: UILabel!
	@IBOutlet weak var tierLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		shelf.dataSource = self
		shelf.delegate = self
		shelf.reloadData()
		shelf.layer.cornerRadius = 10
		swdView.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "Instagrad")!)
		tierBubble.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "tiergrad")!)
		ShowUser()
        getInfluencerWorkedCompanies(influencer: Yourself) { (company, status, error) in
            
            if status == "success"{
                
                if company?.count != 0 {
                
                    global.influencerWrkCompany = company!
                    
                }
            }
        }
    }

}
