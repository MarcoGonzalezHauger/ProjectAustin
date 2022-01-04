//
//  NewSetUpVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 16/09/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewSetUpVC: UIViewController {
    
    @IBOutlet weak var username: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.username.text = "\(NewAccount.instagramUsername)!!"
        // Do any additional setup after loading the view.
    }
    
    /// Let's Go action.
    /// - Parameter sender: UIButton Referrance
   @IBAction func DoneAction(sender: UIButton) {
        self.CreateAccount()
    }
    
    /// Check if user entered valid details. Check if user already exist in DB. Create new account.
    func CreateAccount() {
        //[RAM] Complete this function with creation of account
        
//        //if failed:
//        AccountCreationFailed(problem: .emailTaken)
//
//        //if success (this only dimisses the VCs):
//        AccountSuccessfullyCreated()
                
        if NewAccount.email == "" {
            AccountCreationFailed(problem: .emailTaken)
            return
        }
        
        if NewAccount.instagramUsername == ""{
            AccountCreationFailed(problem: .instaTaken)
            return
        }
        
        if NewAccount.zipCode == "" {
            AccountCreationFailed(problem: .noBasicInfo)
            return
        }
        
        var referralcodeString = ""
        referralcodeString.append(randomString(length: 6))
        let referral = referralcodeString.uppercased()
        NewAccount.referralCode = referral
        let uid = NewAccount.instagramUsername.replacingOccurrences(of: ".", with: ",")
        let NewUserID = uid + ", " + randomString(length: 15)
        checkNewIfUserExists(userID: NewUserID, instagramAuth: NewAccount.instagramAccountId) { (exist, user) in
            
            if exist{
                self.AccountCreationFailed(problem: .instaTaken)
            }else{
                Myself = user
                InitializeAmbassadoor()
                UserDefaults.standard.set(NewUserID, forKey: "userID")
                UserDefaults.standard.set(NewAccount.email, forKey: "email")
                UserDefaults.standard.set(NewAccount.password, forKey: "password")
                self.AccountSuccessfullyCreated()
            }
            
        }
        
        
    }
    
    /// Calculate average likes by post and likes count. Redirect to Tabbar controller.
    func AccountSuccessfullyCreated() {

        //self.delegate?.DismissNow(sender: "CreateAccount")
        AverageLikes(instagramID: Myself.instagramAccountId, userToken: Myself.instagramAuthToken)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //self.delegate?.DismissNow(sender: "signin")
            let viewReference = instantiateViewController(storyboard: "Main", reference: "TabBarReference") as! TabBarVC
            //downloadDataBeforePageLoad(reference: viewReference)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = viewReference
            
            NewAccount = NewAccountInfo.init(email: "", password: "", categories: [], gender: "", zipCode: "", instagramAccountId: "", instagramUsername: "", authenticationToken: "", averageLikes: 0, followerCount: 0, id: "", instagramName: "", profilePicture: "", referralCode: "", dob: "", isForTesting: false, referredBy: "")
            
        }
        
    }
    
    /// Account creation failed message
    /// - Parameter problem: CreateAccountProblem enum properties
        func AccountCreationFailed(problem: CreateAccountProblem) {
           // wasFailed = true
            
           // YouShallNotPass(SaveButtonView: CreateButtonView, returnColor: UIColor.init(named: "AmbDarkPurple")!)
            
            switch problem {
            case .emailTaken:
                NewAccount.email = ""
                self.showStandardAlertDialog(title: "Email Taken", msg: "The email address has been taken already.", handler: nil)
                break
            case .instaTaken:
                NewAccount.instagramUsername = ""
                self.showStandardAlertDialog(title: "Instagram Account Taken", msg: "This Instagram Account is already being used by another user.", handler: nil)
                break
            case .noConnection:
                self.showStandardAlertDialog(title: "No Connection", msg: "No communication with the Ambasadoor server.s", handler: nil)
                break
            case .noBasicInfo:
                self.showStandardAlertDialog(title: "No Basic Information Given", msg: "Please provide your basic information to Ambasadoor", handler: nil)
            }
            
        }
        
//        self.dismiss(animated: true) {
//
//        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
