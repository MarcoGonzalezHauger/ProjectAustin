//
//  structs.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/22/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import Foundation
import UIKit

//Protocol for ACCEPTING offers.
protocol OfferResponse {
	func OfferAccepted(offer: Offer) -> ()
}


//Shadow Class reused all throughout this app.
@IBDesignable
class ShadowView: UIView {
	override func awakeFromNib() {
		super.awakeFromNib()
		DrawShadows()
	}
	override var bounds: CGRect { didSet { DrawShadows() } }
	@IBInspectable var cornerRadius: Float = 10 {	didSet { DrawShadows() } }
	@IBInspectable var ShadowOpacity: Float = 0.2 { didSet { DrawShadows() } }
	@IBInspectable var ShadowRadius: Float = 1.75 { didSet { DrawShadows() } }
	@IBInspectable var ShadowColor: UIColor = UIColor.black { didSet { DrawShadows() } }
	
	func DrawShadows() {
		//draw shadow & rounded corners for offer cell
		self.layer.cornerRadius = CGFloat(cornerRadius)
		self.layer.shadowColor = ShadowColor.cgColor
		self.layer.shadowOpacity = ShadowOpacity
		self.layer.shadowOffset = CGSize.zero
		self.layer.shadowRadius = CGFloat(ShadowRadius)
		self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
		
	}
}

//Structure for an offer that comes into username's inbox
class Offer : NSObject {
    //naveen added
    var status: String
	let money: Double
	let company: Company
	let posts: [Post]
	let offerdate: Date
	let offer_ID: String
	let expiredate: Date
	var allPostsConfrimedSince: Date?
	var allConfirmed: Bool {
		get {
			var areConfirmed = true
			for x : Post in posts {
				if x.isConfirmed == false {
					areConfirmed = false
				}
			}
			return areConfirmed
		}
	}
	var isAccepted: Bool
	var isExpired: Bool {
		return self.expiredate.timeIntervalSinceNow <= 0
	}
	var debugInfo: String {
		return "Offer by \(company.name) for $\(String(money)) that is \(isExpired ? "" : "not ") expired."
	}
    init(dictionary: [String: AnyObject]) {
        //naveen added
        self.status = dictionary["status"] as! String
        self.money = dictionary["money"] as! Double
        self.company = dictionary["company"] as! Company
        self.posts = dictionary["posts"] as! [Post]
        self.offerdate = getDateFromString(date: dictionary["offerdate"] as! String)
        self.offer_ID = dictionary["offer_ID"] as! String
        self.expiredate = getDateFromString(date: dictionary["expiredate"] as! String)
        self.allPostsConfrimedSince = dictionary["allPostsConfirmedSince"] as? Date
        self.isAccepted = dictionary["isAccepted"] as! Bool
    }
}

//Strcuture for users
class User: NSObject {
	let name: String?
	let username: String
	let followerCount: Double
	let profilePicURL: String?
	var primaryCategory: Category
	var SecondaryCategory: Category?
	let averageLikes: Double?
	var zipCode: String?
    //naveen added
    let id: String
    var gender: Gender?
    var isBankAdded: Bool
    var yourMoney: Int
	
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String
        self.username = dictionary["username"] as! String
        self.followerCount = dictionary["followerCount"] as! Double
		if (dictionary["profilePicture"] as? String ?? "") == "" {
			self.profilePicURL = nil
		} else {
			self.profilePicURL = dictionary["profilePicture"] as? String
		}
		debugPrint("Category: \(String(describing: dictionary["primaryCategory"]))")
//		self.primaryCategory = Category.init(rawValue: dictionary["primaryCategory"] as? String ?? "Other")!
        //naveen added
        if ((dictionary["primaryCategory"] ?? "") as! String) == ""{
            self.primaryCategory = Category.init(rawValue: "Other")!
        } else {
            self.primaryCategory = ((dictionary["primaryCategory"] as? String ?? "") == "" ? nil : Category.init(rawValue: dictionary["primaryCategory"] as! String))!
        }
        
