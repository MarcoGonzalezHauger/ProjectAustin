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
    
    override func awakeFromNib() {
        shadowview.cornerRadius = 15
        shadowview.ShadowOpacity = 0.2
        shadowview.ShadowRadius = 3
    }
    
}


class BankListVC: PlaidLinkEnabledVC, UITableViewDelegate, UITableViewDataSource, GlobalListener {
    
    override func handleSuccessWithToken(_ publicToken:String, institutionName:String, institutionID:String, acctID:String, acctName:String, metadata:[String:Any]?){
        
        NSLog("metadata: \(metadata ?? [:])")
        let current = ["publicToken":publicToken,"institutionName":institutionName,"institutionID":institutionID,"acctID":acctID,"acctName":acctName] as! [String: Any]
        
//        let ref = Database.database().reference().child("InfluencerBanks")
//        let userReference = ref.child(Yourself.id)
//        let userData = API.serializeUser(user: userfinal!, id: userfinal!.id)
//        userReference.updateChildValues(userData)
        
        let ref = Database.database().reference().child("InfluencerBanks").child(Yourself.id)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.childrenCount)
            
            if let banksList = snapshot.value as? NSMutableArray{
                var final = banksList as! [[String:Any]]

                var bankdata:[String:[String: Any]] = [:]
                let ref = Database.database().reference().child("InfluencerBanks")
                let userData = API.serializeBank(bank: Bank.init(dictionary: current))
                final.append(userData)
                bankdata[Yourself.id] = userData
                ref.updateChildValues(bankdata)
                
            }else{
                var bankdata:[String:[String: Any]] = [:]
                let ref = Database.database().reference().child("InfluencerBanks")
                let userData = API.serializeBank(bank: Bank.init(dictionary: current))
                bankdata[Yourself.id] = userData
                ref.updateChildValues(bankdata)
            }
            
           
        })

        
    }

    @IBOutlet weak var shelf: UITableView!
    @IBOutlet weak var emptybank_Lbl: UILabel!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return global.AcceptedOffers.count + 1
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = shelf.dequeueReusableCell(withIdentifier: "bank") as! BankDetalCell
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shelf.dataSource = self
        shelf.delegate = self
        global.delegates.append(self)

        // Do any additional setup after loading the view.

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !Yourself.isBankAdded {
            emptybank_Lbl.isHidden = false
            shelf.isHidden = true
        }else{
            emptybank_Lbl.isHidden = true
            shelf.isHidden = false
        }

    }
    
    @IBAction func addBank_Action(_ sender: Any) {
        
        self.presentPlaid()
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

