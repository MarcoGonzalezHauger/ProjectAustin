//
//  ChangeEmailVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 25/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ChangeEmailVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /// call change email method
    /// - Parameter sender: UIButton referrance
    @IBAction func changeEmailAction(sender: UIButton){
        self.changeEmail()
    }
    
    
    /// resign email textfield
    /// - Parameter textField: UITextField referrance
    /// - Returns: true or false
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        //self.updatePassword()
        self.email.resignFirstResponder()
        return true
    }
    
    
    /// Check if user entered valid email. check if user email exist. update changes to firebase. pop to root view controller
    func changeEmail() {
        if email.text?.count == 0 {
            showStandardAlertDialog(title: "Alert", msg: "Please enter the email", handler: nil)
            return
        }
        
        if !isValidEmail(emailStr: self.email.text!) {
           showStandardAlertDialog(title: "Alert", msg: "Please enter the valid email", handler: nil)
            return
        }
        
        checkNewIfEmailExist(email: self.email.text!, completion: { (exist) in
            
            if exist{
                self.showStandardAlertDialog(title: "Alert", msg: "This email already exist", handler: nil)
                return
            }
            
            Myself.email = self.email.text!.lowercased()
            Myself.UpdateToFirebase(alsoUpdateToPublic: false) { (error) in
                if error{
                    self.showStandardAlertDialog(title: "Alert", msg: "Something Wrong!", handler: nil)
                    return
                }
                UserDefaults.standard.set(Myself.email, forKey: "email")
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            
        })
    }
    
    /// Pop to root viewcontroller
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
