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
    @IBOutlet weak var primeCat_Txt: UITextField!
    @IBOutlet weak var zipcode_Txt: UITextField!
    @IBOutlet weak var gender_Txt: UITextField!
    
	@IBOutlet weak var townNameLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		townNameLabel.text = ""
		
        // Do any additional setup after loading the view.
        self.setDoneOnKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
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
        } else if textField == zipcode_Txt {
            return true
        } else {
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
	
	@IBAction func textChanged(_ sender: Any) {
		if let text = zipcode_Txt.text {
			GetTownName(zipCode: text) { (TownName, zipCode) in
				if self.zipcode_Txt.text == zipCode {
					self.townNameLabel.text = TownName ?? ""
				}
			}
		}
	}
	
    @IBAction func submitTapped(_ sender: Any) {
        
        
		if userfinal!.categories == nil {
            self.showStandardAlertDialog(title: "Alert!", msg: "You must choose at least one category before progessing.")
        } else if gender_Txt.text!.isEmpty {
            self.showStandardAlertDialog(title: "Alert!", msg: "You must choose your gender before progessing.")
        } else if zipcode_Txt.text!.isEmpty {
            self.showStandardAlertDialog(title: "Alert!", msg: "You must enter your Zip Code before progessing. We will not sell this information.")
        } else {
            
            userfinal?.zipCode = zipcode_Txt.text!
            userfinal?.gender = TextToGender(gender: gender_Txt.text!)
            
            userfinal?.joinedDate = Date.getCurrentDate()
            userfinal?.isDefaultOfferVerify = false
            
//            var referralcodeString = ""
            
//            //user name first and last character
//            if let firstChar = userfinal?.name?.first{
//                referralcodeString.append(firstChar)
//            }
//            if let lastChar = userfinal?.name?.last {
//                referralcodeString.append(lastChar)
//            }
//
            //user dateofbirth
//            let date = getDateFromString(date: (userfinal?.joinedDate!)!)
//
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yy"
//            let yearString = dateFormatter.string(from: date)
//
//            dateFormatter.dateFormat = "MM"
//            let monthString = dateFormatter.string(from: date)
//
//            dateFormatter.dateFormat = "dd"
//            let dayString = dateFormatter.string(from: date)
//
//            referralcodeString.append(dayString)
//            referralcodeString.append(monthString)
//            referralcodeString.append(yearString)
            
            //random four digit code
//            referralcodeString.append(randomString(length: 6))
            
            
            updateUserDataToFIR(user: userfinal!){ (user) in
                
//                    userfinal?.referralcode = referralcodeString.uppercased()
//
//                    let ref = Database.database().reference().child("users")
//                    let userReference = ref.child(userfinal!.id)
//                    let userData = API.serializeUser(user: userfinal!, id: userfinal!.id)
//                    userReference.updateChildValues(userData)
                    
//                    let categoryReference = ref.child("categories")
//
//                    var dict: [Int: String] = [:]
//                    var i: Int = 0
//                    for cat in user.categories! {
//                        dict[i] = cat
//                        i += 1
//                    }
//
//                    categoryReference.updateChildValues(dict)
                        
                    Yourself = user
                    UserDefaults.standard.set(API.INSTAGRAM_ACCESS_TOKEN, forKey: "token")
                    UserDefaults.standard.set(Yourself.id, forKey: "userid")
                
                //create default offer
                createDefaultOffer(userID: user.id){ (bool) in
                    
                    self.dismiss(animated: false) {
                        self.delegate?.dismissed(success: true)
                    }
                }
                    
//                    //insertd Default offers
//                    let refDefaultOffer = Database.database().reference().child("SentOutOffersToUsers").child(user.id)
//                    let postID = refDefaultOffer.childByAutoId().key
//                    let offerData = API.serializeDefaultOffer(offerID:"XXXDefault", postID: postID! ,userID:user.id)
//                
//                    
//                    /*
//                    READ : NOTE BY MARCO
//                    I have edited this section of code so that the getOfferList function will only be activated after the default offer as been created by putting the code in the Completion Block. This was probably the "button not working" error.
//                    */
//                    refDefaultOffer.updateChildValues(["XXXDefault":offerData], withCompletionBlock: { (error, databaseref) in
//                        var youroffers: [Offer] = []
//                        // ****
//                        //naveen added
//                        getOfferList { (Offers) in
//                            //                print(Offers.count)
//                            youroffers = Offers
//                            //                                global.AvaliableOffers = youroffers.filter({$0.isAccepted == false})
//                            //                                global.AcceptedOffers = youroffers.filter({$0.isAccepted == true})
//                            global.AvaliableOffers = youroffers.filter({$0.status == "available"})
//                            global.AvaliableOffers = GetSortedOffers(offer: global.AvaliableOffers)
//                            global.AcceptedOffers = youroffers.filter({$0.status == "accepted"})
//                            global.AcceptedOffers = GetSortedOffers(offer: global.AcceptedOffers)
//                            global.RejectedOffers = youroffers.filter({$0.status == "rejected"})
//                            
//                            self.dismiss(animated: false) {
//                                self.delegate?.dismissed(success: true)
//                            }
//                            
//                        }
//                    })
                
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
			var cats: [Category] = []
			if let doCat = userfinal!.categories  {
				cats = StringsToCategories(strings: doCat)
			}
			
			destination.SetupPicker(originalCategories: cats) { (cat) in
				let newCats = CategoriesToStrings(categories: cat)
				self.userfinal!.categories = newCats
				self.primeCat_Txt.text = GetCategoryStringFromlist(categories:  newCats)
            }
            
        }
        
    }
  

}
