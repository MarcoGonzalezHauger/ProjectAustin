//
//  PageVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/2/2020.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class SearchPVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, SearchSegmentDelegate {
    func searchSegmentIndex(index: Int) {
        let viewController = OrderedVC[index]
        goToPage(index: index, sender: viewController)
    }
    
	
	//Turn page -1
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let i : Int = OrderedVC.lastIndex(of: viewController) else { return nil }
		if i - 1 < 0 {
			return nil
		}
		return OrderedVC[i - 1]
	}
	
	//Turn page +1
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let i : Int = OrderedVC.lastIndex(of: viewController) else { return nil }
		if i + 1 >= OrderedVC.count {
			return nil
		}
		return OrderedVC[i + 1]
	}
	
	
	
	//returns a list of all VCs in Home Tab.
	lazy var OrderedVC: [UIViewController] = {
		return [newVC(VC: "resultsBoth"), newVC(VC: "resultsBusiness"), newVC(VC: "resultsInfluencer")]
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
		let NewVC = UIStoryboard(name: "Searcher", bundle: nil).instantiateViewController(withIdentifier: VC)
		return NewVC
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
	
}
