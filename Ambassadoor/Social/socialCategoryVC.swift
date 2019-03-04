//
//  socialCategoryVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/1/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class socialCategoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GlobalListener, UIGestureRecognizerDelegate {

	@IBOutlet weak var categoryHeader: UILabel!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//filters all users in list and makes sure only to display the users in the same account type.
		return GetSameCategoryUsers().count
	}
	
	var selectedUser: User?
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedUser = GetSameCategoryUsers()[indexPath.row]
		performSegue(withIdentifier: "ViewFromCategory", sender: self)
		rankedShelf.deselectRow(at: indexPath, animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ViewFromCategory" {
			if let destination = segue.destination as? ViewProfileVC {
				if let selected = selectedUser {
					destination.ThisUser = selected
				}
			}
		}
	}
	
	func GetSameCategoryUsers() -> [User] {
		var allpossibleusers = global.SocialData.filter{$0.AccountType == Yourself!.AccountType}
		allpossibleusers.append(Yourself!)
		allpossibleusers.sort{return $0.followerCount > $1.followerCount }
		return allpossibleusers
	}
	
	@IBAction func search(_ sender: Any) {
		Pager.GoToSearch(sender: self)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		//Displays user's information in a cell.
		
		let cell = rankedShelf.dequeueReusableCell(withIdentifier: "socialProfileCell") as! SocialUserCell
		cell.ShowCategory = false
		cell.ThisUser = GetSameCategoryUsers()[indexPath.row]
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 86
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.setNavigationBarHidden(true, animated: true)
		navigationController?.interactivePopGestureRecognizer?.delegate = self
		categoryHeader.text = "Category: " + Yourself!.AccountType.rawValue
		rankedShelf.dataSource = self
		rankedShelf.delegate = self
		global.delegates.append(self)
	}
	
	@IBOutlet weak var rankedShelf: UITableView!
	
	var Pager: socialPageVC!
}
