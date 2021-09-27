//
//  NewGotoInstaVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 28/07/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewGotoInstaVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func toSegueAction(sender: UIButton){
        self.performSegue(withIdentifier: "toFBprofileSegue", sender: self)
    }

	@IBAction func openInsta(_ sender: Any) {
		
		
			let appURL = URL(string: "instagram://")!
			let application = UIApplication.shared

			if application.canOpenURL(appURL) {
				application.open(appURL)
			} else {
				// if Instagram app is not installed, open URL inside Safari
				let webURL = URL(string: "https://instagram.com/")!
				application.open(webURL)
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
