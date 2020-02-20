//
//  ConnectInstagramVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/12/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

protocol VerificationReturned {
	func DonePressed()
	func ThatsNotMe()
}

import UIKit
import WebKit
import FBSDKCoreKit
import FBSDKLoginKit

class ConnectInstagramVC: UIViewController, WKNavigationDelegate, VerificationReturned {
	
	
	func DonePressed() { //Proceeded
		
		
		//[RAM] The account entered should be loaded onto the NewAccount strucutre
		NewAccount.instagramKey = "" //The instagram key gotten from the WKWebView
		NewAccount.instagramUsername = igName //The instagram user's username.
		accInfoUpdate()
		self.navigationController?.popViewController(animated: true)
	}
	
	func ThatsNotMe() {
		//[RAM] WKWebView needs to be reset so that the influencer could login again.
	}
	

	@IBAction func testIt(_ sender: Any) {
		//This button will be removed later of course
		//AccountAlreadyInUse(emailOfExistingUser: "marco@amb.co")
		AccountLoggedIn(instagramUsername: "marcogonzalezhauger")
	}
	
	@IBOutlet weak var webView: WKWebView!
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
	
	//[RAM] These are the three different possibilties when a user logs in. The functoins are done, you just need to call them.
	
	
	func AccountLoggedIn(instagramUsername: String) {
		igName = instagramUsername
		performSegue(withIdentifier: "toConnected", sender: self)
	}
	
	func AccountAlreadyInUse(emailOfExistingUser email: String) {
		alreadyUsedEmail = email
		performSegue(withIdentifier: "toInUse", sender: self)
	}
	
	func NotBusinessAccount() {
		performSegue(withIdentifier: "toNotBusiness", sender: self)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
		//[RAM] make this wkWebView go to the login page on Instagram, just like the one before.
        
        self.loginAct()
        
    }
    
    func loginAct() {
        
        let login: LoginManager = LoginManager()
        login.logOut()
        login.logIn(permissions: ["instagram_basic","pages_show_list"], from: self) { (result, FBerror) in
            if((FBerror) != nil){
                print("Process Error=",FBerror?.localizedDescription)
                
            }else{
                
                GraphRequest(graphPath: "/me/accounts", parameters: [:]).start(completionHandler: { (connection, result, error) -> Void in
                    
                    if let resultDict = result as? [String: AnyObject] {
                    let arrayKey = resultDict.keys
                    print(arrayKey)
                        
                        if let dataArray = resultDict["data"] as? NSArray{
                            
                            if let dataDict = dataArray.firstObject as? NSDictionary{
                                if let idString = dataDict["id"] as? String{
                                    print(idString)
                                    
                                    GraphRequest(graphPath: idString, parameters: ["fields":"instagram_business_account"]).start(completionHandler: { (connection, businessResult, error) -> Void in
                                        
                                        if let dicVal = businessResult as? NSDictionary {
                                        
                                            if let businessResultDict = dicVal["instagram_business_account"] as? NSDictionary{
                                            
                                            if let businessID = businessResultDict["id"] as? String{
                                                
                                                print(businessID)
                                                
                                                GraphRequest(graphPath: businessID, parameters: ["fields":"biography,id,followers_count,follows_count,media_count,name,profile_picture_url,username,website"]).start(completionHandler: { (connection, userDetail, error) -> Void in
                                                    
                                                    if let userDetailDict = userDetail as? [String: AnyObject]{
                                                        
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
                                                        NewAccount.authenticationToken = AccessToken.current!.tokenString
                                                        
                                                        DispatchQueue.main.async {
                                                            self.performSegue(withIdentifier: "toConnected", sender: self)
                                                            //self.NotBusinessAccount()
                                                        }
                                                        
                                                    }
                                                    
                                                })
                                                
                                            }
                                        }
                                        
                                        }
                                        
                                    })
                                }
                            }
                            
                        }
                        
                    }
                    
                })
                
            }
            
        }
        
    }
	
	@IBAction func cancelButtonPressed(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicatorView.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()
    }
	
	var igName: String = ""
	var igKey: String = ""
	var alreadyUsedEmail: String = ""
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? InstagramConnectedVC {
			destination.delegate = self
			destination.SetName(name: igName)
		}
		if let destination = segue.destination as? AccountInUseVC {
			destination.delegate = self
			destination.SetEmail(email: alreadyUsedEmail)
		}
		if let destination = segue.destination as? NotBusinessVC {
			destination.delegate = self
		}
	}
	
}
