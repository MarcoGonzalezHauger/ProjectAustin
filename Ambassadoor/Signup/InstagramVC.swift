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
import JavaScriptCore

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
		debugPrint("before LoadLogin()")
        loadLogin()
		debugPrint("after LoadLogin()")
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
		debugPrint("WEB VIEW URL: \(String(describing: webView.url))")
		

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
        //print("requestURLString" + requestURLString)
        if requestURLString.hasPrefix(API.INSTAGRAM_REDIRECT_URI) {
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            handleAuth(authToken: String(requestURLString[range.upperBound...]))
            return true
        }
        return false
    }

    // Handle Instagram auth token from callback url and handle it with our logic
    //naveen commented
//    func handleAuth(authToken: String) {
//        debugPrint("Instagram authentication token = ", authToken)
//        API.INSTAGRAM_ACCESS_TOKEN = authToken
//		API.getProfileInfo { (user: User?) in
//			DispatchQueue.main.async {
//				if user != nil {
//					debugPrint("user NOT nil, creating user.")
//                    CreateAccount(instagramUser: user!)
//					Yourself = user
//					self.performSegue(withIdentifier: "VerifySegue", sender: self)
//				} else {
//					debugPrint("Youself user was NIL.")
//				}
//			}
//		}
//    }
    
    //naveen added
    func handleAuth(authToken: String) {
        debugPrint("Instagram authentication token = ", authToken)
        API.INSTAGRAM_ACCESS_TOKEN = authToken
        API.getProfileInfo { (user: User?) in
            DispatchQueue.main.async {
                if user != nil {
                    debugPrint("user NOT nil, creating user.")
                    CreateAccount(instagramUser: user!) { (userVal, alreadyRegistered) in
                        Yourself = userVal
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
                }
            }
        }
    }
    
    func worked(){
        debugPrint("Segue complete.")
    }
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
		decisionHandler(.allow)
		checkRequestForCallbackURL(request: navigationAction.request)
    }
    
    func getDwollaProcessorToken(params: [String: AnyObject],completion: @escaping (_ status: String,  _ error: String?, _ dataValue: Data?) -> Void) {
        
        let urlString = "https://us-central1-amassadoor.cloudfunctions.net/" + "getDwollaToken"
        
        let url = URL(string: urlString)
        
        let session = URLSession.shared
        var request = URLRequest(url: url!)
        request.httpMethod = "Post"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        let task = session.dataTask(with: request) {
            (
            data, response, error) in
            if (error != nil && data != nil) {
                
                completion("failure", error?.localizedDescription ?? "error", data)
            }
            else if (error != nil || data == nil){
                completion("failure", error?.localizedDescription ?? "error", nil)
            }
            else{
                //                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                completion("success",nil,data!)
            }
            
        }
        
        task.resume()
        
    }

}
