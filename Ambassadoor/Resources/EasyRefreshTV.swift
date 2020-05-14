//
//  EasyRefreshTV.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 5/13/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol EasyRefreshDelegate {
	func wantsReload(stopRefreshing: @escaping () -> Void)
}

class EasyRefreshTV: UITableView {
	
	var easyRefreshDelegate: EasyRefreshDelegate? {
		didSet {
			setupRefresher()
		}
	}
	
	func StopRefreshing() {
		ezRefreshControl.endRefreshing()
	}
	
	@objc func startRefresh() {
		easyRefreshDelegate?.wantsReload(stopRefreshing: StopRefreshing)
	}
	
	private lazy var ezRefreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(startRefresh), for: .valueChanged)
		return refreshControl
	}()
	
	func setupRefresher() {
		self.insertSubview(ezRefreshControl, at: 0)
		ezRefreshControl.layer.zPosition = -1
	}
	
}
