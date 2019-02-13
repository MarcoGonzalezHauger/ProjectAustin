//
//  socialTierVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/1/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

let defaultImage : UIImage = makeImageCircular(image: UIImage.init(named: "defaultuser")!)

class SocialUserCell: UITableViewCell {
	@IBOutlet weak var username: UILabel!
	@IBOutlet weak var details: UILabel!
	@IBOutlet weak var profilepicture: UIImageView!
	@IBOutlet weak var shadow: ShadowView!
	
	var ShowCategory: Bool = false
	var ThisUser: User? {
		didSet {
			if let thisUser = ThisUser {
				username.text = thisUser.username
				let secondtext : String = ShowCategory ? SubCategoryToString(subcategory: thisUser.AccountType) : "Tier " + String(GetTierFromFollowerCount(FollowerCount: thisUser.followerCount) ?? 0)
				details.text = NumberToStringWithCommas(number: thisUser.followerCount) + " followers • " + secondtext
					if thisUser.username! == Yourself!.username! {
						self.profilepicture.downloadedFrom(url: URL.init(string: Yourself!.profilePicture!)!)
					} else {
						self.profilepicture.image = defaultImage
					}
					self.SetColors(isYourself: thisUser.username == Yourself!.username!)
			}
		}
	}
	
	func SetColors(isYourself: Bool) {
		if isYourself {
			shadow.ShadowColor = UIColor.init(red: 1, green: 121/255, blue: 8/255, alpha: 1)
			shadow.ShadowOpacity = 0.75
			shadow.ShadowRadius = 4
			shadow.backgroundColor = UIColor.init(red: 1, green: 251/255, blue: 243/255, alpha: 1)
		} else {
			shadow.ShadowColor = UIColor.black
			shadow.ShadowOpacity = 0.2
			shadow.ShadowRadius =  1.75
			shadow.backgroundColor = UIColor.white
		}
	}
}

class socialTierVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GlobalListener {
	
	@IBOutlet weak var tierLabel: UILabel!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//filters all users in list and makes sure only to display the users in the same account type.
		let filtered = global.SocialData.filter{GetTierFromFollowerCount(FollowerCount: $0.followerCount) ==  GetTierFromFollowerCount(FollowerCount: Yourself!.followerCount)}
		return filtered.count + 1 //adds one bc of yourself
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		rankedShelf.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		//Displays user's information in a cell.
		
		let cell = rankedShelf.dequeueReusableCell(withIdentifier: "socialProfileCell") as! SocialUserCell
		var allpossibleusers: [User] = global.SocialData.filter{GetTierFromFollowerCount(FollowerCount:  $0.followerCount) ==  GetTierFromFollowerCount(FollowerCount: Yourself!.followerCount)}
		allpossibleusers.append(Yourself!)
		allpossibleusers.sort{ return $0.followerCount > $1.followerCount }
		let thisUser : User = allpossibleusers[indexPath.row]
		cell.ShowCategory = true
		cell.ThisUser = thisUser
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 86
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		tierLabel.text = "Tier " + String(GetTierFromFollowerCount(FollowerCount: Yourself!.followerCount) ?? 0)
		rankedShelf.dataSource = self
		rankedShelf.delegate = self
		global.delegates.append(self)
    }
	
	@IBOutlet weak var rankedShelf: UITableView!
	
	var Pager: socialPageVC!
	
}
