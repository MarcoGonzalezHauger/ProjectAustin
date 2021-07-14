//
//  NewWithdrawVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 18/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class NewWithdrawVC: UIViewController {
    
    @IBOutlet weak var amt: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.amt.text = NumberToPrice(Value: Myself.finance.balance)
        // Do any additional setup after loading the view.
    }
    @IBAction func cancel_Action(_ sender: Any) {
        self.performDismiss()
    }
    
    @IBAction func withdrawAction(sender: UIButton){
        
        let ref = Database.database().reference().child("Accounts/Private/Influencers").child(Myself.userId)
        
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
        if let userInfo = snapshot.value as? [String: Any] {
            
            let influencer = Influencer.init(dictionary: userInfo, userId: Myself.userId)
            
            if influencer.finance.balance == 0 {
                self.showStandardAlertDialog(title: "No Money to Withdraw", msg: "Earn money by completing Offers.")
                return
            }
            
            var subAmount:Double = 0.0
            let feeAmount = GetFeeForNewInfluencer(influencer)
            let withdrawAmount = influencer.finance.balance - Double(feeAmount)
            print("fee=\(feeAmount)")
            print(withdrawAmount)
            subAmount = withdrawAmount + Double(feeAmount)
            
            if withdrawAmount < 0 {
				self.showStandardAlertDialog(title: "Not enough to Withdraw", msg: "You must earn at least \(NumberToPrice(Value: GetFeeForNewInfluencer(Myself), enforceCents: true)) to withdraw due to Stripe transaction fees.")
                return
            }
                    
            let finaltotalAmount = 0
            let balanceUpdateRef = Database.database().reference().child("Accounts/Private/Influencers").child(Myself.userId).child("finance")
            balanceUpdateRef.updateChildValues(["balance": 0]) { (error, DatabaseReference) in
            if error == nil {
                
                let params = ["accountID": Myself.finance.stripeAccount?.stripeUserId as Any,"amount": subAmount * 100, "mode": "test"] as [String: AnyObject]
                APIManager.shared.withdrawThroughStripe(params: params) { (status, error, data) in
                    
                    
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    print("dataString=",dataString as Any)
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                        
                        
                        _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        
                        if let code = json!["code"] as? Int {
                            
                            if code == 401 {
                                let message = json!["message"] as! [String:Any]
                                self.showStandardAlertDialog(title: "Failed", msg: message["code"] as! String)
                                balanceUpdateRef.updateChildValues(["balance": influencer.finance.balance]) { (error, DatabaseReference) in
                                }
                            }else{
                                //update to DB
                                balanceUpdateRef.updateChildValues(["balance":finaltotalAmount])
                                var transID = ""
                                if let withDrawIDObj = json!["result"] as? [String: AnyObject] {
                                    if let withDrawID = withDrawIDObj["id"] as? String{
                                        transID = withDrawID
                                    }
                                }
                                
                                let logDict = ["time":Date().toUString(),"type": "withdraw", "value":withdrawAmount] as [String : Any]
                                let log = InfluencerTransactionLogItem.init(dictionary: logDict, userID: Myself.userId, transactionId: transID)
                                updateNewTransLog(transID: transID, userID: Myself.userId, log: log.toDictionary())
                                Myself.finance.log.append(log)
                                
                                DispatchQueue.main.async {
                                    Myself.finance.balance = 0
                                    self.performSegue(withIdentifier: "fromNewWithToNote", sender: withdrawAmount)
                                }
                            }
                        }
                    }catch _ {
                    }
                }
                
            }
            }
        }
        }, withCancel: nil)
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? WithDrawNoteVC{
            view.withDrawAmount = sender as! Double
        }
    }
    

}
