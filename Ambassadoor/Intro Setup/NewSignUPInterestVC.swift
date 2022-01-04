//
//  NewSignUPInterestVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 16/09/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewSignUPInterestVC: UIViewController {
    
    var pickerviewdel: pickerViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    /// Check if choose any interest. segue to gender picker page.
    @IBAction func nextAction(){
        if pickerviewdel!.getInterests().count == 0 {
            //MakeShake(viewToShake: DoneButton, coefficient: 0.5)
            showStandardAlertDialog(title: "Interests", msg: "Please pick at least one interest.") { (action) in
            }
            return
        }
        
        NewAccount.categories = pickerviewdel!.getInterests()
        self.performSegue(withIdentifier: "toNewGenderPicker", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewInterestPicker" {
//            if let view = segue.destination as? InterestPickerVC {
//                pickerviewdel = view
//            }
            
            if let view = segue.destination as? PickInterests {
                pickerviewdel = view
                //view.pickedInterests = currentInterests
            }
        }
        
    }

}