		if ((dictionary["secondaryCategory"] ?? "") as! String) == ""{
			self.SecondaryCategory = nil
		} else {
			self.SecondaryCategory = ((dictionary["secondaryCategory"] as? String ?? "") == "" ? nil : Category.init(rawValue: dictionary["secondaryCategory"] as! String))!
		}
		self.averageLikes = dictionary["averageLikes"] as? Double
		self.zipCode = dictionary["zipCode"] as? String
        //naveen added
        self.id = dictionary["id"] as! String
        self.gender = dictionary["gender"] as? Gender
        self.isBankAdded = dictionary["isBankAdded"] as! Bool 
        self.yourMoney = dictionary["yourMoney"] as! Int
    }
	
	override var description: String {
		return "NAME: \(name ?? "NIL")\nUSERNAME: \(username)\nFOLLOWER COUNT: \(followerCount)\nPROFILE PIC: \(profilePicURL ?? "NIL")\nACCOUNT TYPE: \(primaryCategory)\nAVERAGE LIKES: \(averageLikes ?? -404)"
	}
}
//naveen added
class Bank: NSObject {
    let publicToken: String
    let institutionName: String
    let institutionID: String
    var acctID: String
    var acctName: String
   
    
    init(dictionary: [String: Any]) {
        self.publicToken = dictionary["publicToken"] as! String
        self.institutionName = dictionary["institutionName"] as! String
        self.institutionID = dictionary["institutionID"] as! String
        self.acctID = dictionary["acctID"] as! String
        self.acctName = dictionary["acctName"] as! String

    }
    

}
//Structure for post
struct Post {
	let image: String?
	let instructions: String
	let captionMustInclude: String?
	let products: [Product]?
	let post_ID: String
	let PostType: TypeofPost
	var confirmedSince: Date?
	var isConfirmed: Bool
}

//struct for product
struct Product {
	let image: String?
	let name: String
	let price: Double
	let buy_url: String
	let color: String
	let product_ID: String
}

//struct for company
struct Company {
	let name: String
	let logo: String?
	let mission: String
	let website: String
	let account_ID: String
	let instagram_name: String
	let description: String
}

//Carries personal info only avalible to view and edit by the user.
struct PersonalInfo {
	let gender: Gender?
    let accountBalance: Int?
}

enum Gender: String {
	case Male, Female, Other
}

enum TypeofPost {
	case SinglePost, MultiPost, Story
}

//naveen added
enum Status: String {
    case available, accepted, rejected
}
    
    //instagram post data
class InstagramManager: NSObject, UIDocumentInteractionControllerDelegate {

    private let kInstagramURL = "instagram://"
    //    private let kInstagramURL = "instagram://share"
    //    private let kInstagramURL = "instagram://app"

    private let kUTI = "com.instagram.exclusivegram"
    private let kfileNameExtension = "instagram.igo"
    private let kAlertViewTitle = "Error"
    private let kAlertViewMessage = "Please install the Instagram application"

    var documentInteractionController = UIDocumentInteractionController()

    // singleton manager
    class var sharedManager: InstagramManager {
        struct Singleton {
            static let instance = InstagramManager()
        }
        return Singleton.instance
    }

    func postImageToInstagramWithCaption(imageInstagram: UIImage, instagramCaption: String, view: UIView,  completion:@escaping (_ bool:Bool) -> ()) {
        // called to post image with caption to the instagram application
        
//        let instagramURL = NSURL(string: kInstagramURL)
        let instagramURL = NSURL(string: kInstagramURL + "user?username=\(Yourself.username)")
        if UIApplication.shared.canOpenURL(instagramURL! as URL) {
            let jpgPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(kfileNameExtension)
            //            UIImageJPEGRepresentation(imageInstagram, 1.0)!.writeToFile(jpgPath, atomically: true)
            do {
                try imageInstagram.jpegData(compressionQuality: 1.0)!.write(to: URL(fileURLWithPath: jpgPath), options: .atomic)
            } catch let error {
                print(error)
            }
            let rect = CGRect(x: 0,y: 0,width: 612,height: 612)
            let fileURL = NSURL.fileURL(withPath: jpgPath)
            documentInteractionController.url = fileURL
            documentInteractionController.delegate = self
            documentInteractionController.uti = kUTI
            documentInteractionController.dismissMenu(animated: true)
            documentInteractionController.name = instagramCaption

            // adding caption for the image
            //["InstagramCaption": instagramCaption]
            documentInteractionController.annotation = ["InstagramCaption": instagramCaption]
            documentInteractionController.presentOpenInMenu(from: rect, in: view, animated: true)
            completion(true)
        }
        else {
            // alert displayed when the instagram application is not available in the device
            completion(false)
            //            UIAlertView(title: kAlertViewTitle, message: kAlertViewMessage, delegate:nil, cancelButtonTitle:"Ok").show()
            
        }
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        
    }
    
    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        
    }
    
    func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
        
    }
    func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
        
    }

}


