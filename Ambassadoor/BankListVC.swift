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
    
    var dwollaFSList = [DwollaCustomerFSList]()
    
    override func handleSuccessWithToken(_ publicToken:String, institutionName:String, institutionID:String, acctID:String, acctName:String, metadata:[String:Any]?){
        
        NSLog("metadata: \(metadata ?? [:])")
//        let current = ["publicToken":publicToken,"institutionName":institutionName,"institutionID":institutionID,"acctID":acctID,"acctName":acctName] as! [String: Any]
        
//        let ref = Database.database().reference().child("InfluencerBanks")
//        let userReference = ref.child(Yourself.id)
//        let userData = API.serializeUser(user: userfinal!, id: userfinal!.id)
//        userReference.updateChildValues(userData)
        
        
//        let ref = Database.database().reference().child("InfluencerBanks").child(Yourself.id)
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            print(snapshot.childrenCount)
//
//            if let banksList = snapshot.value as? NSMutableArray{
//                var final = banksList as! [[String:Any]]
//
//                var bankdata:[String:[String: Any]] = [:]
//                let ref = Database.database().reference().child("InfluencerBanks")
//                let userData = API.serializeBank(bank: Bank.init(dictionary: current))
//                final.append(userData)
//                bankdata[Yourself.id] = userData
//                ref.updateChildValues(bankdata)
//
//            }else{
//                var bankdata:[String:[String: Any]] = [:]
//                let ref = Database.database().reference().child("InfluencerBanks")
//                let userData = API.serializeBank(bank: Bank.init(dictionary: current))
//                bankdata[Yourself.id] = userData
//                ref.updateChildValues(bankdata)
//            }
//
//
//        })
        
        let current = ["publictoken":publicToken,"accountid":acctID] as [String: AnyObject]
        if let accountArray = metadata!["accounts"] as? NSArray{
            if let accountDictionary = accountArray[0] as? NSDictionary{
                global.dwollaCustomerInformation.mask = accountDictionary["mask"] as! String
            }
            
        }
        global.dwollaCustomerInformation.acctID = acctID
        global.dwollaCustomerInformation.name = acctName
        self.getProcessorToken(params: current)

        
    }
    
    
    
    func getProcessorToken(params: [String: AnyObject]) {
        
        APIManager.shared.getDwollaProcessorToken(params: params) { (status, error, data) in
            
            //            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //
            //            print("dataString=",dataString)
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                //                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if let statusCode = json!["code"] as? Int {
                    
                    if statusCode == 200 {
                        
                        if let processorToken = json!["result"] as? String {
                            
                            self.createDwollaAccessToken(token: processorToken)
                            
                            
                        }
                    }
                }
                
            }catch _ {
                
            }
            
        }
        
    }
    
    
    func createDwollaAccessToken(token: String) {
        let params = ["grant_type=":"client_credentials"] as [String: AnyObject]
        APIManager.shared.getDwollaAccessToken(params: params) { (status, error, data) in
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print("dataString=",dataString as Any)
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if let accessToken = json!["access_token"] as? String {
                    
                    DispatchQueue.main.async(execute: {
                        let segueData = ["dpToken":token,"dAccessToken":accessToken]
                        
                        self.performSegue(withIdentifier: "toDwollaUserInfo", sender: segueData)
                    })
                    
                    //                    self.createFundingSourceForCustomer(dpToken: token, dAccessToken: accessToken)
                    
                }
                
            }catch _ {
                
            }
        }
        
    }
    
    
    

    @IBOutlet weak var shelf: UITableView!
    @IBOutlet weak var emptybank_Lbl: UILabel!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return global.AcceptedOffers.count + 1
        return self.dwollaFSList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = shelf.dequeueReusableCell(withIdentifier: "bank") as! ConnectedPlaidTVCell
        let obj = self.dwollaFSList[indexPath.row]
        cell.nameText.text = obj.name
        cell.acctIDText.text = "****" + obj.mask
        cell.withdrawButton.tag = indexPath.row
        cell.withdrawButton.addTarget(self, action: #selector(self.withDrawAction(sender:)), for: .touchUpInside)
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shelf.dataSource = self
        shelf.delegate = self
        global.delegates.append(self)
        
        

        // Do any additional setup after loading the view.

    }
    
    @IBAction func withDrawAction(sender: UIButton){
        
        let index = sender.tag
        
        let object = self.dwollaFSList[index]
        self.createDwollaAccessTokenForFundTransfer(fundSource: object.customerFSURL, acctID: object.acctID, object: object)
    }
    
    func createDwollaAccessTokenForFundTransfer(fundSource: String, acctID: String, object: DwollaCustomerFSList) {
        
        let links = ["_links":["source":["href":API.superBankFundingSource],"destination":["href":fundSource]],"amount":["currency":"USD","value":"100"]] as [String: AnyObject]
        let params = ["grant_type=":"client_credentials"] as [String: AnyObject]
        getDwollaAccessToken(params: params) { (status, error, data) in
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print("dataString=",dataString)
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if let accessToken = json!["access_token"] as? String {
                    
                    self.createFundTransfer(params: links, accessToken: accessToken) { (status, error, data, response) in
                        if error == nil {
                            
                            if let header = response as? HTTPURLResponse {
                                
                                if header.statusCode == 201 {
                                    
                                    let tranferDetail = header.allHeaderFields["Location"]! as! String
                                    
                            let tranferID = tranferDetail.components(separatedBy: "/")
                                    
                            fundTransferAccount(transferURL: tranferDetail, accountID: tranferID.last!, Obj: object, currency: "USD", amount: "100")
                                    
                                    
                                    
                                    
                                }
                                
                            }
                        }
                    }
                }
                
            }catch _ {
                
            }
        }
        
        
    }
    
    func getDwollaAccessToken(params: [String: AnyObject],completion: @escaping (_ status: String, _ error: String?, _ dataValue: Data?) -> Void) {
        
        let urlString = "https://api-sandbox.dwolla.com/token"
        
        let url = URL(string: urlString)
        
        let para = "grant_type=client_credentials"
        let postData = NSMutableData(data: para.data(using: String.Encoding.utf8)!)
        
        
        let credentials = API.kDwollaClient_id + ":" + API.kDwollaClient_secret
        
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        request.httpMethod = "Post"
        request.httpBody = postData as Data
        let credentialData = credentials.data(using: String.Encoding.utf8)
        let base64 = credentialData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic " + base64, forHTTPHeaderField: "Authorization")
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request) {
            (
            data, response, error) in
            if (error != nil && data != nil) {
                
                completion("failure", error?.localizedDescription ?? "error", data)
            }
            else if (error != nil || data == nil){
                completion("failure", error?.localizedDescription ?? "error", nil)
            }
            else{
                
                completion("success",nil,data!)
            }
            
        }
        
        task.resume()
        
    }
    
    
    func createFundTransfer(params: [String: AnyObject],accessToken: String,completion: @escaping (_ status: String, _ error: String?, _ dataValue: Data?,_ response: URLResponse?) -> Void) {
        
        let urlString = API.kFundTransferURL
        
        let url = URL(string: urlString)
        
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        request.httpMethod = "Post"
        request.setValue("application/vnd.dwolla.v1.hal+json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.dwolla.v1.hal+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        //NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        let task = session.dataTask(with: request) {
            (
            data, response, error) in
            if (error != nil && data != nil) {
                
                completion("failure", error?.localizedDescription ?? "error", data,nil)
            }
            else if (error != nil || data == nil){
                completion("failure", error?.localizedDescription ?? "error", nil,nil)
            }
            else{
                //                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                completion("success",nil,data!,response)
            }
            
        }
        
        task.resume()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if !Yourself.isBankAdded {
//            emptybank_Lbl.isHidden = false
//            shelf.isHidden = true
//        }else{
//            emptybank_Lbl.isHidden = true
//            shelf.isHidden = false
//        }
        
        getDwollaFundingSource { (object, status, error) in
            if error == nil {
                if object != nil {
                    self.emptybank_Lbl.isHidden = true
                    self.shelf.isHidden = false
                    self.dwollaFSList = object!
                    self.shelf.reloadData()
                }
            }
        }

    }
    
    @IBAction func addBank_Action(_ sender: Any) {
        
        self.presentPlaid()
        
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
        }
    }
 

}

