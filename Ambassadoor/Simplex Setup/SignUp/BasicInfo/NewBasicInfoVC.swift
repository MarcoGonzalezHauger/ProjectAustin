//
//  NewBasicInfoVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 22/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewBasicInfoVC: UIViewController, EnterZipCode {
    
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
    
    func setDatePicker(dateChooserAlert: UIAlertController) {
        datePickerView.frame = CGRect.init(x: 0, y: 10, width: dateChooserAlert.view.frame.size.width, height: 300)
        var components = DateComponents()
        components.year = -18
        let maxDate = Calendar.current.date(byAdding: components, to: Date())
        datePickerView.maximumDate = maxDate
        datePickerView.datePickerMode = UIDatePicker.Mode.date
//        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
    }
    
    func convertDateToAge(date: Date) {
        NewAccount.dob = date.toUString()
        let age = Calendar.current.dateComponents([.year], from: date, to: Date())
        self.ageText.text = "\(age.year ?? 0)"
    }
    
    @IBAction func zipCodePressed(_sender: Any){
        self.performSegue(withIdentifier: "fromBasicInfo", sender: self)
    }
    
    @IBAction func genderPressed(_sender: Any){
        self.pickGender()
    }
    
    @IBAction func dobPressed(_sender: Any){
        let dateChooserAlert = UIAlertController(title: "Choose Date.", message: nil, preferredStyle: .actionSheet)
        self.setDatePicker(dateChooserAlert: dateChooserAlert)
        dateChooserAlert.view.addSubview(datePickerView)
        dateChooserAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
            self.convertDateToAge(date: self.datePickerView.date)
        }))
        let height: NSLayoutConstraint = NSLayoutConstraint(item: dateChooserAlert.view as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 350)
        dateChooserAlert.view.addConstraint(height)
        self.present(dateChooserAlert, animated: true, completion: nil)
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
        }else if segue.identifier == "interestpickerembed" {
            if let view = segue.destination as? InterestPickerVC {
                pickerviewdel = view
            }
        }
    }
    

}
