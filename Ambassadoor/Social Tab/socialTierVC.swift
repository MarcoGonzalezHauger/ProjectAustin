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
}

class socialTierVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GlobalListener {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//filters all users in list and makes sure only to display the users in the same account type.
		let filtered = global.SocialData.filter{$0.AccountType == Yourself.AccountType}
		return filtered.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		//Displays user's information in a cell.
		
		let cell = rankedShelf.dequeueReusableCell(withIdentifier: "socialProfileCell") as! SocialUserCell
		let thisUser : User = global.SocialData.filter{$0.AccountType == Yourself.AccountType}[indexPath.row]
		cell.username.text = thisUser.username
		cell.details.text = NumberToStringWithCommas(number: thisUser.followercount) + " • " + SubCategoryToString(subcategory: thisUser.AccountType)
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 86
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		rankedShelf.dataSource = self
		rankedShelf.delegate = self
		global.delegates.append(self)
    }
	
	@IBOutlet weak var rankedShelf: UITableView!
	
	var Pager: socialPageVC!
	
}
