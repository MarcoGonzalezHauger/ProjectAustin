//
//  ReferralInfoVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 14/09/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ReferralInfoVC: UIViewController {
    
    @IBOutlet weak var referralLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        referralLabel.text = Yourself.referralcode

        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
