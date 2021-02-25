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
    
    @IBAction func changeEmailAction(sender: UIButton){
        self.changeEmail()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        //self.updatePassword()
        self.email.resignFirstResponder()
        return true
    }
    
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
