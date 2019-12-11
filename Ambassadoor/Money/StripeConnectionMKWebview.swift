//
//  StripeConnectionMKWebview.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 01/10/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import WebKit


class StripeConnectionMKWebview: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView_MKWeb: WKWebView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    let url = URL(string: "https://dashboard.stripe.com/express/oauth/authorize?response_type=code&client_id=\(API.Stripeclient_id)&scope=read_write")

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        webView_MKWeb.navigationDelegate = self
        activityIndicatorView.isHidden = true
        
        
        guard let url = self.url else {
            self.showStandardAlertDialog(title: "Alert!", msg: "The URL seems to be Invalid.")
            return
        }
                
        let cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        let timeout: TimeInterval = 6.0
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        
        request.httpMethod = "GET"
        
        activityIndicatorView.isHidden = false
        webView_MKWeb.load(request)
    }
    
    
    //MARK: WKWebView Delegate method
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicatorView.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.showStandardAlertDialog(title: "Alert", msg: error.localizedDescription)
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {
        
        
        
        
        print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(String(describing: decisionHandler))")
        
        print("navigation=",navigationAction.request.url!.absoluteString)
        
        if let url = navigationAction.request.url {
            print(url.absoluteString)
            /* Test
             if url.absoluteString.hasPrefix("https://connect.stripe.com/connect/default_new/oauth/test?") || url.absoluteString.hasPrefix("https://connect.stripe.com/connect/default/oauth/test?"){
             print("SUCCESS")
             */
            if url.absoluteString.hasPrefix("https://www.ambassadoor.co/paid?") || url.absoluteString.hasPrefix("https://www.ambassadoor.co/paid?code="){
                print("SUCCESS")
                //                    self.dismiss(animated: true, completion: nil)
                
                if let range = url.absoluteString.range(of: "code=") {
                    let code = url.absoluteString[range.upperBound...]
                    print(code) // prints "123.456.7891"
                    self.getAccountID(code: String(code))
                }
                
            }
        }
        
        decisionHandler(.allow)
    }

    
    func getAccountID(code: String) {

        let params = ["client_secret":API.Stripeclient_secret,"code":code,"grant_type":"authorization_code"] as [String: AnyObject]
        APIManager.shared.getAccountID(params: params) { (status, error, data) in
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print("dataString=",dataString as Any)
            do {
				_ = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
				_ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if let accDetail = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any] {
                    
                    createStripeAccToFIR(AccDetail:accDetail)
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }

                }
                
            }catch _ {
                
            }
        }
        
    }

    
    
    @IBAction func cancel_Action(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
