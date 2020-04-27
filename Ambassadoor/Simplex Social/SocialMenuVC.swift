//
//  SocialMenuVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 13/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol SocialSegmentDelegate {
    func socialSegmentIndex(index: Int)
}

enum SocialDescription: String {
    case Feed = "Social Updates", Following = "Who You're Follow", FollowedBy = "Who’s Following You"
    static var allValues = [Feed, Following, FollowedBy]
}

class SocialMenuVC: UIViewController,PageViewDelegate {
    
    func pageViewIndexDidChangedelegate(index: Int) {
        self.socialSegmentFilter.selectedSegmentIndex = index
        self.desText.text = SocialDescription.allValues[index].rawValue
		
    }
    
    @IBOutlet weak var desText: UILabel!
    
    @IBOutlet weak var socialSegmentFilter: UISegmentedControl!
    
    var socialPVCDelegate: SocialSegmentDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func segmentValueChange(sender: UISegmentedControl){
        self.socialPVCDelegate?.socialSegmentIndex(index: socialSegmentFilter.selectedSegmentIndex)
        self.desText.text = SocialDescription.allValues[socialSegmentFilter.selectedSegmentIndex].rawValue
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PageView"{
            let view = segue.destination as! SocialPVC
            self.socialPVCDelegate = view
            view.pageViewDidChange = self
        }
    }
    

}
