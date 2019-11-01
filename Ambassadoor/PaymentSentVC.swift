//
//  PaymentSentVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 24/09/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class PaymentSentVC: UIViewController {
    

    //successView
    @IBOutlet weak var moneyAmountLabel: UILabel!
    @IBOutlet weak var paymentSuccessView: UIView!
    @IBOutlet weak var withdrawView: ShadowView!
    
    @IBOutlet weak var cancel_btn: UIButton!
    @IBOutlet weak var yourMoney_lbl: UILabel!
    @IBOutlet weak var withdra_txt: UITextField!
//    var selectedBank:DwollaCustomerFSList?
    var selectedBank : StripeAccDetail?

    
    var MoneyAmount: Double = 0 {
        didSet {
            moneyAmountLabel.text = NumberToPrice(Value: MoneyAmount)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDoneOnKeyboard()
        paymentSuccessView.isHidden = true
        self.cancel_btn.isHidden = false
        moneyAmountLabel.text = NumberToPrice(Value: Yourself!.yourMoney)
        yourMoney_lbl.text = NumberToPrice(Value: Yourself!.yourMoney)

        print("yourMony=\(Yourself!.yourMoney)")
    }
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PaymentSentVC.dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        withdra_txt.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func Dismissed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submit_Action(_ sender: Any) {
        
        if withdra_txt.text!.isEmpty {
            self.showStandardAlertDialog(title: "Alert!", msg: "Please enter your withdraw amount")
        }else if Yourself.yourMoney < Double(withdra_txt.text!)!{
            self.showStandardAlertDialog(title: "Alert!", msg: "don't have enough money in your account")
        }else{
//            self.createDwollaAccessTokenForFundTransfer(fundSource: selectedBank!.customerFSURL, acctID: selectedBank!.acctID, object: selectedBank!)
            

            //calculation for OSC for user
           var subAmount:Double = 0.0
           let pendingMonths = Date.getmonthsBetweenDate(startDate: Date.getDateFromString(date: Yourself.lastPaidOSCDate)!, endDate: Date.getDateFromString(date: Date.getCurrentDate())!)
           let feeAmount = pendingMonths * GetFeeFromFollowerCount(FollowerCount: Yourself.followerCount)!
           let withdrawAmount = Double(self.withdra_txt.text!)!
           print("fee=\(feeAmount)")
            print(withdrawAmount)
//           DispatchQueue.main.async {
               subAmount = withdrawAmount + Double(feeAmount)
//           }
            
            if  Yourself.yourMoney < subAmount && feeAmount > 0 {
                self.showStandardAlertDialog(title: "Alert", msg: "This transaction including monthly fee amount  $\(feeAmount). So you don't have enough money in your account")
            }else{
                let finaltotalAmount = Yourself.yourMoney - subAmount
                
                var msg = "Do you want to withdraw $\(subAmount) from your account ?"
                if feeAmount > 0 {
                    msg = "This transaction including monthly fee amount $\(feeAmount). Totally we will debit $\(subAmount) from your account"
                }
                 
                 let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "proceed", style: .default, handler: { (action) in
                     let params = ["accountID":self.selectedBank!.stripe_user_id,"amount":subAmount * 100] as [String: AnyObject]
                                 APIManager.shared.withdrawThroughStripe(params: params) { (status, error, data) in
                                     
                                     let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                                     
                                     print("dataString=",dataString as Any)
                                     do {
                                         let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                                         
                                         
                                         _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                                         
                                         if let code = json!["code"] as? Int {
                                             
                                             if code == 401 {
                                                 let message = json!["message"] as! [String:Any]
                                                 self.showStandardAlertDialog(title: "Alert", msg: message["code"] as! String)
                                             }else{
                                                 //update to DB
                                                 let prntRef  = Database.database().reference().child("users").child(Yourself.id)
                                                 prntRef.updateChildValues(["yourMoney":finaltotalAmount])
                                                prntRef.updateChildValues(["lastPaidOSCDate":Date.getCurrentDate()])

                                                 withdrawUpdate(amount: withdrawAmount,fee:Double(feeAmount), from: Yourself.id, to: Yourself.id, id: self.selectedBank!.stripe_user_id, status: "success", type: "withdraw", date:getStringFromTodayDate())
                                                

                                                 DispatchQueue.main.async {
                                                     Yourself.yourMoney = finaltotalAmount
                                                     self.moneyAmountLabel.text = NumberToPrice(Value: subAmount)
                                                     self.withdra_txt.resignFirstResponder()
                                                     self.cancel_btn.isHidden = true
                                                     self.withdrawView.isHidden = true
                                                     self.paymentSuccessView.isHidden = false
                                                 }
                                             }
                                         }
                                         
                                     }catch _ {
                                         
                                     }
                                     
                                 }
                 }))
                 alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                     
                 }))
                 
                 DispatchQueue.main.async {
                     self.present(alert, animated: true, completion: nil)
                 }
            }
            

    
            
        }

    }
    
//    func createDwollaAccessTokenForFundTransfer(fundSource: String, acctID: String, object: DwollaCustomerFSList) {
//        let amount = withdra_txt.text!
//        let links = ["_links":["source":["href":API.superBankFundingSource],"destination":["href":fundSource]],"amount":["currency":"USD","value":amount]] as [String: AnyObject]
//        let params = ["grant_type=":"client_credentials"] as [String: AnyObject]
//        APIManager.shared.getDwollaAccessToken(params: params) { (status, error, data) in
//            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//
//			print("dataString=",dataString ?? "nil")
//            do {
//                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
//
//				_ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//
//                if let accessToken = json!["access_token"] as? String {
//
//                    APIManager.shared.createFundTransfer(params: links, accessToken: accessToken) { (status, error, data, response) in
//                        if error == nil {
//
//                            if let header = response as? HTTPURLResponse {
//
//                                if header.statusCode == 201 {
//
//                                    let tranferDetail = header.allHeaderFields["Location"]! as! String
//
//                                    let tranferID = tranferDetail.components(separatedBy: "/")
//
//                                    fundTransferAccount(transferURL: tranferDetail, accountID: tranferID.last!, Obj: object, currency: "USD", amount: amount, date:getStringFromTodayDate())
//                                    let old = Yourself.yourMoney
//                                    let sub = Double(amount)
//                                    let total = old - sub!
//                                    //update to DB
//                                    let prntRef  = Database.database().reference().child("users").child(Yourself.id)
//                                    prntRef.updateChildValues(["yourMoney":total])
//
//                                    withdrawUpdate(amount: sub!, fee: <#Double#>, from: Yourself.id, to: Yourself.id, id: tranferID.last!, status: "withdraw", type: "success", date:getStringFromTodayDate())
//
//                                    DispatchQueue.main.async {
//                                        Yourself.yourMoney = total
//                                        self.moneyAmountLabel.text = NumberToPrice(Value: sub!)
//                                        self.withdra_txt.resignFirstResponder()
//                                        self.cancel_btn.isHidden = true
//                                        self.withdrawView.isHidden = true
//                                        self.paymentSuccessView.isHidden = false
//                                    }
//
//                                }
//
//                            }
//                        }
//                    }
//                }
//
//            }catch _ {
//
//            }
//        }
//
//
//    }
    
    

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
