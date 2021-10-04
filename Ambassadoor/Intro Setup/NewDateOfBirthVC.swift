//
//  NewDateOfBirthVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 04/10/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewDateOfBirthVC: UIViewController, CustomDatePickerDelegate {
    
    func pickedDate(date: Date) {
        NewAccount.dob = date.toUString()
        self.ageText.text = date.toString(dateFormat: "MM/dd/YY")
        birthdaySubtitle.text = "Birthday"
    }
    
    @IBOutlet weak var birthdaySubtitle: UILabel!
    @IBOutlet weak var ageText: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ageText.text = "Birthday"
        birthdaySubtitle.text = "Click to enter"
        NewAccount.dob = ""
        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickDOB(sender: Any){
        self.performSegue(withIdentifier: "toDOBSegue", sender: self)
    }
    
    @IBAction func nextAction(sender: UIButton){
        if NewAccount.dob == "" {
            self.showStandardAlertDialog(title: "Alert", msg: "Please enter your Born day") { action in
                
            }
            return
        }
        self.performSegue(withIdentifier: "toNewCreateAccountSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? CustomDatePickerVC{
            
            view.pickerDelegate = self
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
