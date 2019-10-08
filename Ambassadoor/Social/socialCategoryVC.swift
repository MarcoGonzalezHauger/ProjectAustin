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
        var allpossibleusers = global.SocialData
		allpossibleusers = allpossibleusers.filter{
			for x in $0.categories ?? [] {
				for y in Yourself!.categories ?? [] {
					if x == y {
						return true
					}
				}
			}
			return false
		}
		allpossibleusers.sort{
			if $0.zipCode == Yourself!.zipCode && $1.zipCode != Yourself.zipCode {
				return true
			}
			if $0.zipCode != Yourself!.zipCode && $1.zipCode == Yourself.zipCode {
				return false
			}
			if GetTierForInfluencer(influencer: $0) > GetTierForInfluencer(influencer: $1) {
				return true
			} else if GetTierForInfluencer(influencer: $0) < GetTierForInfluencer(influencer: $1) {
				return false
			} else {
				return $0.followerCount > $1.followerCount
			}
		}
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
		categoryHeader.text = "Same Categories"
		rankedShelf.dataSource = self
		rankedShelf.delegate = self
		global.delegates.append(self)
	}
    
    override func viewWillAppear(_ animated: Bool) {
        _ = GetAllUsers(completion: { (users) in
            global.SocialData = users
            self.rankedShelf.reloadData()
        })
    }
	
	@IBOutlet weak var rankedShelf: UITableView!
	
	var Pager: socialPageVC!
}
