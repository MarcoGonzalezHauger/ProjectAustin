 //
//  OtherInfoVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 08/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class OtherInfoVC: UIViewController, UITextFieldDelegate {
    var delegate: ConfirmationReturned?
    var userfinal: User?
    var selectedID: String!
    var curcat: Category?



    @IBOutlet weak var secondaryCat_Txt: UITextField!
    @IBOutlet weak var primeCat_Txt: UITextField!
    @IBOutlet weak var zipcode_Txt: UITextField!
    @IBOutlet weak var gender_Txt: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setDoneOnKeyboard()
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == primeCat_Txt {
            self.performSegue(withIdentifier: "otherinfoToCatSegue", sender: nil)
            selectedID = "main_cat"
            return false
        }else if textField == secondaryCat_Txt{
            selectedID = "second_cat"
            self.performSegue(withIdentifier: "otherinfoToCatSegue", sender: nil)
            return false
        }else if textField == zipcode_Txt{
            return true
        }else{
            // create an actionSheet
            let actionSheetController: UIAlertController = UIAlertController(title: "Choose Gender", message: nil, preferredStyle: .actionSheet)
            
            // create an action
            let MaleAction: UIAlertAction = UIAlertAction(title: "Male", style: .default) { action -> Void in
                
                print("Male Action pressed")
                self.gender_Txt.text = "Male"
            }
            
            let FemaleAction: UIAlertAction = UIAlertAction(title: "Female", style: .default) { action -> Void in
                
                print("Female Action pressed")
                self.gender_Txt.text = "Female"

            }
            
            let OtherAction: UIAlertAction = UIAlertAction(title: "Other", style: .default) { action -> Void in
                
                print("Other Action pressed")
                self.gender_Txt.text = "Other"

            }
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
            
            // add actions
            actionSheetController.addAction(MaleAction)
            actionSheetController.addAction(FemaleAction)
            actionSheetController.addAction(OtherAction)
            
            actionSheetController.addAction(cancelAction)
            
            
            // present an actionSheet...
            // present(actionSheetController, animated: true, completion: nil)   // doesn't work for iPad
            
            actionSheetController.popoverPresentationController?.sourceView = gender_Txt // works for both iPhone & iPad
            
            present(actionSheetController, animated: true) {
                print("option menu presented")
            }
            return false
        }
        
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        
        
        if primeCat_Txt.text!.isEmpty {
            self.showStandardAlertDialog(title: "Alert!", msg: "Please select PrimaryCategory")
        }else if secondaryCat_Txt.text!.isEmpty{
            self.showStandardAlertDialog(title: "Alert!", msg: "Please select SecondaryCategory")
        }else if gender_Txt.text!.isEmpty{
            self.showStandardAlertDialog(title: "Alert!", msg: "Please select Gender")
        }else if gender_Txt.text!.isEmpty{
            self.showStandardAlertDialog(title: "Alert!", msg: "Please enter the zipcode")
        }else{
            userfinal?.primaryCategory = Category(rawValue: primeCat_Txt.text!)!
            userfinal?.SecondaryCategory = Category(rawValue: secondaryCat_Txt.text!)!
            userfinal?.zipCode = Int(zipcode_Txt.text!)
            userfinal?.gender = TextToGender(gender: gender_Txt.text!)

            let ref = Database.database().reference().child("users")
            let userReference = ref.child(userfinal!.id)
            let userData = API.serializeUser(user: userfinal!, id: userfinal!.id)
            userReference.updateChildValues(userData)
            self.dismiss(animated: false) {
                self.delegate?.dismissed(success: false)
            }
        }
        

    }

    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(OtherInfoVC.dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        zipcode_Txt.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? CategoryPicker {
            destination.SetupPicker(originalCategory: curcat) { (cat) in
                if self.selectedID == "main_cat" {
                    Yourself.primaryCategory = cat
                } else if self.selectedID == "second_cat" {
                    Yourself.SecondaryCategory = cat
                }
            }
        }
        
    }
  

}
