//
//  NewSocialSearchVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/28/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewSocialSearchVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, publicDataRefreshDelegate {
    
    /// publicDataRefreshDelegate delegate method. refresh user table if any changes updated in Firebase
	func publicDataRefreshed(userOrBusinessId: String) {
		refreshItems()
	}
    
    /// Get search bar SearchFor enum
    /// - Returns: SearchFor enum
	func GetSearchScope() -> SearchFor {
		switch searchBar.selectedScopeButtonIndex {
		case 0:
			return .both
		case 1:
			return .influencers
		default:
			return .businesses
		}
	}
//	MARK: - Search bar delegate and datasource
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		refreshItems()
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		refreshItems()
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: EasyRefreshTV!
	
	var basicObjectResults: [Any] = []
	
	override func viewDidLoad() {
		tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
		searchBar.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
		
		publicDataListeners.append(self)
		
		refreshItems()
	}

    
    /// Refresh user list
	func refreshItems() {
		basicObjectResults = SearchSocialData(searchQuery: searchBar.text!, searchIn: GetSearchScope())
		tableView.reloadData()
	}

	var passedUserId: String = ""
	var passedBasicId: String = ""
	
//    MARK: - User list UITableview Delegate and Datasource
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if let thisInf = basicObjectResults[indexPath.row] as? BasicInfluencer {
			passedUserId = thisInf.userId
			performSegue(withIdentifier: "toInfluencerView", sender: self)
		}
		if let thisBus = basicObjectResults[indexPath.row] as? BasicBusiness {
			passedBasicId = thisBus.basicId
			performSegue(withIdentifier: "toBusinessView", sender: self)
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return basicObjectResults.count
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? NewBasicInfluencerView {
			view.displayInfluencerId(userId: passedUserId)
		}
		if let view = segue.destination as? NewBasicBusinessView {
			view.displayBasicId(basicId: passedBasicId)
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let businessNibID = "BasicBusinessCell"
		let influencerNibID = "BasicInfluencerCell"
		
		if let business = basicObjectResults[indexPath.row] as? BasicBusiness {
			
			
			var cell = tableView.dequeueReusableCell(withIdentifier: businessNibID) as? BasicBusinessCell
			if cell == nil {
				let nib = Bundle.main.loadNibNamed(businessNibID, owner: self, options: nil)!
				cell = nib[0] as? BasicBusinessCell
			}
			cell!.represents = business
			return cell!
			
			
		} else {
			let influencer = basicObjectResults[indexPath.row] as! BasicInfluencer
			
			
			var cell = tableView.dequeueReusableCell(withIdentifier: influencerNibID) as? BasicInfluenerCell
			if cell == nil {
				let nib = Bundle.main.loadNibNamed(influencerNibID, owner: self, options: nil)!
				cell = nib[0] as? BasicInfluenerCell
			}
			cell!.represents = influencer
			return cell!
			
			
		}
	}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if basicObjectResults[indexPath.row] is BasicBusiness  {
            return 150
        } else {
            return 80
        }
    }
	
}
