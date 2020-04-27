//
//  InstagramConnectedVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/12/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class InstagramConnectedVC: UIViewController {

	var delegate: VerificationReturned?
    
    @IBOutlet weak var BOX: ShadowView!
    
	@IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var slider: UIView!
    @IBOutlet weak var proceed: UIButton!
    @IBOutlet weak var sliderWidth: NSLayoutConstraint!
    
	override func viewDidLoad() {
		super.viewDidLoad()
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
		usernameText.text = "@" + thisName
        
        sliderWidth.constant = 0
        self.view .layoutIfNeeded()
            self.slider.backgroundColor = UIColor.clear
            self.proceed.setTitle("Proceed", for: .normal)
            self.proceed.setTitleColor(.white, for: .normal)
            self.BOX.backgroundColor = UIColor.systemBlue
        //self.AverageLikes()
    }
    /*
     
     sliderWidth.constant = 0
     
     view.layoutIfNeeded()
     sliderWidth.constant = Box.bounds.width

     UIView.animate(withDuration: 5.0, animations: {
          self.view.layoutIfNeeded()
     })
     DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
         self.okayButton.setTitle("OKAY", for: .normal)
     }
     */
	
	@IBAction func ThatsNotMe(_ sender: Any) {
		delegate?.ThatsNotMe()
		dismiss(animated: true, completion: nil)
	}
	
	var thisName: String!
    var totalSliderValue: CGFloat = 0.0
	func SetName(name: String) {
		thisName = name
	}
    
    func AverageLikes() {
        
        API.calculateAverageLikes(userID: NewAccount.id, longLiveToken: NewAccount.authenticationToken) { (recentMedia, error) in
            
            if error == nil {
            
            if let recentMediaDict = recentMedia as? [String: AnyObject] {
                
                if let mediaData = recentMediaDict["data"] as? [[String: AnyObject]]{
                    let width = self.BOX.bounds.width
                    let sliderValue = width/CGFloat(mediaData.count)
                    
                    var numberOfPost = 0
                    var numberOfLikes = 0
                    
                    for (index,mediaObject) in mediaData.enumerated() {
                        
                        if let mediaID = mediaObject["id"] as? String {
                            
                            GraphRequest(graphPath: mediaID, parameters: ["fields":"like_count,timestamp","access_token":NewAccount.authenticationToken]).start(completionHandler: { (connection, recentMediaDetails, error) -> Void in
                                
                                if let mediaDict = recentMediaDetails as? [String: AnyObject] {
                                    
                                    if let timeStamp = mediaDict["timestamp"] as? String{
                                        print(Date.getDateFromISO8601DateString(ISO8601String: timeStamp))
                                        print(Date().deductMonths(month: -3))
                                        
                                        if Date.getDateFromISO8601DateString(ISO8601String: timeStamp) > Date().deductMonths(month: -3){
                                            
                                            if let likeCount = mediaDict["like_count"] as? Int{
                                                numberOfPost += 1
                                                numberOfLikes += likeCount
                                            }
                                            
                                            
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                self.totalSliderValue += sliderValue
                                self.sliderWidth.constant = self.totalSliderValue
                                
                                UIView.animate(withDuration: 5.0, animations: {
                                    self.view.layoutIfNeeded()
                                })
                                
                                if index == mediaObject.count - 1{
                                    if Double(numberOfLikes/numberOfPost) != nil{
                                        NewAccount.averageLikes = Double(numberOfLikes/numberOfPost)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
                                        self.slider.backgroundColor = UIColor.clear
                                        self.proceed.setTitle("Proceed", for: .normal)
                                        self.proceed.setTitleColor(.white, for: .normal)
                                        self.BOX.backgroundColor = UIColor.systemBlue
                                    }
                                }
                                
                            })
                            
                        }
                        
                    }
                    
                    
                }
            }
        }
        }
        
//        GraphRequest(graphPath: NewAccount.id + "/media", parameters: [:]).start(completionHandler: { (connection, recentMedia, error) -> Void in
//        })
        
    }
    
    
	
	@IBAction func Proceed(_ sender: Any) {
		dismiss(animated: true) {
			self.delegate?.DonePressed()
		}
	}
    
    /*
     if let recentMediaDict = recentMedia as? [String: AnyObject] {
     
         if let mediaData = recentMediaDict["data"] as? [[String: AnyObject]]{
         let width = self.BOX.bounds.width
         let sliderValue = width/CGFloat(mediaData.count)
             
             var numberOfPost = 0
             var numberOfLikes = 0
         
             for (index,mediaObject) in mediaData.enumerated() {
             
             if let mediaID = mediaObject["id"] as? String {
                 
                 GraphRequest(graphPath: mediaID, parameters: ["fields":"like_count,timestamp"]).start(completionHandler: { (connection, recentMediaDetails, error) -> Void in
                     
                     if let mediaDict = recentMediaDetails as? [String: AnyObject] {
                         
                         if let timeStamp = mediaDict["timestamp"] as? String{
                             print(Date.getDateFromISO8601DateString(ISO8601String: timeStamp))
                             print(Date().deductMonths(month: -3))
                                 
                             if Date.getDateFromISO8601DateString(ISO8601String: timeStamp) > Date().deductMonths(month: -3){
                                 
                                 if let likeCount = mediaDict["like_count"] as? Int{
                                    numberOfPost += 1
                                    numberOfLikes += likeCount
                                 }
                                 
                                 
                                     
                             }
                                 
                         }
                         
                     }
                     
                     self.totalSliderValue += sliderValue
                     self.sliderWidth.constant = self.totalSliderValue

                     UIView.animate(withDuration: 5.0, animations: {
                          self.view.layoutIfNeeded()
                     })
                     
                     if index == mediaObject.count - 1{
                         if Double(numberOfLikes/numberOfPost) != nil{
                         NewAccount.averageLikes = Double(numberOfLikes/numberOfPost)
                         }
                         DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
                             self.slider.backgroundColor = UIColor.clear
                             self.proceed.setTitle("Proceed", for: .normal)
                             self.proceed.setTitleColor(.white, for: .normal)
                             self.BOX.backgroundColor = UIColor.systemBlue
                         }
                     }
                     
                 })
                 
             }
             
         }
             
         
     }
     }
     */
	
}
