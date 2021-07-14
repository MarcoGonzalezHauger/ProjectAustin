//
//  TabBarVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 19/09/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController, UITabBarControllerDelegate, myselfRefreshDelegate {
	
	func myselfRefreshed() {
		let shouldHaveMoney = Myself.finance.balance > GetFeeForNewInfluencer(Myself)
		self.viewControllers![0].tabBarItem.badgeValue = shouldHaveMoney ? "$" : nil
		self.viewControllers![0].tabBarItem.badgeColor = .systemGreen
		print("Money Listened to. : \(shouldHaveMoney)")
		
		let _count = Myself.inProgressPosts.filter{$0.status == "Accepted"}.count
		self.viewControllers![3].tabBarItem.badgeValue = _count == 0 ? nil : String(_count)
		self.viewControllers![3].tabBarItem.badgeColor = .systemBlue
		
	}
	
	var isListening = false

	func beginListeningToMoney() {
		if !isListening {
			print("Listening to Money.")
			myselfRefreshListeners.append(self)
			myselfRefreshed()
			isListening = true
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		beginListeningToMoney()
        self.delegate = self
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool{
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
    

}
