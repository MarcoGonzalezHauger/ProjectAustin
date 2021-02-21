//
//  SetPasswordVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 20/02/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

enum passwordIssue {
    case noConnection //iPhone not connected to the internet
    case noPassword //Password empty
}

class SetPasswordVC: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    @IBOutlet weak var resetPasswordView: ShadowView!
    @IBOutlet weak var closeButton: UIButton!
    
    var dontAnimate = false
    var passwordWasReset = false
    var authenticationData = [String: AnyObject]()
    var userMail: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if !self.dontAnimate {
                self.SetLabelText(text: "Reset Password", animated: true)
            }
        }
    }
    
    @IBAction func textChanged(_ sender: Any) {
        if let sender = sender as? UITextField {
            if sender.text!.contains(" ") {
                sender.text = sender.text?.replacingOccurrences(of: " ", with: "")
            }
        }
    }
    
    func ResetPasswordNow() {
        dontAnimate = true
        resetPasswordButton.isEnabled = false
        resetPasswordButton.setTitle("Changing Password...", for: .normal)
        
        //[RAM] pretty much the same as the signinVC and CreateLoginVC.
        //Functions are: PasswordResetSuccess()
        //and: PasswordResetFailed(reason: passwordResetPorblem)
        //PasswordResetSuccess()
        
        if newPassword.text?.count != 0 {
			
			let password = newPassword.text!.md5()
			var userId = ""
			for (key,_) in self.authenticationData {
				userId = key
			}
            
			//updatePassword(userID: userId, password: password!)
            self.PasswordResetSuccess(userId: userId, emailID: self.userMail!, password: newPassword.text!)
			
        }else{
            PasswordResetFailed(reason: .noPassword)
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        if passwordWasReset {
            dismiss(animated: true, completion: nil)
        } else {
            ResetPasswordNow()
        }
    }
    
    @IBAction func returnButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.newPassword.resignFirstResponder()
    }
    
    @IBAction func GoButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        ResetPasswordNow()
    }
    
    let defaultText = "Reset Password"
    
    func PasswordResetSuccess(userId: String, emailID: String, password: String) {
        self.dontAnimate = true
        DispatchQueue.main.async {
            self.passwordWasReset = true
            UIView.animate(withDuration: 0.5) {
                    //self.EmailText.alpha = 0
                    self.newPassword.isHidden = true
                    self.closeButton.alpha = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                
 //               self.closeButton.isHidden = true
                
                //self.SetLabelText(text: "Password Reset Successfully", animated: true)
                
                if AccessToken.current != nil {
                    
                    self.getSingleUserDetails(userID: userId, email: emailID, password: password)
                    
                }else{
                    self.callIfAccessTokenExpired(userID: userId, usermail: emailID, password: password)
                }
                
            }
            
            self.infoLabel.textColor = .systemGreen
            self.SetLabelText(text: "Password Reset Successfully", animated: true)
            self.resetPasswordButton.setTitle("Logging In..", for: .normal)
            self.resetPasswordButton.isEnabled = true
        }
        
    }
    
    func PasswordResetFailed(reason: passwordIssue) {
        resetPasswordButton.setTitle("Reset Password", for: .normal)
        MakeShake(viewToShake: resetPasswordView)
        
        SetLabelText(text: GetLabelTextFromIssue(reason: reason), animated: false)
        infoLabel.textColor = .red
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.transition(with: self.infoLabel, duration: 2, options: .transitionCrossDissolve, animations: {
                self.infoLabel.textColor = GetForeColor()
            }, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.SetLabelText(text: self.defaultText, animated: true)
                self.resetPasswordButton.isEnabled = true
            }
        }
    }
    
    func SetLabelText(text textstring: String, animated: Bool) {
        if animated {
            let animation: CATransition = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.push
            animation.subtype = CATransitionSubtype.fromTop
            self.infoLabel.text = textstring
            animation.duration = 0.25
            self.infoLabel.layer.add(animation, forKey: CATransitionType.push.rawValue)
        } else {
            infoLabel.text = textstring
        }
    }
    
    func GetLabelTextFromIssue(reason: passwordIssue?) -> String {
        switch reason {
        case .noConnection:
            return "No Internet Connection"
        case .noPassword:
            return "No Password Entered"
        default:
            return "Failed"
        }
    }
    
    func LoginSuccessful() {
        
        self.infoLabel.text = "Welcome Back"
        self.infoLabel.textColor = .systemGreen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //self.delegate?.DismissNow(sender: "signin")
            let viewReference = instantiateViewController(storyboard: "Main", reference: "TabBarReference") as! TabBarVC
            downloadDataBeforePageLoad(reference: viewReference)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = viewReference
        }
        
    }
    
    func callIfAccessTokenExpired(userID: String, usermail: String, password: String) {
        
        API.facebookLoginAct(userIDBusiness: userID, owner: self) { (userDetail, longliveToken, error) in
            if error == nil {
                
                if let userDetailDict = userDetail as? [String: AnyObject]{
                    
                    if let id = userDetailDict["id"] as? String {
                        NewAccount.id = id
                    }
                    if let followerCount = userDetailDict["followers_count"] as? Int {
                        NewAccount.followerCount = Int64(followerCount)
                    }
                    if let name = userDetailDict["name"] as? String {
                        NewAccount.instagramName = name
                    }
                    if let pic = userDetailDict["profile_picture_url"] as? String {
                        NewAccount.profilePicture = pic
                    }
                    if let username = userDetailDict["username"] as? String {
                        NewAccount.instagramUsername = username
                    }
                    
                    NewAccount.authenticationToken = longliveToken!
                    //updateFirebaseProfileURL(profileUrl: NewAccount.profilePicture, id: NewAccount.id) { (url, status) in
                    updateFirebaseProfileURL(profileUrl: NewAccount.profilePicture, id: NewAccount.instagramUsername) { (url, status) in
                        
                        if status{
                            NewAccount.profilePicture = url!
                            self.updateLoginDetailsToServer(userID: userID, email: usermail, password: password)
                        }else{
                            self.updateLoginDetailsToServer(userID: userID, email: usermail, password: password)
                        }
                    }
                    
                    
                    
                }else{
                    self.showStandardAlertDialog(title: "Alert", msg: "Something is wrong! Please try again later. (Fx3)")
                }
                
            }else{
                print(error.debugDescription)
                self.showStandardAlertDialog(title: "Alert", msg: "Something is wrong! Please try again later. (Fx2)")
            }
        }
        
    }
    
    func updateLoginDetailsToServer(userID: String, email: String, password: String) {
        let userData: [String: Any] = [
            "id": NewAccount.id,
            "name": NewAccount.instagramName,
            "username": NewAccount.instagramUsername,
            "followerCount": NewAccount.followerCount,
            "profilePicture": NewAccount.profilePicture,
            "authenticationToken": NewAccount.authenticationToken,
            "tokenFIR":global.deviceFIRToken
        ]
        
        //updateUserDetails(userID: userID, userData: userData)
        
        self.getSingleUserDetails(userID: userID, email: email, password: password)
    }
    
    func getSingleUserDetails(userID: String, email: String, password: String) {
//        fetchSingleUserDetails(userID: userID) { (status, user) in
//            Yourself = user
//            //updateFirebaseProfileURL()
//            UserDefaults.standard.set(userID, forKey: "userID")
//            UserDefaults.standard.set(email, forKey: "email")
//            UserDefaults.standard.set(password, forKey: "password")
//            setHapticMenu(user: Myself)
//            AverageLikes(instagramID: userID, userToken: NewAccount.authenticationToken)
//            self.LoginSuccessful()
//
//        }
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
