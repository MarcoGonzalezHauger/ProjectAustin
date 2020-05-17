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
    @IBOutlet weak var withdrawView: UIView!
    
	@IBOutlet weak var feeAmount_lbl: UILabel!
	@IBOutlet weak var cancel_btn: UIButton!
    @IBOutlet weak var yourMoney_lbl: UILabel!
//    var selectedBank:DwollaCustomerFSList?
    var selectedBank : StripeAccDetail?

    
    var MoneyAmount: Double = 0 {
        didSet {
			if MoneyAmount < 0 {
				self.dismiss(animated: true, completion: nil)
			}
			yourMoney_lbl.text = NumberToPrice(Value: MoneyAmount, enforceCents: true)
        }
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setDoneOnKeyboard()
        paymentSuccessView.isHidden = true
		view.bringSubviewToFront(paymentSuccessView)
        self.cancel_btn.isHidden = false
		let fee = GetFeeForInfluencer(Yourself)
        
		MoneyAmount = Yourself!.yourMoney - fee
		feeAmount_lbl.text = "Ambassadoor will take \(NumberToPrice(Value: fee)).\nIf you earn more money, we will still only take \(NumberToPrice(Value: fee)) when you withdraw."

        print("yourMony=\(Yourself!.yourMoney)")
	}
	func setDoneOnKeyboard() {
		let keyboardToolbar = UIToolbar()
		keyboardToolbar.sizeToFit()
		let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PaymentSentVC.dismissKeyboard))
		keyboardToolbar.items = [flexBarButton, doneBarButton]
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	@IBAction func Dismissed(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	// this action amount transfer to admin account To Influencer bank account. and update user money value and added user transaction detail in FIR
	@IBAction func submit_Action(_ sender: Any) {
		//            self.createDwollaAccessTokenForFundTransfer(fundSource: selectedBank!.customerFSURL, acctID: selectedBank!.acctID, object: selectedBank!)
		
		
		//calculation for OSC for user
		var subAmount:Double = 0.0
		//we WILL NOT penalize influencers for not using our service!
		//let pendingMonths = Date.getmonthsBetweenDate(startDate: Date.getDateFromString(date: Yourself.lastPaidOSCDate)!, endDate: Date.getDateFromString(date: Date.getCurrentDate())!)
		let feeAmount = GetFeeForInfluencer(Yourself)
		let withdrawAmount = MoneyAmount - Double(feeAmount)
		print("fee=\(feeAmount)")
		print(withdrawAmount)
		
		subAmount = withdrawAmount + Double(feeAmount)
				
		let finaltotalAmount = 0
		
		///I really upgraded security here. ~Marco
		
		//first, make a reference to yourself in firebase.
		let ref = Database.database().reference().child("users").child(Yourself.id)
		
		
		ref.observeSingleEvent(of: .value, with: {(snapshot) in
			if let userInfo = snapshot.value as? [String: AnyObject] {
				
				
				//first, we see if the "yourMoney" value is accurate.
                do {
                let tempYourself = try User.init(dictionary: userInfo)
				if tempYourself.yourMoney == Yourself.yourMoney {
					//If it is, set yourMoney to zero.

					ref.updateChildValues(["yourMoney": 0]) { (error, DatabaseReference) in
						if error == nil {
							//If yourMoney was sucessfully set to zero, then proceed with the bank withdraw.
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
												Yourself.yourMoney = 0
												self.moneyAmountLabel.text = NumberToPrice(Value: subAmount)
												self.cancel_btn.isHidden = true
												self.withdrawView.isHidden = true
												self.paymentSuccessView.isHidden = false
											}
										}
									}
								}catch _ {
								}
							}
						}
					}
				} else {
					let alert = UIAlertController(title: "Nice Try (;", message: "Very creative though.\n~Marco, CTO", preferredStyle: .alert)
					
					alert.addAction(UIAlertAction(title: "Aw man...", style: .default, handler: { (ui) in
						self.dismiss(animated: true, completion: nil)
					}
					))
					
					self.present(alert, animated: true)
				}
                
                } catch let error {
                    print(error)
                }
			}
		}, withCancel: nil)
	}
		
}
