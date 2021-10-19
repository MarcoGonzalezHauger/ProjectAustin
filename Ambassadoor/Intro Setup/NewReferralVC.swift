//
//  NewReferralVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 28/07/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewReferralVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var referralText: UITextField!
    
    @IBOutlet weak var scroll: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if globalBasicInfluencers.count == 0 {
            RefreshPublicData {
                
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification : NSNotification) {
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height + 25
        self.scroll.contentInset = contentInset
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scroll.contentInset = contentInset
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func checkIfreferApplied() {
        if self.referralText.text!.count == 0 {
            showStandardAlertDialog(title: "Alert", msg: "Please enter valid referral code") { action in
            }
            return
        }
        let referralByUser = globalBasicInfluencers.filter { $0.referralCode.lowercased() == self.referralText.text!.lowercased()}
        if referralByUser.count == 0{
            showStandardAlertDialog(title: "Alert", msg: "Please enter valid referral code") { action in
                
            }
            return
        }
        
        NewAccount.referredBy = referralByUser.first!.userId
        self.performSegue(withIdentifier: "toFinalScreen", sender: self)
    }
    
    @IBAction func nextAction(sender: UIButton){
        checkIfreferApplied()
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
