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
    var selectedBank:DwollaCustomerFSList?
    
    var MoneyAmount: Double = 0 {
        didSet {
            moneyAmountLabel.text = NumberToPrice(Value: MoneyAmount)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDoneOnKeyboard()
        paymentSuccessView.isHidden = true
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
            self.createDwollaAccessTokenForFundTransfer(fundSource: selectedBank!.customerFSURL, acctID: selectedBank!.acctID, object: selectedBank!)
        }

    }
    
    func createDwollaAccessTokenForFundTransfer(fundSource: String, acctID: String, object: DwollaCustomerFSList) {
        let amount = withdra_txt.text!
        let links = ["_links":["source":["href":API.superBankFundingSource],"destination":["href":fundSource]],"amount":["currency":"USD","value":amount]] as [String: AnyObject]
        let params = ["grant_type=":"client_credentials"] as [String: AnyObject]
        APIManager.shared.getDwollaAccessToken(params: params) { (status, error, data) in
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print("dataString=",dataString)
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if let accessToken = json!["access_token"] as? String {
                    
                    APIManager.shared.createFundTransfer(params: links, accessToken: accessToken) { (status, error, data, response) in
                        if error == nil {
                            
                            if let header = response as? HTTPURLResponse {
                                
                                if header.statusCode == 201 {
                                    
                                    let tranferDetail = header.allHeaderFields["Location"]! as! String
                                    
                                    let tranferID = tranferDetail.components(separatedBy: "/")
                                    
                                    fundTransferAccount(transferURL: tranferDetail, accountID: tranferID.last!, Obj: object, currency: "USD", amount: amount, date:getStringFromTodayDate())
                                    let old = Yourself.yourMoney
                                    let sub = Double(amount)
                                    let total = old - sub!
                                    //update to DB
                                    let prntRef  = Database.database().reference().child("users").child(Yourself.id)
                                    prntRef.updateChildValues(["yourMoney":total])
                                    
                                    withdrawUpdate(amount: sub!, from: Yourself.id, to: Yourself.id, id: tranferID.last!, status: "withdraw", type: "success", date:getStringFromTodayDate())
                                    
                                    DispatchQueue.main.async {
                                        Yourself.yourMoney = total
                                        self.moneyAmountLabel.text = NumberToPrice(Value: sub!)
                                        self.withdra_txt.resignFirstResponder()
                                        self.cancel_btn.isHidden = true
                                        self.withdrawView.isHidden = true
                                        self.paymentSuccessView.isHidden = false
                                    }
                                    
                                }
                                
                            }
                        }
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
