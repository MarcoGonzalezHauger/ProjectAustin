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
		var pool: [PoolOffer] = [PoolOffer]()
		switch GetScope() {
		case .followed:
			pool = getFollowingOfferPool()
		case .filitered:
			pool = getFilteredOfferPool()
		case .all:
			pool = GetOfferPool()
		}
		if Myself == nil {
			currentOffers = pool
			tableView.reloadData()
			return
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
		
		if pool.count == 0 {
			noResultsView.isHidden = false
			if query == "" {
				noResultsLabel.text = "No offers for you yet.\n\nGet a Businesses to sign up using your referral code \(Myself.basic.referralCode) to get 1% of all the money the business spend on Ambassadoor forever."
			} else {
				noResultsLabel.text = "No results for search"
			}
		} else {
			noResultsView.isHidden = true
		}
		
		tableView.reloadData()
	}
	
	@IBOutlet weak var noResultsLabel: UILabel!
	@IBOutlet weak var noResultsView: UIView!
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

	var imageWasSet = false
    
    override func viewWillAppear(_ animated: Bool) {
        if !imageWasSet {
            self.setTabBarProfilePicture()
        }
    }
    
    func setTabBarProfilePicture() {
        let logo = Myself.basic.resizedProfile
        downloadImage(logo) { (image) in
            let size = CGSize.init(width: 30, height: 30)
            
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            image?.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if var image = newImage {
                DispatchQueue.main.async {
                    print(image.scale)
                    image = makeImageCircular(image: image)
                    print(image.scale)
                    self.tabBarController?.viewControllers?[0].tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
                    self.tabBarController?.viewControllers?[0].tabBarItem.selectedImage = image.withRenderingMode(.alwaysOriginal)
                    self.imageWasSet = true
                }
                
            }
        }
    }
	
	var passPO: PoolOffer!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? PoolOfferNC {
			view.SetPoolOffer(poolOffer: passPO)
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		passPO = currentOffers[indexPath.row]
		performSegue(withIdentifier: "viewPoolOffer", sender: self)
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
