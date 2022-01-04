//
//  AccountResetVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 25/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class AccountResetVC: UIViewController, UITextFieldDelegate {
    
    
    
    /// Add done and cancel button on UITextField
    @IBOutlet weak var otpText: UITextField!{
        didSet {
            otpText.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneAction(sender:))), onCancel: nil)
        }
    }
    
    var identifyTag: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    /// Resign first responder
    /// - Parameter sender: UIButton referrance
    @IBAction func doneAction(sender: UIButton){
        self.checkIfotpright()
        otpText.resignFirstResponder()
    }
    
    /// return segue identifier based on tag
    /// - Parameter tag: UIButton tag
    /// - Returns: return segue identifier
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
    
    
    /// Check if user entered valid OTP
    func checkIfotpright() {
        if otpText.text?.count == 0 {
            return
        }
        
        if otpText.text!.count != 6 || global.otpData == 0 {
           self.showStandardAlertDialog(title: "Failed", msg: "Invalid One Time Password", handler: nil)
           return
        }
        
        if Int(otpText.text!) != global.otpData{
            self.showStandardAlertDialog(title: "Failed", msg: "Code doesn't match.", handler: nil)
            return
        }
        
        self.performSegue(withIdentifier: self.getSegue(tag: self.identifyTag), sender: self)
        
        
    }
    
    
    /// resign otpText UITextfield.
    /// - Parameter textField: UITextfield referrance
    /// - Returns: true or false
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.otpText.resignFirstResponder()
        self.checkIfotpright()
        return true
    }
    
    
    /// Dismiss current view controller
    /// - Parameter sender: UIButton referrance
    @IBAction func backPressed(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /// Open Email app
    /// - Parameter sender: UIButton referrance
    @IBAction func openMail(sender: UIButton) {
		let urlString = sender.tag == 0 ? "message://" : "googlegmail:"
        let url = URL(string: urlString)!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

}
