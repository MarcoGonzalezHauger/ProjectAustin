//
//  TransactionListVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 12/09/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class TransactionDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowview: ShadowView!
    @IBOutlet weak var amount_Lbl: UILabel!
    @IBOutlet weak var date_Lbl: UILabel!
    @IBOutlet weak var fee_Lbl: UILabel!
    @IBOutlet weak var status_Lbl: UILabel!
    @IBOutlet weak var type_Lbl: UILabel!

    
    override func awakeFromNib() {
        shadowview.cornerRadius = 15
        shadowview.ShadowOpacity = 0.2
        shadowview.ShadowRadius = 3
    }
    
}

class TransactionListVC: UIViewController,UITableViewDataSource, UITableViewDelegate {
    

    var transactionHistoryList = [TransactionHistory]()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getTransactionHistory { (object, status, error) in
            if error == nil {
                if object != nil {
                    self.transactionHistoryList = object!
                    self.shelf.reloadData()
                }
            }
        }
    }
    @IBOutlet weak var shelf: UITableView!
    
    @IBAction func cancel_Action(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: tableview datasource and delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.transactionHistoryList.count
    }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = shelf.dequeueReusableCell(withIdentifier: "transaction") as! TransactionDetailTableViewCell
            
            //stripe
            let obj = self.transactionHistoryList[indexPath.row]
            cell.type_Lbl.text = obj.type
            cell.amount_Lbl.text = String(obj.Amount)
            cell.fee_Lbl.text = String(obj.fee)
            cell.status_Lbl.text = obj.status
            cell.date_Lbl.text = obj.createdAt
//            cell.nameText.text = obj.access_token
            
            
            return cell
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
