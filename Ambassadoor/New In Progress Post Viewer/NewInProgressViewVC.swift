//
//  NewInProgressViewVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/7/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewInProgressViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, myselfRefreshDelegate {
	
	func myselfRefreshed() {
		refreshInProgPosts()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return inProgList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "inProgPost", for: indexPath) as! InProgressPostTVC
		cell.thisInProgressPost = inProgList[indexPath.row]
		cell.updateContents()
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 220
	}
	
	var passIPP: InProgressPost!
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		passIPP = inProgList[indexPath.row]
		performSegue(withIdentifier: "toViewInProgress", sender: self)
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? NewViewInProgressVC {
			view.thisInProgressPost = passIPP
		}
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		refreshInProgPosts()
	}
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var noneInProgress: ShadowView!
	
	@IBAction func viewOffersPressed(_ sender: Any) {
		tabBarController?.selectedIndex = 2
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		let xib = UINib.init(nibName: "InProgressPostTVC", bundle: Bundle.main)
		tableView.register(xib, forCellReuseIdentifier: "inProgPost")
        searchBar.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
		
		myselfRefreshListeners.append(self)
		refreshInProgPosts()
    }
	
	var inProgList: [InProgressPost] = []
	
	func refreshInProgPosts() {
		noneInProgress.isHidden = Myself.inProgressPosts.count != 0
		
		let searchText = searchBar.text!
		
		if searchText == "" {
			inProgList = Myself.inProgressPosts
		} else {
			inProgList = Myself.inProgressPosts.filter{$0.BasicBusiness()?.name.contains(searchText) ?? false}
		}
		
		inProgList.sort{$0.dateAccepted > $1.dateAccepted}
		
		tableView.reloadData()
	}

}
