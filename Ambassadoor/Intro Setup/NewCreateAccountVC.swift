//
//  NewCreateAccountVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 16/09/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol OTPDismissed {
    func otpdismissed()
}

class NewCreateAccountVC: UIViewController, UITextFieldDelegate, OTPDismissed {
    func otpdismissed() {
        //self.performSegue(withIdentifier: "toNewSetup", sender: self)
        self.performSegue(withIdentifier: "toNewReferelConfirm", sender: self)
    }
    
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmpass: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var scroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.text = NewAccount.instagramUsername
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    /// return error text.
    /// - Parameter reason: Pass AccountNameProblem enum property
    /// - Returns: error text
    func GetLabelTextFromIssue(reason: AccountNameProblem?) -> String {
        switch reason {
        case .noEmail:
            return "Failed: No Email"
        case .noPassword:
            return "Failed: No Password"
        case .noConnection:
            return "No Internet Connection"
        case .emailExists:
            return "Email Already in Use"
        case .badEmailFormat:
            return "Invalid Email"
        case .weakPassword:
            return "Password is Too Weak"
        case .passwordContainsAmbassadoor:
            return "Password Very Insecure!"
        case .passNoMatch:
            return "Passwords Don't Match"
        default:
            return "Failed"
        }
    }
    
    
    /// Check if user entered valid password, email, and check if user entered email already exist or not. send otp to email.
    /// - Parameter sender: UIButton referrance
    @IBAction func nextAction(sender: UIButton){
        
        if password.text?.count == 0 {
            self.showStandardAlertDialog(title: "alert", msg:  GetLabelTextFromIssue(reason: .noPassword)) { action in
            }
            return
        }
        
        if password.text != confirmpass.text {
            self.showStandardAlertDialog(title: "alert", msg:  GetLabelTextFromIssue(reason: .passNoMatch)) { action in
            }
            return
        }
        
        if email.text?.count == 0{
            
            self.showStandardAlertDialog(title: "alert", msg:  GetLabelTextFromIssue(reason: .noEmail)) { action in
            }
            return
            
        }
        
        if !isValidEmail(emailStr: email.text!){
            self.showStandardAlertDialog(title: "alert", msg:  GetLabelTextFromIssue(reason: .badEmailFormat)) { action in
            }
            return
        }
        
        if password.text?.count == 0 {
            self.showStandardAlertDialog(title: "alert", msg:  GetLabelTextFromIssue(reason: .noPassword)) { action in
            }
            return
        }
        
        let complexity = isMeetingComplexity(password: password.text!)
        
        if complexity == 1 {
            self.showStandardAlertDialog(title: "alert", msg:  GetLabelTextFromIssue(reason: .weakPassword)) { action in
            }
            return
        }
        
        if complexity == 2 {
            self.showStandardAlertDialog(title: "alert", msg:  GetLabelTextFromIssue(reason: .passwordContainsAmbassadoor)) { action in
            }
            return
        }
        
        checkNewIfEmailExist(email: email.text!.lowercased()) { (isExist) in
            
            if isExist{
                
                self.showStandardAlertDialog(title: "alert", msg:  self.GetLabelTextFromIssue(reason: .emailExists)) { action in
                }
                
            }else{
                
                NewAccount.email = self.email.text!.lowercased()
                NewAccount.password = self.password.text!.md5()
                self.resentOTPtoMail(email: NewAccount.email)
            }
            
        }
        
    }
    
    /// Send OTP to user email to verify the mail
    /// - Parameter email: User Email
    func resentOTPtoMail(email: String) {
        let params = ["email":email,"username":""] as [String: AnyObject]
        APIManager.shared.sendOTPtoUserServiceForConfirmEmail(params: params) { (status, error, data) in
            
            if data != nil {
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print("dataString=",dataString as Any)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                
                _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if let code = json!["code"] as? Int {
                    
                    if code == 200 {
                    let otpCode = json!["otp"] as! Int
                        
                        //self.userEmail = email
                        
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "fromNewCreateAcc", sender: otpCode)
                        }
                        
                    }else{
                        
                    }
                }
                
            }catch _ {
                
            }
            
            }else{
                self.showStandardAlertDialog(title: "Alert", msg: "Something wrong!. Try again later.") { action in
                    
                }
            }
            
        }
        
        
        
    }
    
    
    /// resign text field
    /// - Parameter textField: UITextField referrance
    /// - Returns: true or false
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    /// Adjust scroll view as per Keyboard Height if the keyboard hides textfiled.
    /// - Parameter notification: keyboardWillShowNotification reference
    @objc func keyboardWasShown(notification : NSNotification) {
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height + 25
        self.scroll.contentInset = contentInset
        
    }
    ///   Getback scroll view to normal state
    /// - Parameter notification: keyboardWillHideNotification reference
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scroll.contentInset = contentInset
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromNewCreateAcc"{
            let viewController = segue.destination as! VerifyEmailVC
            viewController.dismisDelegate = self
            viewController.otp = sender as! Int
            viewController.email = NewAccount.email
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
