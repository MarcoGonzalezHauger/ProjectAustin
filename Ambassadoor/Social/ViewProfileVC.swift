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
	
	var ThisUser: User! {
		didSet {
			if self.isViewLoaded {
				ShowUser()
			}
		}
	}
	
	func ShowUser() {
		debugPrint("(new) ViewProfile activated, YOURSELF=")
		debugPrint(Yourself!)
		debugPrint("THISUSER=")
		debugPrint(ThisUser)
		stats = [Stat.init(name: "Follower Count", value1: ThisUser.followerCount, value2: Yourself!.followerCount)]
		if ThisUser.averageLikes != nil && Yourself!.averageLikes != nil {
			stats.append(Stat.init(name: "Average Likes", value1: ThisUser.averageLikes!, value2: Yourself!.averageLikes!))
		}
		if let shelf = shelf {
			shelf.reloadData()
		}
//		catLabel.text = ThisUser.primaryCategory.rawValue
        var finalCategories = ""
        if ThisUser.categories != nil{
            for category in ThisUser.categories! {
                finalCategories.append(category + ",")
            }
        }

        if finalCategories != "" {
            finalCategories.remove(at: finalCategories.index(before: finalCategories.endIndex))
        }
        catLabel.text = finalCategories
        
		sinceLabel.text = "Ambassdaoor since 1998"
		followerLabel.text = NumberToStringWithCommas(number: ThisUser.followerCount) + " followers"
		let tier: Int? = GetTierFromFollowerCount(FollowerCount: ThisUser.followerCount)
		tierLabel.text = tier == nil ? "No Tier" : "Tier \(tier!)"
		nameLabel.text = ThisUser.name ?? ThisUser.username
		usernameLabel.text = "@\(ThisUser.username)"
        joinedOn_lbl.text = ThisUser.joinedDate != nil ? "Joined On : " + ThisUser.joinedDate! : ""
		if let picurl = ThisUser.profilePicURL {
			profilePic.downloadedFrom(url: URL.init(string: picurl)!, makeImageCircular: true)
		} else {
			debugPrint(defaultImage)
			debugPrint(profilePic)
			profilePic.image = defaultImage
		}
	}
	
	@IBOutlet weak var profilePic: UIImageView!
	
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
		debugPrint("Attempted to dismiss ViewProfileVC")
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
		let instaURL = URL(string: "instagram://user?username=\(user)")!
		debugPrint(instaURL)
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
    @IBOutlet weak var joinedOn_lbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		shelf.dataSource = self
		shelf.delegate = self
		shelf.reloadData()
		shelf.layer.cornerRadius = 10
		swdView.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "Instagrad")!)
		ShowUser()
    }

}
