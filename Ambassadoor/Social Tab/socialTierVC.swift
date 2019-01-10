//
//  socialTierVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/1/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class SocialUserCell: UITableViewCell {
	@IBOutlet weak var username: UILabel!
	@IBOutlet weak var details: UILabel!
	@IBOutlet weak var profilepicture: UIImageView!
	@IBOutlet weak var shadow: ShadowView!
	
	func SetUser(user thisUser: User) {
		username.text = thisUser.username
		details.text = NumberToStringWithCommas(number: thisUser.followerCount) + " followers • " + SubCategoryToString(subcategory: thisUser.AccountType)
		let userImage: UIImage = thisUser.profilePicture ?? UIImage.init(named: "defaultuser")!
		shadow.ShadowColor = thisUser.username == Yourself.username ? UIColor.init(red: 110/255, green: 200/255, blue: 65/255, alpha: 1) : UIColor.black
		shadow.ShadowOpacity = thisUser.username == Yourself.username ? 0.5 : 0.2
		shadow.ShadowRadius = thisUser.username == Yourself.username ? 4 : 1.75
		shadow.backgroundColor = thisUser.username == Yourself.username ? UIColor.init(red: 245/255, green: 1, blue: 245/255, alpha: 1) : UIColor.white
		profilepicture.image = makeImageCircular(image: userImage)
	}
}

class socialTierVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GlobalListener {
	
	@IBOutlet weak var tierLabel: UILabel!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//filters all users in list and makes sure only to display the users in the same account type.
		let filtered = global.SocialData.filter{GetTierFromFollowerCount(FollowerCount: $0.followerCount) ==  GetTierFromFollowerCount(FollowerCount: Yourself.followerCount)}
		return filtered.count + 1 //adds one bc of yourself
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		rankedShelf.deselectRow(at: indexPath, animated: false)
		let cell = rankedShelf.cellForRow(at: indexPath) as! SocialUserCell
		cell.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
		cell.shadow.isHidden = false
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		//Displays user's information in a cell.
		
		let cell = rankedShelf.dequeueReusableCell(withIdentifier: "socialProfileCell") as! SocialUserCell
		var allpossibleusers: [User] = global.SocialData.filter{GetTierFromFollowerCount(FollowerCount:  $0.followerCount) ==  GetTierFromFollowerCount(FollowerCount: Yourself.followerCount)}
		allpossibleusers.append(Yourself)
		allpossibleusers.sort{ return $0.followerCount > $1.followerCount }
		let thisUser : User = allpossibleusers[indexPath.row]
		cell.SetUser(user: thisUser)
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 86
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		tierLabel.text = "Tier " + String(GetTierFromFollowerCount(FollowerCount: Yourself.followerCount) ?? 0)
		rankedShelf.dataSource = self
		rankedShelf.delegate = self
		global.delegates.append(self)
    }
	
	@IBOutlet weak var rankedShelf: UITableView!
	
	var Pager: socialPageVC!
	
}
