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
                    self.viewControllers?[0].tabBarItem.image = nil
                    self.viewControllers?[0].tabBarItem.selectedImage = nil
                    self.viewControllers?[0].tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
                    self.viewControllers?[0].tabBarItem.selectedImage = image.withRenderingMode(.alwaysOriginal)
                }
                
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool{
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
    

}
