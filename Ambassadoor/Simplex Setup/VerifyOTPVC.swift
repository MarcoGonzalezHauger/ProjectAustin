//
//  VerifyOTPVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 20/02/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

enum OTPProblem {
    case wrongOTP //iPhone not connected to the internet
    case noOTP //account for that email does not exist
    case noConnection
}

class VerifyOTPVC: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var verifyOTP: ShadowView!
    @IBOutlet weak var verifyOTPButton: UIButton!
    @IBOutlet weak var resendLinkButton: UIButton!
    @IBOutlet weak var textOTP: UITextField!{
        didSet {
            textOTP?.addDoneCancelToolbar(onDone: (target: self, action: #selector(verifyOTPAction(_:))))
        }
    }
    @IBOutlet weak var closeButton: UIButton!
    
    let defaultText = "Check email for Recovery Code"
    
    var dontAnimate = false
    var verifiedOTP = false
    var authenticationData = [String: AnyObject]()
    
    var otp: Int = 0
    var email: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        if !self.dontAnimate {
			self.SetLabelText(text: self.defaultText, animated: true)
        }
    }
    }
    
    func VerifyOTPNow() {
        
        if textOTP.text?.count != 0{
            
            if otp == Int(textOTP.text!){
                
                verificationPasswordSuccess()
                
            }else{
                verificationOTPFailed(reason: .wrongOTP)
            }
            
        }else{
            verificationOTPFailed(reason: .noOTP)
        }
        
    }
    
    @IBAction func resentOTPtoMail(sender: UIButton) {
        var username = ""
        var email = ""
        for (_,value) in authenticationData {
            username = value["username"] as! String
            email = value["email"] as! String
        }
        //let username = influencer!["username"] as! String
        let params = ["email":email,"username":username] as [String: AnyObject]
        verifyOTPButton.setTitle("Sending...", for: .normal)
        APIManager.shared.sendOTPtoUserService(params: params) { (status, error, data) in
            
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print("dataString=",dataString as Any)
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                
                _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if let code = json!["code"] as? Int {
                    
                    if code == 200 {
                        let otpCode = json!["otp"] as! Int
                        self.otp = otpCode
                        self.verificationOTPSentSuccess()
                        
                    }else{
                        
                        self.verificationOTPFailed(reason: .noConnection)
                        
                    }
                }
                
            }catch _ {
                
            }
            
            
            
        }
        
        
        
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func verifyOTPAction(_ sender: Any) {
        textOTP.resignFirstResponder()
        if verifiedOTP {
            dismiss(animated: true, completion: nil)
        } else {
            VerifyOTPNow()
        }
    }
    
    @IBAction func GoButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        VerifyOTPNow()
    }
    
    func verificationPasswordSuccess() {
        self.dontAnimate = true
        DispatchQueue.main.async {
            self.verifiedOTP = true
        UIView.animate(withDuration: 0.5) {
            self.textOTP.alpha = 0
            self.closeButton.alpha = 0
            self.resendLinkButton.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.textOTP.isHidden = true
            self.closeButton.isHidden = true
            self.performSegue(withIdentifier: "setpassword", sender: self.authenticationData)
        }
            self.infoLabel.textColor = .systemGreen
            self.SetLabelText(text: "Recovery Code Verified", animated: true)
            
        //resetPasswordButton.setTitle("Close", for: .normal)
        //resetPasswordButton.isEnabled = true
        }
    }
    
    func verificationOTPSentSuccess() {
        DispatchQueue.main.async {
            self.SetLabelText(text: "Send Recovery Code", animated: false)
            self.infoLabel.textColor = .systemGreen
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            UIView.transition(with: self.infoLabel, duration: 2, options: .transitionCrossDissolve, animations: {
                self.infoLabel.textColor = GetForeColor()
            }, completion: nil)
                self.SetLabelText(text: self.defaultText, animated: true)
                self.verifyOTPButton.setTitle("Verify", for: .normal)
                self.verifyOTPButton.isEnabled = true
         }
        }
    }
    
    func verificationOTPFailed(reason: OTPProblem) {
        //resetPasswordButton.setTitle("Reset Password", for: .normal)
        MakeShake(viewToShake: verifyOTP)
        
        SetLabelText(text: GetLabelTextFromIssue(reason: reason), animated: false)
        infoLabel.textColor = .red
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.transition(with: self.infoLabel, duration: 2, options: .transitionCrossDissolve, animations: {
                self.infoLabel.textColor = GetForeColor()
            }, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.SetLabelText(text: self.defaultText, animated: true)
                self.verifyOTPButton.isEnabled = true
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
    
    func GetLabelTextFromIssue(reason: OTPProblem?) -> String {
        switch reason {
        case .wrongOTP:
            return "Failed: Wrong OTP"
        case .noOTP:
            return "No OTP"
        case .noConnection:
            return "Something Happend!"
        default:
            return "Failed"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "setpassword"{
            
            let setPasswordController = segue.destination as! SetPasswordVC
            setPasswordController.authenticationData = self.authenticationData
            setPasswordController.userMail = self.email
            
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
