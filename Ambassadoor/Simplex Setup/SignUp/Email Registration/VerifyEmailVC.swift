//
//  VerifyEmailVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 04/11/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class VerifyEmailVC: UIViewController {
    
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
    
    let defaultText = "Verify Your Email By OTP"
    
    var dontAnimate = false
    var verifiedOTP = false
    var authenticationData = [String: AnyObject]()
    
    var otp: Int = 0
    var email: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButton(_ sender: Any) {
        //dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
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
            //self.performSegue(withIdentifier: "setpassword", sender: self.authenticationData)
            accInfoUpdate()
            self.navigationController?.popToRootViewController(animated: true)
        }
            self.infoLabel.textColor = .systemGreen
            self.SetLabelText(text: "Email Confirm Code Verified", animated: true)
            
        //resetPasswordButton.setTitle("Close", for: .normal)
        //resetPasswordButton.isEnabled = true
        }
    }
    
    func verificationOTPSentSuccess() {
        DispatchQueue.main.async {
            self.SetLabelText(text: "Send Email Confirm Code", animated: false)
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
        self.verifyOTPButton.isEnabled = false
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
    //confirmEmailByOTP
    @IBAction func resentOTPtoMail(sender: UIButton) {
        
        let params = ["email":self.email,"username":""] as [String: AnyObject]
        verifyOTPButton.setTitle("Sending...", for: .normal)
        APIManager.shared.sendOTPtoUserServiceForConfirmEmail(params: params) { (status, error, data) in
            
            
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
