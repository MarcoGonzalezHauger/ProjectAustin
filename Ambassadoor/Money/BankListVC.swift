//
//  BankListVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 22/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class BankDetalCell: UITableViewCell {
    
    @IBOutlet weak var shadowview: ShadowView!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var TimeLeft: UILabel!
    
}


class BankListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GlobalListener {
    
    var dwollaFSList = [DwollaCustomerFSList]()
    var StripeFSList = [StripeAccDetail]()


	@IBOutlet weak var withdrawOffset: NSLayoutConstraint!
	@IBOutlet weak var shelf: UITableView!
    @IBOutlet weak var emptybank_Lbl: UILabel!
    @IBOutlet weak var addBank_btn: UIButton!
	@IBOutlet weak var topView: ShadowView!
	var firstTime = true
	
    //MARK: Tableview datasource & delegates

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return global.AcceptedOffers.count + 1
        
        if self.StripeFSList.count == 0 {
			withdrawOffset.constant = 0
            addBank_btn.setTitle("Add Bank", for: .normal)
            //addBank_btn.isHidden = true
        }else{
			withdrawOffset.constant = -20
            addBank_btn.setTitle("Change Bank", for: .normal)
            //addBank_btn.isHidden = false
        }
		if !firstTime {
			UIView.animate(withDuration: 0.5) {
				self.topView.layoutIfNeeded()
			}
		}
		firstTime = false
        return self.StripeFSList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = shelf.dequeueReusableCell(withIdentifier: "bank") as! ConnectedPlaidTVCell
        //stripe
        let obj = self.StripeFSList[indexPath.row]
        cell.nameText.text = obj.access_token
//		cell.acctIDText.text = "****" + obj.stripe_user_id
        cell.acctIDText.text = "*************"
        cell.withdrawButton.tag = indexPath.row
        cell.withdrawButton.addTarget(self, action: #selector(self.withDrawAction(sender:)), for: .touchUpInside)
//        cell.transactionButton.tag = indexPath.row
//        cell.transactionButton.addTarget(self, action: #selector(self.transactionAction(sender:)), for: .touchUpInside)
       
        cell.withdrawButton.layer.cornerRadius = 5
        cell.withdrawButton.clipsToBounds = true
       
//        cell.transactionButton.layer.cornerRadius = 5
//        cell.transactionButton.clipsToBounds = true
        
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shelf.dataSource = self
        shelf.delegate = self
        global.delegates.append(self)
        
        // Do any additional setup after loading the view.
        if !Yourself.isBankAdded {
            emptybank_Lbl.isHidden = false
            shelf.isHidden = true
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "segueStripConnect", sender: self)
            }

        }else{
            emptybank_Lbl.isHidden = true
            shelf.isHidden = false
        }

    }
    
    @IBAction func withDrawAction(sender: UIButton){
        
		let fee = GetFeeForInfluencer(Yourself)
        
		let MoneyAmount = Yourself!.yourMoney - fee
		
		if MoneyAmount > 0 {
			let index = sender.tag
			
			let object = self.StripeFSList[index]
			
			self.performSegue(withIdentifier: "segueWithdraw", sender: object)
		}
		
        

       
//        self.createDwollaAccessTokenForFundTransfer(fundSource: object.customerFSURL, acctID: object.acctID, object: object)
    }
    
    @IBAction func transactionAction(sender: UIButton){
        
        self.performSegue(withIdentifier: "segueTransaction", sender: nil)
    }
    
       
    override func viewDidAppear(_ animated: Bool) {
//        if !Yourself.isBankAdded {
//            emptybank_Lbl.isHidden = false
//            shelf.isHidden = true
//            self.performSegue(withIdentifier: "segueStripConnect", sender: self)
//
//        }else{
//            emptybank_Lbl.isHidden = true
//            shelf.isHidden = false
//        }
        
//        getDwollaFundingSource { (object, status, error) in
//            if error == nil {
//                if object != nil {
//                    self.emptybank_Lbl.isHidden = true
//                    self.shelf.isHidden = false
//                    self.dwollaFSList = object!
//                    self.shelf.reloadData()
//                }
//            }
//        }
        
        getStripeAccDetails { (object, status, error) in
            if error == nil {
                if object != nil {
                    self.emptybank_Lbl.isHidden = true
                    self.shelf.isHidden = false
                    self.StripeFSList = object!
                    self.shelf.reloadData()
                }
            }
        }

    }
    
    @IBAction func addBank_Action(_ sender: Any) {
        
//        self.presentPlaid()
        
        self.performSegue(withIdentifier: "segueStripConnect", sender: self)
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toDwollaUserInfo"{
            if let destinationVC = segue.destination as? DwollaUserInformationVC{
                destinationVC.dwollaTokens = sender as! [String: AnyObject]
            }
        }else if segue.identifier == "segueWithdraw"{
            
            if let destinationVC = segue.destination as? PaymentSentVC{
                destinationVC.selectedBank = (sender as! StripeAccDetail)
            }
        }
    }
 

}

