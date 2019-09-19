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
    var delegate: OfferResponse?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func OfferConfirmed(_ sender: Any) {
        
        
        let prntRef  = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(ThisOffer.offer_ID)
        prntRef.updateChildValues(["isAccepted":true])
        prntRef.updateChildValues(["status":"accepted"])

        dismiss(animated: true) { self.delegate?.OfferAccepted(offer: self.ThisOffer) }
    }
    
    @IBAction func cancel_Action(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
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
