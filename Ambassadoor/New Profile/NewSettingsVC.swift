//
//  NewSettingsVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/5/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import MessageUI

protocol NewSettingsDelegate {
    func GoIntoEditMode()
}


class NewSettingsVC: UIViewController, MFMailComposeViewControllerDelegate {
    
    var webviewUrl: String = ""
    var resetAccountTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.alwaysBounceVertical = false
        loadProfileSettings()
    }
    
    func loadProfileSettings() {
        invisibleSwitch.isOn = Myself.basic.checkFlag("isInvisible")
    }
    
    @IBAction func legalInfoAction(sender: UIButton){
        self.webviewUrl = sender.tag == 0 ? API.termsUrl : API.privacyUrl
        self.performSegue(withIdentifier: "toLegalWebview", sender: self)
    }
    
    @IBOutlet weak var invisibleSwitch: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    var delegate: NewSettingsDelegate?
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editMyProfile(_ sender: Any) {
        delegate?.GoIntoEditMode()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        if invisibleSwitch.isOn {
            Myself.basic.AddFlag("isInvisible")
        } else {
            Myself.basic.RemoveFlag("isInvisible")
        }
        Myself.UpdateToFirebase(alsoUpdateToPublic: true, completed: nil)
    }
    
    func getTittle(tag: Int) -> (String, String) {
        switch tag {
        case 0:
            return ("Help -","xxxx")
        case 1:
            return ("Bug Report","")
        default:
            return ("Feature Suggestion","")
        }
    }
    
    
    
    @IBAction func sendEmail(sender: UIButton) {
        
        let emailContent = self.getTittle(tag: sender.tag)
        //let toRecipents = []
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailContent.0)
        mc.setMessageBody(emailContent.1, isHTML: false)
        //mc.setToRecipients(toRecipents)
        
        if MFMailComposeViewController .canSendMail(){
            self.present(mc, animated: true, completion: nil)
        }else if let mailUrl = createEmailUrl(to: API.supportEmail, subject: emailContent.0){
            
            if UIApplication.shared.canOpenURL(mailUrl){
                UIApplication.shared.open(mailUrl)
            }
            
        }
        
        
    }
    
    private func createEmailUrl(to: String, subject: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        
        return defaultUrl
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail sent failure: \(error?.localizedDescription)")
        default:
            break
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetAccountAction(sender: UIButton){
        resetAccountTag = sender.tag
        sender.isUserInteractionEnabled = false
        self.ResetPasswordNow(b: sender)
    }
    
    func ResetPasswordNow(b: UIButton) {
        
        let params = ["email":Myself.email,"username":Myself.basic.username] as [String: AnyObject]
        APIManager.shared.sendOTPtoUserService(params: params) { (status, error, data) in
            DispatchQueue.main.async {
                b.isUserInteractionEnabled = true
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print("dataString=",dataString as Any)
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                
                let re = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                print(re)
                
                if let code = json!["code"] as? Int {
                    
                    if code == 200 {
                        let otpCode = json!["otp"] as! Int
                        DispatchQueue.main.async {
                            
                            self.performSegue(withIdentifier: "toResetAccount", sender: otpCode)
                        }
                        
                    }else{
                        
                        
                    }
                }else{
                    
                }
                
            }catch _ {
                
            }
            
            
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? WebViewVC {
            view.urlString = self.webviewUrl
        }else if let view = segue.destination as? AccountResetVC{
            view.identifyTag = resetAccountTag
            view.otpCode = sender as! Int
        }
    }
    
}
