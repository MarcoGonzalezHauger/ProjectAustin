//
//  NewZipcodeVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 16/09/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewZipcodeVC: UIViewController, EnterZipCode {
    
    
    @IBOutlet weak var zipCodeText: UIButton!
    
    func ZipCodeEntered(zipCode: String?) {
        if let zipCode = zipCode {
            if zipCode != "" {
                
                NewAccount.zipCode = zipCode
                
                GetTownName(zipCode: zipCode) { (data, zip) in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.zipCodeText.setTitle(zipCode + ", " + data.CityAndStateName, for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func showZipCode(sender: UIButton){
        self.performSegue(withIdentifier: "fromNewZipcodeVC", sender: self)
    }
    
    @IBAction func nextAction(sender: UIButton){
        if NewAccount.zipCode == "" {
            self.showStandardAlertDialog(title: "alert", msg: "Please enter any Zipcode") { action in
            }
            return
        }
        self.performSegue(withIdentifier: "toNewCreateAccountSegue", sender: self)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        NewAccount.zipCode = ""
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? ZipCodeVC {
            view.delegate = self
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
