//
//  WithDrawNoteVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 18/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class WithDrawNoteVC: UIViewController {
    
    @IBOutlet weak var amt: UILabel!
    
    var withDrawAmount: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amt.text = NumberToPrice(Value: withDrawAmount)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancel_Action(_ sender: Any) {
        self.performDismiss()
    }
    
    @IBAction func dismisAction(sender: UIButton){
        
        if let viewTab = self.view.window?.rootViewController as? TabBarVC{
            if let viewPage = viewTab.viewControllers![1] as? NewProfilePage{
                viewPage.loadFromMyself()
                viewPage.dismiss(animated: true, completion: nil)
            }
        }
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
