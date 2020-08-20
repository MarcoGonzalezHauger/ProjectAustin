//
//  ConnectStepsVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 20/08/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ConnectStepsVC: UIViewController, VerificationReturned {
    
    func DonePressed() { //Proceeded
        
        
        //[RAM] The account entered should be loaded onto the NewAccount strucutre
        NewAccount.instagramKey = "" //The instagram key gotten from the WKWebView
        NewAccount.instagramUsername = igName //The instagram user's username.
        accInfoUpdate()
        self.navigationController?.popViewController(animated: true)
    }
    
    func ThatsNotMe() {
        getFBBusinessAccount()
    }
    
    var igName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func connectAction(){
        self.getFBBusinessAccount()
    }
    
    func noIGConnect() {
        print("noIG")
    }
    
    func noFBPConnect() {
        print("noFBP")
    }
    
    @IBAction func cancelAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getFBBusinessAccount() {
        
        API.facebookLoginBusinessAccount(owner: self) { (userDetail, longLiveToken, error) in
            
            if error == nil {
                
                if let userDetailDict = userDetail as? [String: AnyObject] {
                    
                    if let id = userDetailDict["id"] as? String {
                        NewAccount.id = id
                    }
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
                        self.igName = username
                    }
                    NewAccount.authenticationToken = longLiveToken!
                    
                    if NewAccount.profilePicture != "" {
                        
                        updateFirebaseProfileURL(profileUrl: NewAccount.profilePicture, id: NewAccount.id) { (url, status) in
                            
                            if status{
                                NewAccount.profilePicture = url!
                            }
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "toInstagramConnect", sender: self)
                            }
                            
                        }
                        
                    }else{
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "toInstagramConnect", sender: self)
                            //self.NotBusinessAccount()
                        }
                    }
                    
                    
                }else{
                    
                    
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
                print("THERE WAS AN ERROR.")
                //                            self.showStandardAlertDialog(title: "Alert", msg: "Something is wrong! Please try again later")
                
                if let err = error{
                    
                    print(err)
                    if let errorVal = err as? NSError{
                        
                        if errorVal.code == 408{
                            
                            self.showStandardAlertDialog(title: "Alert", msg: "You have cancelled the Facebook login process.") { (action) in
                                self.navigationController?.popViewController(animated: true)
                            }
                            
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let destination = segue.destination as? InstagramConnectedVC {
            destination.delegate = self
            destination.SetName(name: igName)
        }
    }


}
