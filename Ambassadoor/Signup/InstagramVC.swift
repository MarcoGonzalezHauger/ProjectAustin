//
//  InstagramVC.swift
//  Ambassadoor
//
//  Created by Chris Chomicki on 2/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit
import WebKit

class InstagramVC: UIViewController, ConfirmationReturned {
	
	func dismissed(success: Bool!) {
		if success {
			//Proceed button clicked
			self.dismiss(animated: false) {
				self.delegate?.dismissed(success: true)
			}
		} else {
			//NOT ME button clicked
			loadLogin()
			
		}
	}
	
    var delegate: ConfirmationReturned?
    @IBOutlet weak var webView: WKWebView!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? VerifedVC {
			if segue.identifier == "VerifySegue" {
				destination.delegate = self
                destination.user = sender as? User
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		print("before LoadLogin()")
        loadLogin()
		print("after LoadLogin()")
    }
    
    // Loads the Instagram login page
    func loadLogin() {
		if attemptedLogOut {
			API.instaLogout()
		}
		
//		let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [API.INSTAGRAM_AUTHURL,API.INSTAGRAM_CLIENT_ID,API.INSTAGRAM_REDIRECT_URI, API.INSTAGRAM_SCOPE])
		
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token", arguments: [API.INSTAGRAM_AUTHURL, API.INSTAGRAM_CLIENT_ID, API.INSTAGRAM_REDIRECT_URI])


        let urlRequest = URLRequest.init(url: URL.init(string: authURL)!)
        // Puts login page into WebView on VC
        webView.load(urlRequest)
		print("WEB VIEW URL: \(String(describing: webView.url))")

    }
}

extension InstagramVC: WKNavigationDelegate {
    //Set delegate as itself
    override func viewDidAppear(_ animated: Bool) {
        self.webView.navigationDelegate = self
    }
    
    // Check callback url for instagram access token
    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        let requestURLString = (request.url?.absoluteString)! as String
        print("requestURLString= " + requestURLString)
        if requestURLString.hasPrefix(API.INSTAGRAM_REDIRECT_URI) || requestURLString.hasPrefix(API.INSTAGRAM_REDIRECT_URI2) {
            let range: Range<String.Index> = requestURLString.range(of: "access_token=")!
			print("Access Token : " + String(requestURLString[range.upperBound...]))
            handleAuth(authToken: String(requestURLString[range.upperBound...]))
            return true
        }
        return false
    }

    // Handle Instagram auth token from callback url and handle it with our logic
    func handleAuth(authToken: String) {
        print("Instagram authentication token = ", authToken)
        API.INSTAGRAM_ACCESS_TOKEN = authToken
        API.getProfileInfo { (user: User?) in
            DispatchQueue.main.async {
                if user != nil {
                    print("user NOT nil, creating user.")
                    CreateAccount(instagramUser: user!) { (userVal, alreadyRegistered) in
                        Yourself = userVal
                        print("Insta gender = \(Yourself.gender)")

                        if alreadyRegistered {
                            UserDefaults.standard.set(API.INSTAGRAM_ACCESS_TOKEN, forKey: "token")
                            UserDefaults.standard.set(Yourself.id, forKey: "userid")

                            self.dismissed(success: alreadyRegistered)
                        }else{
                            self.performSegue(withIdentifier: "VerifySegue", sender: userVal)
                        }
                    }

                } else {
                    debugPrint("Youself user was NIL.")
                    self.showStandardAlertDialog(title: "Alert", msg: "You have exceeded the maximum number of requests per hour. You have performed a total of 270 requests in the last hour. Our general maximum limit is set at 200 requests per hour.")
                }
            }
        }
    }
    
    func worked(){
        print("Segue complete.")
    }
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
		decisionHandler(.allow)
		let success: Bool = checkRequestForCallbackURL(request: navigationAction.request)
		if success {
			print("Sucessful login.")
		}
    }
    

}
