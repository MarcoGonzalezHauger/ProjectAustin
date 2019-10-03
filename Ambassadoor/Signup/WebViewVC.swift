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
	
    var urlString = "https://www.ambassadoor.co/terms-of-service"
	
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: urlString)
        let requestObj = URLRequest(url: url!)
        webView.load(requestObj)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancel_Action(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
