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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        //self.updatePassword()
        self.password.resignFirstResponder()
        return true
    }
    
    @IBAction func changePassword(sender: UIButton){
        self.password.resignFirstResponder()
        self.updatePassword()
    }
    
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
    
    @IBAction func popAction(sender: UIButton){
        performDismiss()
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
