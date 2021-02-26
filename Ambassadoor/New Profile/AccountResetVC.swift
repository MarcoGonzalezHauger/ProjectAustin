//
//  AccountResetVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 25/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class AccountResetVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var otpText: UITextField!
    
    var identifyTag: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func getSegue(tag: Int) -> String {
        switch tag {
        case 0:
            return "toChangePassword"
        case 1:
            return "toChangeEmail"
        default:
            return "toCloseAccount"
        }
    }
    
    func checkIfotpright() {
        
        
        if otpText.text?.count == 0 {
            return
        }
        
        if otpText.text!.count != 6 {
           self.showStandardAlertDialog(title: "Failed", msg: "Invalid One Time Password", handler: nil)
           return
        }
        
        if Int(otpText.text!) != global.otpData{
            self.showStandardAlertDialog(title: "Failed", msg: "Code doesn't match.", handler: nil)
            return
        }
        
        self.performSegue(withIdentifier: self.getSegue(tag: self.identifyTag), sender: self)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.otpText.resignFirstResponder()
        self.checkIfotpright()
        return true
    }
    
    @IBAction func backPressed(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openMail(sender: UIButton) {
		let urlString = sender.tag == 0 ? "message://" : "googlegmail:"
        let url = URL(string: urlString)!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

}
