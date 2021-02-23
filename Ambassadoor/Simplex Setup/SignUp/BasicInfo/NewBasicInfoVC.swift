//
//  NewBasicInfoVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 22/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewBasicInfoVC: UIViewController, EnterZipCode, CustomDatePickerDelegate {
    func pickedDate(date: Date) {
        NewAccount.dob = date.toUString()
        let age = Calendar.current.dateComponents([.year], from: date, to: Date())
        self.ageText.text = "\(age.year ?? 0)"
    }
    
    
    @IBOutlet weak var zipCodeText: UILabel!
    @IBOutlet weak var genderText: UILabel!
    @IBOutlet weak var ageText: UILabel!
    
    var pickerviewdel: pickerViewDelegate?
    
    let datePickerView:UIDatePicker = UIDatePicker()
    
    var dobString: String?
    
    
    func ZipCodeEntered(zipCode: String?) {
        
        self.zipCodeText.text = zipCode?.count == nil || zipCode?.count == 0 ? "ZIP CODE" : zipCode
        NewAccount.zipCode = (zipCode?.count == nil || zipCode?.count == 0 ? "" : zipCode)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func zipCodePressed(_sender: Any){
        self.performSegue(withIdentifier: "fromBasicInfo", sender: self)
    }
    
    @IBAction func genderPressed(_sender: Any){
        self.pickGender()
    }
    
    @IBAction func dobPressed(_sender: Any){
        
        self.performSegue(withIdentifier: "fromBasicToDate", sender: self)
    }
    
    func pickGender() {
        let genderPick = UIAlertController(title: "Pick Gender", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        
        let female = UIAlertAction(title: "Female", style: .default) { (action: UIAlertAction) in
            NewAccount.gender = "Female"
            self.genderText.text = "Female"
        }
        
        let male = UIAlertAction(title: "Male", style: .default) { (action: UIAlertAction) in
            NewAccount.gender = "Male"
            self.genderText.text = "Male"
        }
        
        let other = UIAlertAction(title: "Other...", style: .default) { (action: UIAlertAction) in
            let alert = UIAlertController(title: "Enter Your Gender", message: "", preferredStyle: .alert)

            alert.addTextField { (textField) in
                textField.placeholder = "Gender"
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let text = alert!.textFields![0].text!
                if text != "" {
                    NewAccount.gender = text
                    self.genderText.text = text
                }
            }))

            self.present(alert, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        genderPick.addAction(female)
        genderPick.addAction(male)
        genderPick.addAction(other)
        genderPick.addAction(cancelAction)
        self.present(genderPick, animated: true, completion: nil)
    }

    @IBAction func doneAction(){
        
        if NewAccount.zipCode != "" {
            if NewAccount.gender != "" {
                if NewAccount.dob != ""{
                    
                    let newInt = pickerviewdel!.getInterests()
                    if newInt.count > 0 {
                        
                        NewAccount.categories = pickerviewdel!.getInterests()
                        accInfoUpdate()
                        self.dismiss(animated: true, completion: nil)
                        
                    }else{
                        self.showStandardAlertDialog(title: "Alert", msg: "Pick any Interest") { (action) in
                            
                        }
                    }
                    
                }else{
                    self.showStandardAlertDialog(title: "Alert", msg: "Enter the Birthday") { (action) in
                        
                    }
                }
            }else{
                self.showStandardAlertDialog(title: "Alert", msg: "Enter the Gender") { (action) in
                    
                }
            }
        }else{
            self.showStandardAlertDialog(title: "Alert", msg: "Enter ZIP CODE") { (action) in
                
            }
        }
        
       
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? ZipCodeVC {
            view.delegate = self
        }
        if segue.identifier == "interestpickerembed" {
            if let view = segue.destination as? InterestPickerVC {
                pickerviewdel = view
            }
        }
        if let view = segue.destination as? CustomDatePickerVC{
            
            view.pickerDelegate = self
        }
    }
    

}
