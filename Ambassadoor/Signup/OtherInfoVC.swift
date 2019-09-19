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

    @IBOutlet weak var category_Lbl: UILabel!
    @IBOutlet weak var baseScrollView: UIScrollView!
    @IBOutlet weak var secondaryCat_Txt: UITextField!
    @IBOutlet weak var primeCat_Txt: UITextField!
    @IBOutlet weak var zipcode_Txt: UITextField!
    @IBOutlet weak var gender_Txt: UITextField!
    
    @IBOutlet weak var secCatTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var secCatHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secCatTxtTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var secCatTxtHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setDoneOnKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        //minimum category of 6.
        if GetTierFromFollowerCount(FollowerCount: userfinal!.followerCount) ?? 0 > 6 {
           category_Lbl.text = "First Category"
        }else{
            secCatTopConstraint.constant = 0
            secCatHeightConstraint.constant = 0
            secCatTxtTopConstraint.constant = 0
            secCatTxtHeightConstraint.constant = 0
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.baseScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        baseScrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        baseScrollView.contentInset = contentInset
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
            self.showStandardAlertDialog(title: "Alert!", msg: "Please select a \(category_Lbl.text!)")
        } else if secondaryCat_Txt.text!.isEmpty && GetTierFromFollowerCount(FollowerCount: userfinal!.followerCount) ?? 0 > 6 {
            self.showStandardAlertDialog(title: "Alert!", msg: "Please select a Second Category")
        } else if gender_Txt.text!.isEmpty {
            self.showStandardAlertDialog(title: "Alert!", msg: "Please select your Gender")
        } else if zipcode_Txt.text!.isEmpty {
            self.showStandardAlertDialog(title: "Alert!", msg: "Please enter your ZIP code")
        } else {
            userfinal?.primaryCategory = Category(rawValue: primeCat_Txt.text!)!
            userfinal?.SecondaryCategory =
                secondaryCat_Txt.text! == "" ? nil : Category(rawValue: secondaryCat_Txt.text!)!
            userfinal?.zipCode = zipcode_Txt.text!
            userfinal?.gender = TextToGender(gender: gender_Txt.text!)
            
            userfinal?.joinedDate = Date.getCurrentDate()

            let ref = Database.database().reference().child("users")
            let userReference = ref.child(userfinal!.id)
            let userData = API.serializeUser(user: userfinal!, id: userfinal!.id)
            userReference.updateChildValues(userData)
            Yourself = userfinal
            UserDefaults.standard.set(API.INSTAGRAM_ACCESS_TOKEN, forKey: "token")
            UserDefaults.standard.set(Yourself.id, forKey: "userid")

            // ****
            //naveen added
            var youroffers: [Offer] = []
            getOfferList { (Offers) in
//                print(Offers.count)
                youroffers = Offers
                //                                global.AvaliableOffers = youroffers.filter({$0.isAccepted == false})
                //                                global.AcceptedOffers = youroffers.filter({$0.isAccepted == true})
                global.AvaliableOffers = youroffers.filter({$0.status == "available"})
                global.AcceptedOffers = youroffers.filter({$0.status == "accepted"})
                global.RejectedOffers = youroffers.filter({$0.status == "rejected"})
                                
                    self.dismiss(animated: false) {
                        self.delegate?.dismissed(success: false)
                    }

            }
            // *********
//            self.dismiss(animated: false) {
//                self.delegate?.dismissed(success: false)
//            }
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
                    self.userfinal!.primaryCategory = cat
                    self.primeCat_Txt.text = cat.rawValue
                } else if self.selectedID == "second_cat" {
                    self.userfinal!.SecondaryCategory = cat
                    self.secondaryCat_Txt.text = cat.rawValue

                }
            }
            
        }
        
    }
  

}
