//
//  socialPageVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/1/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class socialPageVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

	//Turn page -1
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let i : Int = socialOrderedVC.lastIndex(of: viewController) else { return nil }
		if i - 1 < 0 {
			return nil
		}
		return socialOrderedVC[i - 1]
	}
	
	//Turn page +1
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let i : Int = socialOrderedVC.lastIndex(of: viewController) else { return nil }
		if i + 1 >= socialOrderedVC.count {
			return nil
		}
		return socialOrderedVC[i + 1]
	}
	
	
	
	//returns a list of all VCs in social Tab.
	lazy var socialOrderedVC: [UIViewController] = {
		return [newVC(VC: "socialTier"), newVC(VC: "socialCategory"), newVC(VC: "socialTrending")]
	}()
	
	//Goes directly to the page specified.
	func goToPage(index: Int, sender: UIViewController) {
		guard let i : Int = socialOrderedVC.lastIndex(of: sender) else { return }
		if index < socialOrderedVC.count {
			self.setViewControllers([socialOrderedVC[index]], direction: index > i ? .forward : .reverse, animated: true, completion: nil)
		}
	}
	
	//Allows for returning of VC when string is inputted.
	func newVC(VC: String) -> UIViewController {
		let NewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: VC)
		if let vc = NewVC as? socialTierVC	{
			//Make sure each VC has access to the PageViewController
			vc.Pager = self
		}
		if let vc = NewVC as? socialCategoryVC {
			vc.Pager = self
		}
		if let vc = NewVC as? socialTrendingVC {
			vc.Pager = self
		}
		return NewVC
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource = self
		delegate = self
		
		
		//set default VC to Offers Page.
		let firstViewController : UIViewController = socialOrderedVC[1]
		
		//display that in pages.
		setViewControllers([firstViewController],
						   direction: .forward,
						   animated: true,
						   completion: nil)
		
		let bgView = UIView(frame: UIScreen.main.bounds)
		bgView.backgroundColor = UIColor.white
		view.insertSubview(bgView, at: 0)
	}
	
}
