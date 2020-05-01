//
//  OfferAcceptConfirmVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 19/09/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class OfferAcceptConfirmVC: UIViewController {

    var ThisOffer: Offer!
	var Confirmdelegate: ConfirmPage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
	
	@IBAction func confirmButtonDown(_ sender: Any) {
		UseTapticEngine()
	}
	
    //If user agree and confirm the offer. we need to update offer expire date, offer status and isaccepted status to FIR
    @IBAction func OfferConfirmed(_ sender: Any) {
        if let incresePay = ThisOffer.incresePay {
        let pay = calculateCostForUser(offer: ThisOffer, user: Yourself, increasePayVariable: incresePay)
        updateIsAcceptedOffer(offer: ThisOffer, money: pay)
        }else{
        let pay = calculateCostForUser(offer: ThisOffer, user: Yourself)
        updateIsAcceptedOffer(offer: ThisOffer, money: pay)
        }
        
        //updateIsAcceptedOffer(offer: ThisOffer, money: )
        
        updateUserIdOfferPool(offer: ThisOffer)
        
//        self.sendPushNotificationToFollowers()
//
//        fetchBusinessUserDetails(userID: ThisOffer.ownerUserID) { (status, deviceFIR) in
//
//            if status {
//                let params = ["token":deviceFIR,"offer":self.ThisOffer.title,"influencer":Yourself.username]
//
//                self.sendAcceptedOfferPushNotification(params: params as [String : AnyObject])
//            }
//
//        }

        dismiss(animated: true) {
			self.Confirmdelegate?.dismissPage()
		}
    }
    
    
    func sendPushNotificationToFollowers() {
        
        if Yourself.following != nil{
        getFilteredUsers(userIDs: Yourself.following!) { (status, users, tokens) in
            
            if status {
                
                if tokens!.count != 0 {
                
                getCompanyDetails(id: self.ThisOffer.ownerUserID) { (status, company) in
                    
                    if status {
                        //let exTok = ["frHTI-BeSlU:APA91bG3cWKn9Yz99l1Dn1LpRv72EH8ontH57Vjaf3nQLYhH0LhgnwC2xH1PP3WT6SXNu3X-YQjDwYHSyWX42x5_foNu7JFA_kA0FyB7LPbjzgZ0I_uuTpL3w3PpxrUDFmCa2_gPkGCc"]
                    let params = ["tokens":tokens!,"company":company!.name,"username":Yourself.username] as [String : AnyObject]
                    self.sendNotificationToFollowingUsers(params:params)
                        
                    }
                    
                }
                    
                }
                
                
            }else{
                
            }
            
        }
        }
    }
    
    func sendAcceptedOfferPushNotification(params: [String: AnyObject]){
        
        let urlString = "https://us-central1-amassadoor.cloudfunctions.net/" + "acceptedOfferNotificationToBusinessUser"
        
        let url = URL(string: urlString)!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "Post"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("result=",dataString!)
            
        }
        task.resume()
    }
    
    func sendNotificationToFollowingUsers(params: [String: AnyObject]){
        
        let urlString = "https://us-central1-amassadoor.cloudfunctions.net/" + "sendNotificationToMultipleUsers"
        
        let url = URL(string: urlString)!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "Post"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("result=",dataString!)
            
        }
        task.resume()
    }
    
    @IBAction func cancel_Action(_ sender: Any) {
        dismiss(animated: true, completion: nil)
		
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
