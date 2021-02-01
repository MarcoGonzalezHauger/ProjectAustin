//
//  OfferPoolView.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/31/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class OfferPoolView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, OfferPoolRefreshDelegate {
	
	func OfferPoolRefreshed(poolId: String) {
		refreshPool()
	}
	
	enum offerPoolFilter {
		case followed, filitered, all
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		refreshPool()
	}
	
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		refreshPool()
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		refreshPool()
	}
	
	func GetScope() -> offerPoolFilter {
		switch searchBar.selectedScopeButtonIndex {
		case 0:
			return .followed
		case 1:
			return .filitered
		default:
			return .all
		}
	}
	
	func refreshPool() {
		var pool: [PoolOffer]
		switch GetScope() {
		case .followed:
			pool = getFollowingOfferPool()
		case .filitered:
			pool = getFilteredOfferPool()
		case .all:
			pool = GetOfferPool()
		}
		let query = searchBar.text!.lowercased()
		if query != "" {
			pool = pool.filter{($0.BasicBusiness()?.name.lowercased().contains(query) ?? false)}
		}
		if !Myself.basic.isForTesting {
			pool = pool.filter {
				if let bus = $0.BasicBusiness() {
					return !bus.isForTesting
				}
				return false
			}
		}
		currentOffers = pool
		tableView.reloadData()
	}
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchBar: UISearchBar!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		let xib = UINib.init(nibName: "PoolOfferTVC", bundle: Bundle.main)
		tableView.register(xib, forCellReuseIdentifier: "PoolOffer")
		
		searchBar.delegate = self
		
		tableView.delegate = self
		tableView.dataSource = self
		
		offerPoolListeners.append(self)
		
    }
	
	var currentOffers: [PoolOffer] = []
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return currentOffers.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return globalPoolOfferHeight
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let thisOffer = currentOffers[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "PoolOffer") as! PoolOfferTVC
		cell.poolOffer = thisOffer
		cell.updateContents(expectedWidth: tableView.bounds.width)
		return cell
	}

}
