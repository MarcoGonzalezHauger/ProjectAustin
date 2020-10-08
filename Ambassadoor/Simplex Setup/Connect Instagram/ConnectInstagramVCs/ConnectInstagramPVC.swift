//
//  ConnectInstagramPVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 28/09/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ConnectInstagramPVC: UIPageViewController,UIPageViewControllerDataSource, UIPageViewControllerDelegate, InstagramPageDelegate {
    func pageIndex(index: Int) {
        let viewController = OrderedVC[self.lastIndex]
        goToPage(index: index, sender: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let i : Int = OrderedVC.lastIndex(of: viewController) else { return nil }
        self.lastIndex = i
        if i - 1 < 0 {
            return nil
        }
        
        return OrderedVC[i - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let i : Int = OrderedVC.lastIndex(of: viewController) else { return nil }
        self.lastIndex = i
        if i + 1 >= OrderedVC.count {
            return nil
        }
        
        return OrderedVC[i + 1]
    }
    
    var lastIndex: Int = 0
    var pageViewDidChange: PageViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dataSource = self
        delegate = self
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.setInprogressBadgeCount), name: Notification.Name("updateinprogresscount"), object: nil)
        //set default VC to Offers Page.
        let firstViewController : UIViewController = OrderedVC[0]
        
        //display that in pages.
        DispatchQueue.main.async {
            self.setViewControllers([firstViewController],
                                    direction: .forward,
                                    animated: true,
                                    completion: nil)
        }
        
    }
    
    //Goes directly to the page specified.
    func goToPage(index: Int, sender: UIViewController) {
        guard let i : Int = OrderedVC.lastIndex(of: sender) else { return }
        if index < OrderedVC.count {
            self.setViewControllers([OrderedVC[index]], direction: index > i ? .forward : .reverse, animated: true, completion: nil)
            self.lastIndex = index
        }
    }
    
    
    
    //returns a list of all VCs in Home Tab.
    lazy var OrderedVC: [UIViewController] = {
        return [newConnectInstaVC(VC: "ConnectStepReference"), newConnectInstaVC(VC: "WhatWillTheySeeReference"),newConnectInstaVC(VC: "IVOreference"),newConnectInstaVC(VC: "IVTreference"),newConnectInstaVC(VC: "ConnectInstaOnlyReference")]
    }()
    
    /*
     //returns a list of all VCs in Home Tab.
     lazy var OrderedVC: [UIViewController] = {
         return [newConnectInstaVC(VC: "ConnectStepReference"), newConnectInstaVC(VC: "HowToSwitchReference"), newConnectInstaVC(VC: "WhatWillTheySeeReference"),newConnectInstaVC(VC: "IVOreference"),newConnectInstaVC(VC: "IVTreference"),newConnectInstaVC(VC: "IVThreference"),newConnectInstaVC(VC: "ConnectInstaOnlyReference")]
     }()
     */
    
    //Allows for returning of VC when string is inputted.
    func newConnectInstaVC(VC: String) -> UIViewController {
        let NewVC = UIStoryboard(name: "LoginSetup", bundle: nil).instantiateViewController(withIdentifier: VC)
        return NewVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
               if let index = pageViewController.viewControllers!.first!.view.tag as? Int{
               self.pageViewDidChange?.pageViewIndexDidChangedelegate(index:index)
            }
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
