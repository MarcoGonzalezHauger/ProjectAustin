//
//  WebViewVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 18/09/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import WebKit


class WebViewVC: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var titleText: UILabel!
	
    var urlString: String = ""
	//"https://www.ambassadoor.co/terms-of-service"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleText.text = self.urlString == API.privacyUrl ? "Privacy Policy" : "Terms of Service"
        
        let url = URL(string: urlString)
        let requestObj = URLRequest(url: url!)
        webView.load(requestObj)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancel_Action(_ sender: Any) {
        performDismiss()
    }
}
