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
    
    @IBAction func OfferConfirmed(_ sender: Any) {
        
        
        let prntRef  = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(ThisOffer.offer_ID)
		let dayCount = ThisOffer.posts.count * 2
		var expireDate = Date.getStringFromDate(date: Date().afterDays(day: dayCount))!
		if ThisOffer.offer_ID == "XXXDefault" {
			let foreverDate = 365 * 1000
			expireDate = Date.getStringFromDate(date: Date().afterDays(day: foreverDate))!
		}
        
        prntRef.updateChildValues(["expiredate":expireDate])
        prntRef.updateChildValues(["isAccepted":true])
        prntRef.updateChildValues(["status":"accepted"])
        

        dismiss(animated: true) {
			self.Confirmdelegate?.dismissPage()
		}
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
