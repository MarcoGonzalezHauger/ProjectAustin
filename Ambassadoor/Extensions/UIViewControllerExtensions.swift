//
//  UIViewControllerExtensions.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 09/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

extension UIViewController {
//    class func getIdentifier() -> String {
//        let className = NSStringFromClass(self).components(separatedBy: ".").last!
//        return className.lowercaseFirst
//    }
    
	func showStandardAlertDialog(title: String = "Error", msg: String = "An unhandled error occurred.", handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: handler))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func performDismiss()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func toggleUserInteraction(_ enable: Bool) {
        if let activeView = navigationController?.view ?? view {
            activeView.isUserInteractionEnabled = enable
        }
    }
    
}
