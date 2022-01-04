//
//  ChangePasswordVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 25/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    /// resign password textfield
    /// - Parameter textField: UITextField referrance
    /// - Returns: true or false
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        //self.updatePassword()
        self.password.resignFirstResponder()
        return true
    }
    
    
    /// Resign password text. call Update password method
    /// - Parameter sender: UIButton referrance
    @IBAction func changePassword(sender: UIButton){
        self.password.resignFirstResponder()
        self.updatePassword()
    }
    
    
    /// Check if user entered valid password or not. update changes to firebase. pop to root viewcontroller
    func updatePassword() {
        
        if self.password.text?.count == 0 {
            
            showStandardAlertDialog(title: "Alert", msg: "Please enter your new password", handler: nil)
            return
        }
        
        let password = self.password.text!.md5()
        
        Myself.password = password!
        Myself.UpdateToFirebase(alsoUpdateToPublic: false) { (error) in
            if error{
                self.showStandardAlertDialog(title: "Alert", msg: "Something Wrong!", handler: nil)
                return
            }
            UserDefaults.standard.set(password!, forKey: "password")
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        
        
    }
    
    
    /// Pop to root view controller
    /// - Parameter sender: UIButton referrance
    @IBAction func popAction(sender: UIButton){
        poptoRoot()
    }
    
    //let password = newPassword.text!.md5()
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
