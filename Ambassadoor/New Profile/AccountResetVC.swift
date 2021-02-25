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
    var otpCode: Int = 0

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
            self.showStandardAlertDialog(title: "Alert", msg: "Please enter the OTP", handler: nil)
            return
        }
        
        if Int(otpText.text!) != self.otpCode{
            self.showStandardAlertDialog(title: "Alert", msg: "OTP does not match", handler: nil)
            return
        }
        
        self.performSegue(withIdentifier: self.getSegue(tag: self.identifyTag), sender: self)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.otpText.resignFirstResponder()
        self.checkIfotpright()
        return true
    }
    
    @IBAction func openMail(sender: UIButton) {
        let urlString = sender.tag == 0 ? "googlegmail://" : "mailto://"
        let url = URL(string: urlString)!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
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
