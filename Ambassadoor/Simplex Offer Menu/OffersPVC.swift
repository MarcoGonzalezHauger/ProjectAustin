//
//  PageVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/2/2020.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class OffersPVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, OfferMenuSegmentDelegate,AutoDimiss {
    func DismissNow(sender: String) {
        dataSource = self
        delegate = self
        
        
        //set default VC to Offers Page.
        let firstViewController : UIViewController = OrderedVC[1]
        
        //display that in pages.
        DispatchQueue.main.async {
            self.setViewControllers([firstViewController],
                                    direction: .forward,
                                    animated: true,
                                    completion: nil)
        }
        
        let bgView = UIView(frame: UIScreen.main.bounds)
        bgView.backgroundColor = GetBackColor()
        view.insertSubview(bgView, at: 0)
        
        self.setInprogressBadgeCount()
        
    }
    
    @objc func setInprogressBadgeCount() {
        getAcceptedOffers { (status, offers) in
            
            if status{
                if offers.count > 0{
                    global.allInprogressOffer = offers
//					self.tabBarController?.tabBar.items![3].badgeValue = String(offers.filter{CheckIfOferIsActive(offer: $0)}.count)
//					UIApplication.shared.applicationIconBadgeNumber = offers.filter{$0.variation == .inProgress}.count
                }
                
            }
            
        }
    }
    
    func segmentIndex(index: Int) {
        let viewController = OrderedVC[self.lastIndex]
        goToPage(index: index, sender: viewController)
    }
	//Turn page -1
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let i : Int = OrderedVC.lastIndex(of: viewController) else { return nil }
		if i - 1 < 0 {
			return nil
		}
        self.lastIndex = i
		return OrderedVC[i - 1]
	}
	
	//Turn page +1
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let i : Int = OrderedVC.lastIndex(of: viewController) else { return nil }
		if i + 1 >= OrderedVC.count {
			return nil
		}
        self.lastIndex = i
		return OrderedVC[i + 1]
	}
	
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
//        if (!completed)
//        {
//          return
//        }
        if let index = pageViewController.viewControllers!.first!.view.tag as? Int{
			self.pageViewDidChange?.pageViewIndexDidChangedelegate(index:index)
        }
    }
	
	//returns a list of all VCs in Home Tab.
	lazy var OrderedVC: [UIViewController] = {
		return [newVC(VC: "followedOffers"), newVC(VC: "filteredOffers"), newVC(VC: "allOffers")]
	}()
	
	//Goes directly to the page specified.
	func goToPage(index: Int, sender: UIViewController) {
		guard let i : Int = OrderedVC.lastIndex(of: sender) else { return }
		if index < OrderedVC.count {
			self.setViewControllers([OrderedVC[index]], direction: index > i ? .forward : .reverse, animated: true, completion: nil)
            self.lastIndex = index
		}
	}
	
	//Allows for returning of VC when string is inputted.
	func newVC(VC: String) -> UIViewController {
		let NewVC = UIStoryboard(name: "OfferMenu", bundle: nil).instantiateViewController(withIdentifier: VC)
		return NewVC
	}
	
    var pageViewDidChange: PageViewDelegate?
    
    var lastIndex: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Yourself != nil{
		dataSource = self
		delegate = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.setInprogressBadgeCount), name: Notification.Name("updateinprogresscount"), object: nil)
		//set default VC to Offers Page.
		let firstViewController : UIViewController = OrderedVC[1]
		
		//display that in pages.
        DispatchQueue.main.async {
            self.setViewControllers([firstViewController],
                                    direction: .forward,
                                    animated: true,
                                    completion: nil)
        }
		
		//let bgView = UIView(frame: UIScreen.main.bounds)
		//bgView.backgroundColor = GetBackColor()
		//view.insertSubview(bgView, at: 0)
        }else{
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toSignUp", sender: self)
            }
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSignUp"{
            let view = segue.destination as! WelcomeVC
            view.delegate = self
            
        }
    }
	
}
