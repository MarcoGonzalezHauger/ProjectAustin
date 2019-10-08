//
//  TabBarVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 19/09/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.versionUpdateValidation()

    }
    
//    func versionUpdateValidation(){
//        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
//
//        let ref = Database.database().reference().child("LatestAppVersion").child("version")
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//
//            let latestVersion = snapshot.value as! String
//            if (latestVersion == appVersion) {
//
//            }else{
//                let alertMessage = "A new version of Application is available,Please update to version " + latestVersion;
//                let alert = UIAlertController(title: "New Version Available", message: alertMessage, preferredStyle: .alert)
//
//                let okBtn = UIAlertAction(title: "Update", style: .default, handler: {(_ action: UIAlertAction) -> Void in
//                    if let url = URL(string: "itms-apps://itunes.apple.com/app"),
//                        UIApplication.shared.canOpenURL(url){
//                        if #available(iOS 10.0, *) {
//                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                        } else {
//                            UIApplication.shared.openURL(url)
//                        }
//                    }
//                })
//
//                alert.addAction(okBtn)
//                DispatchQueue.global().async {
//                    self.present(alert, animated: true, completion: nil)
//                }
//            }
//        })
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
