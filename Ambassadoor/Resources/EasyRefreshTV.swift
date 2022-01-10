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
	
    /// Setup refresh control
	var easyRefreshDelegate: EasyRefreshDelegate? {
		didSet {
			setupRefresher()
		}
	}
	
    /// Stop refreshing tableview
	func StopRefreshing() {
		ezRefreshControl.endRefreshing()
	}
	
    /// Pass StopRefreshing method to EasyRefreshDelegate method(wantsReload)
	@objc func startRefresh() {
		easyRefreshDelegate?.wantsReload(stopRefreshing: StopRefreshing)
	}
    /// A lazy stored property is a property whose initial value isn’t calculated until the first time it’s used. so we create ezRefreshControl refreshcontrol as lazy property. and initialize UIRefreshControl.
	private lazy var ezRefreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(startRefresh), for: .valueChanged)
		return refreshControl
	}()
    
    /// Create refresh controller and add subview of UITableview
	func setupRefresher() {
		self.insertSubview(ezRefreshControl, at: 0)
		ezRefreshControl.layer.zPosition = -1
	}
	
}
