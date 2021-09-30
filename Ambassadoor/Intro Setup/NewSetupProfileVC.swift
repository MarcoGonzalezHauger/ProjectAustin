//
//  NewSetupProfileVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 28/07/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewSetupProfileVC: UIViewController {
    
    @IBOutlet weak var connectBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var Step2View: ShadowView!
    
    func noIGConnect() {
        print("noIG")
        showStandardAlertDialog(title: "Connection Failed", msg: "No Instagram account was connected to this Facebook profile.") { (aa) in
            MakeShake(viewToShake: self.Step2View)
        }
        //you don't have an instagram account connected.
    }
    
    func noFBPConnect() {
        print("noFBP")
        showStandardAlertDialog(title: "Connection Failed", msg: "You must create a Facebook Page that is connected to your Instagram account to connect to Ambassadoor.") { (aa) in
            MakeShake(viewToShake: self.Step2View)
        }
        //You don't have a facebook page connected to the instagram account!!
    }
    
    @IBAction func connectAction(){
        
        AccessToken.current = nil
        Profile.current = nil
        self.getFBBusinessAccount()
    }
    
    func getFBBusinessAccount() {
        self.connectBtn.setTitle("CONNECTING...", for: .normal)
        API.facebookLoginBusinessAccount(owner: self) { (userDetail, longLiveToken, error) in
            
            if error == nil {
                
                if let userDetailDict = userDetail as? [String: AnyObject] {
                    
                    if let id = userDetailDict["id"] as? String {
                    NewAccount.id = id
                    NewAccount.instagramAccountId = id
                        checkNewIfInstagramExist(id: NewAccount.id) { (exist, user)  in
                        
                        if exist{
                            self.connectBtn.setTitle("CONNECT TO INSTAGRAM", for: .normal)
                            self.showStandardAlertDialogWithMultipleAction(title: "Account in use", msg: "This Instagram account already belongs to a user.", titles: ["Sign In","Try Again"]) { (action) in
                                
                                if action.title == "Sign In"{
                                    
                                    DispatchQueue.main.async {
                                        //self.dismiss(animated: true, completion: nil)
                                        self.performSegue(withIdentifier: "FromFCtoSignInVC", sender: user)
                                    }
                                    
                                }else{
                                    
                                }
                            }
                            
                        }else{
                            
                            if let followerCount = userDetailDict["followers_count"] as? Int {
                                NewAccount.followerCount = Int64(followerCount)
                            }
                            if let name = userDetailDict["name"] as? String {
                                NewAccount.instagramName = name
                            }
                            if let pic = userDetailDict["profile_picture_url"] as? String {
                                NewAccount.profilePicture = pic
                            }
                            if let username = userDetailDict["username"] as? String {
                                NewAccount.instagramUsername = username
                                //self.igName = username
                            }
                            NewAccount.authenticationToken = longLiveToken!
                            
                            if NewAccount.profilePicture != "" {
                                //updateFirebaseProfileURL(profileUrl: NewAccount.profilePicture, id: NewAccount.id) { (url, status) in
                                updateFirebaseProfileURL(profileUrl: NewAccount.profilePicture, id: NewAccount.instagramUsername) { (url, status) in
                                    
                                    self.connectBtn.setTitle("CONNECT TO INSTAGRAM", for: .normal)
                                    
                                    if status{
                                        NewAccount.profilePicture = url!
                                    }
                                    DispatchQueue.main.async {
                                        self.performSegue(withIdentifier: "toNewInterestPicker", sender: self)
                                    }
                                    
                                }
                                
                            }else{
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "fromInstagramConnectOnly", sender: self)
                                    //self.NotBusinessAccount()
                                }
                            }

                            
                        }
                        
                    }
                    
                    }else{
                        self.connectBtn.setTitle("CONNECT TO INSTAGRAM", for: .normal)
                        self.showStandardAlertDialog(title: "alert", msg: "Unknown error!") { (action) in
                            
                        }
                        
                    }
                    
                }else{
                    
                    self.connectBtn.setTitle("CONNECT TO INSTAGRAM", for: .normal)
                    if let err = error{
                        
                        print("ERROR: NO SERIALIZATION:\n\(err)")
                        if let errorVal = err as? NSError {
                            if let messageDict = errorVal.userInfo as? [String: Any] {
                                //com.facebook.sdk:FBSDKErrorDeveloperMessageKey
                                
                                if let message = messageDict["com.facebook.sdk:FBSDKErrorDeveloperMessageKey"] as? String{
                                    
                                    self.showStandardAlertDialog(title: "Alert", msg: message) { (action) in
                                        DispatchQueue.main.async {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                        }else{
                            
                            if err as! String == "Page Not Created"{
                                
                                self.noFBPConnect()
                                
                            }else if err as! String == "Instagram Not Linked"{
                                
                                self.noIGConnect()
                                
                            }
                        }
                    }
                }
                
            }else{
                
                self.connectBtn.setTitle("CONNECT TO INSTAGRAM", for: .normal)
                
                print("THERE WAS AN ERROR.")
                //                            self.showStandardAlertDialog(title: "Alert", msg: "Something is wrong! Please try again later")
                
                if let err = error{
                    
                    print(err)
                    if let errorVal = err as? NSError{
                        
                        if errorVal.code == 408{
                            self.navigationController?.popViewController(animated: true)
//                            self.showStandardAlertDialog(title: "Alert", msg: "You have cancelled the Facebook login process.") { (action) in
//
//                            }
                            
                        } else {
                            self.showStandardAlertDialog(title: "Error", msg: "\(err)") { (action) in
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }else{
                        
                        if err as! String == "Page Not Created"{
                            
                            self.noFBPConnect()
                            
                        }else if err as! String == "Instagram Not Linked"{
                            
                            self.noIGConnect()
                        }
                        
                    }
                    
                }
                
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
