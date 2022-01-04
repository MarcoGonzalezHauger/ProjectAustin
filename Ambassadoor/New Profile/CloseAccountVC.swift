//
//  CloseAccountVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 25/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class CloseAccountVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var confirm: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    /// Resign confirm textfield
    /// - Parameter textField: UITextField referrance
    /// - Returns: true or false
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        //self.updatePassword()
        self.confirm.resignFirstResponder()
        return true
    }
    
    
    /// Confirm action
    /// - Parameter sender: UIButton referrance
    @IBAction func confirmPressedAction(sender: UIButton){
        self.confirmPassed()
    }
    
    
    /// Check if user entered correct text. add isInvisible, isClosedAccount, InstagramAccessToken tags. set instagram access token empty. update changes to firebase
    func confirmPassed() {
        
        if self.confirm.text?.count == 0 {
            showStandardAlertDialog(title: "Alert", msg: "Type CONFIRM to close the account", handler: nil)
            return
        }
        
        if self.confirm.text!.lowercased().trimmingCharacters(in: .whitespaces) != "confirm" {
           showStandardAlertDialog(title: "Alert", msg: "Please Type CONFIRM text", handler: nil)
           return
        }
        
        Myself.basic.AddFlag("isInvisible")
        Myself.basic.AddFlag("isClosedAccount")
        Myself.basic.AddFlag("InstagramAccessToken")
        Myself.instagramAccountId = ""
        Myself.email = "(deleted)\(Myself.email)"
        
        Myself.UpdateToFirebase(alsoUpdateToPublic: true) { (error) in
            if error{
               self.showStandardAlertDialog(title: "Alert", msg: "Something Wrong!", handler: nil)
                return
            }
            logOut()
        }
        
    }
    
    
    /// Pop to root view controller
    /// - Parameter sender: UIButton referrance
    @IBAction func popAction(sender: UIButton){
        poptoRoot()
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
