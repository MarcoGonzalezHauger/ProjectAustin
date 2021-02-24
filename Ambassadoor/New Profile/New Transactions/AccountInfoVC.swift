//
//  AccountInfoVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 16/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class AccountInfoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.segueToWithdraw), name: Notification.Name("reloadbanklist"), object: nil)
        // Do any additional setup after loading the view.
		
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
    }
    
    @IBAction func showStripeAccount(gesture: UIGestureRecognizer){
        if Myself.finance.hasStripeAccount {
            self.performSegue(withIdentifier: "fromAccountInfoToWithdraw", sender: self)
        }else{
            self.performSegue(withIdentifier: "fromAccountToStripe", sender: self)
        }
        
    }
    
    @objc func segueToWithdraw(notification: Notification){
        
            DispatchQueue.main.async {
            var navigationArray = self.navigationController!.viewControllers // To get all UIViewController stack as Array
            navigationArray.remove(at: navigationArray.count - 1) // To remove previous UIViewController
            self.navigationController?.viewControllers = navigationArray
                
            self.performSegue(withIdentifier: "fromAccountInfoToWithdraw", sender: self)
            
            }
        
        
    }
    
    @IBAction func closeAction(_sender: Any){
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
