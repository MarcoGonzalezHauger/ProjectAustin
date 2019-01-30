//
//  socialTrendingVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/1/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class socialTrendingVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GlobalListener {
	
	@IBOutlet weak var categoryHeader: UILabel!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//filters all users in list and makes sure only to display the users in the same account type.
		let filtered = global.SocialData.filter{$0.followerCount >= 100000}
		return filtered.count // DOesn't add one because you  might not qualify for Trending.
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		rankedShelf.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		//Displays user's information in a cell.
		
		let cell = rankedShelf.dequeueReusableCell(withIdentifier: "socialProfileCell") as! SocialUserCell
		var allpossibleusers: [User] = global.SocialData.filter{$0.followerCount >= 100000}
		//allpossibleusers.append(Yourself)
		allpossibleusers.sort{return $0.followerCount > $1.followerCount }
		let thisUser : User = allpossibleusers[indexPath.row]
		cell.ShowCategory = false
		cell.ThisUser = thisUser
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 86
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		categoryHeader.text = "Trending"
		rankedShelf.dataSource = self
		rankedShelf.delegate = self
		global.delegates.append(self)
	}
	
	@IBOutlet weak var rankedShelf: UITableView!
	
	var Pager: socialPageVC!
}
