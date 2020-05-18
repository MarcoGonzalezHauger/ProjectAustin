//
//  PageVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/2/2020.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import UIKit
//AutoDimiss
class SocialPVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, SocialSegmentDelegate {
    
	
    func socialSegmentIndex(index: Int) {
        let viewController = OrderedVC[self.lastIndex]
        goToPage(index: index, sender: viewController)
        self.lastIndex = index
    }
	
	var lastIndex = 0
	
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
        if (!completed)
        {
          return
        }
        if let index = pageViewController.viewControllers!.first!.view.tag as? Int{
        self.pageViewDidChange?.pageViewIndexDidChangedelegate(index:index)
        }
    }
	
	//returns a list of all VCs in Home Tab.
	lazy var OrderedVC: [UIViewController] = {
		return [newVC(VC: "socialFeed"), newVC(VC: "socialFollowing"), newVC(VC: "socialFollowedBy")]
	}()
	
	//Goes directly to the page specified.
	func goToPage(index: Int, sender: UIViewController) {
		guard let i : Int = OrderedVC.lastIndex(of: sender) else { return }
		if index < OrderedVC.count {
			self.setViewControllers([OrderedVC[index]], direction: index > i ? .forward : .reverse, animated: true, completion: nil)
		}
	}
	
	//Allows for returning of VC when string is inputted.
	func newVC(VC: String) -> UIViewController {
		let NewVC = UIStoryboard(name: "simplexSocial", bundle: nil).instantiateViewController(withIdentifier: VC)
		return NewVC
	}
    
    var pageViewDidChange: PageViewDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		dataSource = self
		delegate = self
		
		
		let firstViewController : UIViewController = OrderedVC[0]
		
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
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
	
}
