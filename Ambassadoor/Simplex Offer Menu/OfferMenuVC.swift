//
//  OfferMenuVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 03/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol OfferMenuSegmentDelegate {
    func segmentIndex(index: Int)
}

class OfferMenuVC: UIViewController {
    
    @IBOutlet weak var offerSegmentFilter: UISegmentedControl!
    
    var offerPVCDelegate: OfferMenuSegmentDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func segmentValueChange(sender: UISegmentedControl){
        self.offerPVCDelegate?.segmentIndex(index: offerSegmentFilter.selectedSegmentIndex)
        //let adddd = self.children[0] as! OfferVC
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PageView"{
            let view = segue.destination as! OffersPVC
            self.offerPVCDelegate = view
        }
    }
   

}
