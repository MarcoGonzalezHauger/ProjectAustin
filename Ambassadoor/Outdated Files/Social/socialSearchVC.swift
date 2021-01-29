//
//  socialSearchVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/1/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import UIKit

class socialSearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GlobalListener, UISearchBarDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//filters all users in list and makes sure only to display the users in the same account type.
		return results.count // Doesn't add one because you  might not qualify for Trending; Trending shall be the only page in Trending that might not include yourself.
	}
	
	var selectedUser: User?
	@IBOutlet weak var searchbar: UISearchBar!
	@IBOutlet weak var rankedShelf: UITableView!
	var Pager: socialPageVC!
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)	{
		query = searchText != "" ? searchText : nil
		if let query = query {
			socialSearchVC.GetSearchedItems(query: query, completed: DoneSearch(Results:))
		} else {
			DoneSearch(Results: GetTrendingUsers())
		}
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchbar.resignFirstResponder()
	}
	
	var query: String?
	
	func DoneSearch(Results: [User]) -> () {
		results = Results
		rankedShelf.reloadData()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedUser = results[indexPath.row]
		performSegue(withIdentifier: "ViewFromSearch", sender: self)
		rankedShelf.deselectRow(at: indexPath, animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ViewFromSearch" {
			if let destination = segue.destination as? ViewProfileVC {
				if let selected = selectedUser {
					destination.ThisUser = selected
				}
			}
		}
	}
	
	var autoSearch: Bool = false
	
	@IBAction func back(_ sender: Any) {
		Pager.goToPage(index: 1, sender: self)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if autoSearch == true {
			searchbar.becomeFirstResponder() // selects search bar in order to start typing.
			autoSearch = false
		}
	}
	
	var results: [User] = []
	
	static func GetSearchedItems(query: String?, completed: @escaping (_ Results: [User]) -> ()) {
		guard let query = query else { return }
		var metusers: [User] = []
		var strengthdict: [User: Int] = [:]
		for x : User in global.SocialData {
			var isDone = false
			if let urname = x.name {
				if urname.lowercased().hasPrefix(query.lowercased()) {
					metusers.append(x)
					strengthdict[x] = 100
					isDone = true
				} else if urname.lowercased().contains(query.lowercased()) {
					metusers.append(x)
					strengthdict[x] = 80
					isDone = true
				}
			}
			if isDone == false {
				if x.username.lowercased().hasPrefix(query.lowercased()) {
					metusers.append(x)
					strengthdict[x] = 90
				} else if x.username.lowercased().contains(query.lowercased()) {
					metusers.append(x)
					strengthdict[x] = 70
				}
			}
		}
		metusers.sort { (User1, User2) -> Bool in
			if strengthdict[User1]! == strengthdict[User2]! {
				return User1.followerCount > User2.followerCount
			} else {
				return strengthdict[User1]! > strengthdict[User2]!
			}
		}
		completed(metusers)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		//Displays user's information in a cell.
		
		let cell = rankedShelf.dequeueReusableCell(withIdentifier: "socialProfileCell") as! SocialUserCell
		let thisUser : User = results[indexPath.row]
		cell.ShowCategory = true
		cell.ThisUser = thisUser
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 86
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		results = GetTrendingUsers()
		searchbar.delegate = self
		rankedShelf.dataSource = self
		rankedShelf.delegate = self
		global.delegates.append(self)
	}
	
}
