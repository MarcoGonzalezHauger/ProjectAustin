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
		self.ageText.text = date.toString(dateFormat: "MM/dd/YY")
		birthdaySubtitle.text = "Birthday"
    }
    
    
    @IBOutlet weak var zipCodeText: UILabel!
    @IBOutlet weak var genderText: UILabel!
    @IBOutlet weak var ageText: UILabel!
	
	@IBOutlet weak var genderSubtitle: UILabel!
	@IBOutlet weak var zipCodeSubtitle: UILabel!
	@IBOutlet weak var birthdaySubtitle: UILabel!
	
	
    var pickerviewdel: pickerViewDelegate?
    
    let datePickerView:UIDatePicker = UIDatePicker()
    
    var dobString: String?
    
	@IBOutlet weak var DoneButton: UIButton!
	
    func ZipCodeEntered(zipCode: String?) {
		
		if let zipCode = zipCode {
			if zipCode != "" {
				self.zipCodeText.text = zipCode
				NewAccount.zipCode = zipCode
				
				GetTownName(zipCode: zipCode) { (data, zip) in
					if let data = data {
						self.zipCodeSubtitle.text = data.CityAndStateName
					}
				}
			}
		}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
		
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
			self.genderSubtitle.text = "Gender"
        }
        
        let male = UIAlertAction(title: "Male", style: .default) { (action: UIAlertAction) in
            NewAccount.gender = "Male"
            self.genderText.text = "Male"
			self.genderSubtitle.text = "Gender"
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
					self.genderSubtitle.text = "Gender"
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

    @IBAction func doneAction() {
		
		if NewAccount.zipCode == "" {
			MakeShake(viewToShake: DoneButton, coefficient: 0.5)
			showStandardAlertDialog(title: "ZIP Code", msg: "Please enter your ZIP Code.") { (action) in
			}
			return
		}
		
		if NewAccount.gender == "" {
			MakeShake(viewToShake: DoneButton, coefficient: 0.5)
			showStandardAlertDialog(title: "Gender", msg: "Please pick your Gender.") { (action) in
			}
			return
		}
		
		if NewAccount.dob == "" {
			MakeShake(viewToShake: DoneButton, coefficient: 0.5)
			showStandardAlertDialog(title: "Birthday", msg: "Please enter your Birthday.") { (action) in
			}
			return
		}
        
		if pickerviewdel!.getInterests().count == 0 {
			MakeShake(viewToShake: DoneButton, coefficient: 0.5)
			showStandardAlertDialog(title: "Interests", msg: "Please pick at least one interest.") { (action) in
			}
			return
		}
		
		NewAccount.categories = pickerviewdel!.getInterests()
		accInfoUpdate()
		self.dismiss(animated: true, completion: nil)
		
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
