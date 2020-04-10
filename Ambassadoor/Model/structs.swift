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
    @IBInspectable var cornerRadius: Float = 10 { didSet { DrawShadows() } }
    @IBInspectable var ShadowOpacity: Float = 0.2 { didSet { DrawShadows() } }
    @IBInspectable var ShadowRadius: Float = 1.75 { didSet { DrawShadows() } }
    @IBInspectable var ShadowColor: UIColor = UIColor.black { didSet { DrawShadows() } }
    @IBInspectable var borderWidth: Float = 0.0 { didSet { DrawShadows() }}
    @IBInspectable var borderColor: UIColor = UIColor.black { didSet { DrawShadows() }}
    
    func DrawShadows() {
        //draw shadow & rounded corners for offer cell
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.shadowColor = ShadowColor.cgColor
        self.layer.shadowOpacity = ShadowOpacity
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = CGFloat(ShadowRadius)
        self.layer.borderWidth = CGFloat(borderWidth)
        self.layer.borderColor = borderColor.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        
    }
}

//Structure for an offer that comes into username's inbox
class Offer : NSObject {
    
    var status: String
	let money: Double
    var company: Company?
	var posts: [Post]
	let offerdate: Date
	let offer_ID: String
	var expiredate: Date
	var allPostsConfirmedSince: Date?
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
		return "Offer by \(company?.name) for $\(String(money)) that is \(isExpired ? "" : "not ") expired."
	}
    var ownerUserID: String
    var title: String
    
    var isRefferedByInfluencer: Bool?
    var isReferCommissionPaid: Bool?
    var referralAmount: Double?
    var referralCommission: Double?
    var referralID: String?
    
    var cashPower: Double?
    
    var influencerFilter: [String: AnyObject]?
    
    var incresePay: Double?
    
    var companyDetails: CompanyDetails?
    var accepted: [String]?
    
    var commission: Double?
    var isCommissionPaid: Bool?
    var user_ID: [String]?
    var notify: Bool
    var category: [String]
    var genders: [String]
    var user_IDs: [String]
    
    var shouldRefund: Bool?
    var didRefund: Bool?
    var refundedOn: String?
    var updatedDate: Date?
    
    init(dictionary: [String: AnyObject]) {
        
        self.status = dictionary["status"] as! String
        self.money = dictionary["money"] as! Double
        self.company = nil
        if let companyDetails = dictionary["companyDetails"] as? [String: AnyObject]{
            
            self.company = Company.init(name: companyDetails["name"] as! String, logo: companyDetails["logo"] as? String, mission: companyDetails["mission"] as! String, website: companyDetails["website"] as! String, account_ID: companyDetails["account_ID"] as! String, instagram_name: "", description: "", followers: companyDetails["followers"] as? [String] ?? [])
            
        }
        
        
        var postVal = [Post]()
        
        /*
         ["image":post.image!,"instructions":post.instructions,"captionMustInclude":post.captionMustInclude!,"products":product,"post_ID":post.post_ID,"PostType": post.PostType,"confirmedSince":"" ,"isConfirmed":post.isConfirmed,"hashCaption":post.hashCaption,"status": post.status,"hashtags": post.hashtags, "keywords": post.keywords, "isPaid": post.isPaid ?? false, "PayAmount": post.PayAmount ?? 0.0]
         */
        
        if let posDict = dictionary["posts"] as? [[String: AnyObject]]{

        for post in posDict {

            //postVal.append(Post.init(image: post["image"] as? String, instructions: post["instructions"] as! String, captionMustInclude: "", products: post["products"] as? [Product] , post_ID: post["post_ID"] as! String, PostType: TextToPostType(posttype: post["PostType"] as! String), confirmedSince: post["confirmedSince"] as? Date, isConfirmed: post["isConfirmed"] as! Bool, hashCaption: post["hashCaption"] as? String ?? "",denyMessage: post["denyMessage"] as? String ?? "",status: post["status"] as? String ?? "", hashtags: post["hashtags"] as? [String] ?? [], keywords: post["keywords"] as? [String] ?? []))
            
            postVal.append(Post.init(image: post["image"] as? String, instructions: post["instructions"] as! String, captionMustInclude: "", products: post["products"] as? [Product], post_ID: post["post_ID"] as! String, PostType: post["PostType"] as! String, confirmedSince: post["confirmedSince"] as? Date, isConfirmed: post["isConfirmed"] as! Bool, hashCaption: post["hashCaption"] as? String ?? "", status: post["status"] as? String ?? "", hashtags: post["hashtags"] as? [String] ?? [], keywords: post["keywords"] as? [String] ?? [], isPaid: post["isPaid"] as? Bool, PayAmount: post["isPaid"] as? Double ?? 0.0, denyMessage: post["denyMessage"] as? String ?? ""))


        }
        
        }
        
        self.posts = postVal
        self.offerdate = getDateFromString(date: dictionary["offerdate"] as! String)
        self.offer_ID = dictionary["offer_ID"] as! String
        //self.expiredate = getDateFromString(date: dictionary["expiredate"] as! String)
        self.expiredate = getESTDateFromString(date: dictionary["expiredate"] as! String)
//        self.allPostsConfrimedSince = dictionary["allPostsConfirmedSince"] as? Date
		if dictionary["allPostsConfirmedSince"] as! String != "" {
			self.allPostsConfirmedSince = getDateFromString(date: dictionary["allPostsConfirmedSince"] as! String)
		}

        self.isAccepted = dictionary["isAccepted"] as! Bool
        self.ownerUserID = dictionary["ownerUserID"] as! String
        self.title = dictionary["title"] as! String
        
        self.isRefferedByInfluencer = dictionary["isRefferedByInfluencer"] as? Bool ?? false
        self.isReferCommissionPaid = dictionary["isReferCommissionPaid"] as? Bool ?? false
        self.referralAmount = dictionary["referralAmount"] as? Double ?? 0.0
        self.referralID = dictionary["referralID"] as? String ?? ""
        self.referralCommission = dictionary["referralCommission"] as? Double ?? 0.0
        
        self.cashPower = dictionary["cashPower"] as? Double ?? 0.0
        self.influencerFilter = dictionary["influencerFilter"] as? [String: AnyObject] ?? [:]
        self.incresePay = dictionary["incresePay"] as? Double ?? 0.0
        self.companyDetails = CompanyDetails.init(dictionary: dictionary["companyDetails"] as? [String: AnyObject] ?? [:]) 
        self.accepted = dictionary["accepted"] as? [String] ?? []
        self.commission = dictionary["commission"] as? Double
        self.isCommissionPaid = dictionary["isCommissionPaid"] as? Bool ?? false
        self.user_ID = dictionary["user_ID"] as? [String] ?? []
        self.notify = dictionary["notify"] as? Bool ?? false
        self.category = dictionary["category"] as? [String] ?? []
        self.genders = dictionary["genders"] as? [String] ?? []
        self.user_IDs = dictionary["user_IDs"] as? [String] ?? []
        self.accepted = dictionary["accepted"] as? [String] ?? []
        self.shouldRefund = dictionary["shouldRefund"] as? Bool ?? false
        self.didRefund = dictionary["didRefund"] as? Bool ?? false
        self.refundedOn = dictionary["refundedOn"] as? String ?? ""
        self.updatedDate =  ((dictionary["updatedDate"] as? String) != nil) ? getDateFromString(date: dictionary["updatedDate"] as! String) : nil
    }
}

class allOfferObject: NSObject {
    var offer: Offer
    var isFiltered: Bool
    
    init(offer: Offer, isFiltered: Bool) {
        
        self.offer = offer
        self.isFiltered = isFiltered
    }
    
}

//Strcuture for users
class User: NSObject {
	let name: String?
	let username: String
	let followerCount: Double
	let profilePicURL: String?
	var averageLikes: Double?
	var zipCode: String?
    let id: String
    var gender: Gender?
    var isBankAdded: Bool
    var yourMoney: Double
    var joinedDate: String?
    var categories: [String]?
    var referralcode: String
    var isDefaultOfferVerify: Bool
    var lastPaidOSCDate: String
    var priorityValue: Int
    var authenticationToken: String
    var tokenFIR: String?
    var following: [String]?
    var businessFollowing: [String]?
    var email: String?
    //followerCount
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String
        self.username = dictionary["username"] as! String
        self.followerCount = Double(dictionary["followerCount"] as! Int64)
		if (dictionary["profilePicture"] as? String ?? "") == "" {
			self.profilePicURL = nil
		} else {
			self.profilePicURL = dictionary["profilePicture"] as? String
		}
//		print("Category: \(String(describing: dictionary["primaryCategory"]))")
//		self.primaryCategory = Category.init(rawValue: dictionary["primaryCategory"] as? String ?? "Other")!
		self.averageLikes = dictionary["averageLikes"] as? Double
		self.zipCode = dictionary["zipCode"] as? String
        self.id = dictionary["id"] as! String
        self.gender = Gender(rawValue: dictionary["gender"] as? String ?? "Male")
        //self.gender = (dictionary["gender"] as? Gender.RawValue).map { Gender(rawValue: $0) }!
        self.isBankAdded = dictionary["isBankAdded"] as! Bool 
        self.yourMoney = dictionary["yourMoney"] as! Double
        self.joinedDate = dictionary["joinedDate"] as? String
        self.categories = dictionary["categories"] as? [String]
        
        self.referralcode = dictionary["referralcode"] as? String ?? ""
        self.isDefaultOfferVerify = dictionary["isDefaultOfferVerify"] as? Bool ?? false
        self.lastPaidOSCDate = dictionary["lastPaidOSCDate"] as? String ?? Date.getCurrentDate()
        self.priorityValue = dictionary["priorityValue"] as? Int ?? 0
        self.authenticationToken = dictionary["authenticationToken"] as? String ?? ""
        self.tokenFIR = dictionary["tokenFIR"] as? String ?? ""
        self.following = dictionary["following"] as? [String] ?? []
        self.businessFollowing = dictionary["businessFollowing"] as? [String] ?? []
        self.email = dictionary["email"] as? String ?? ""
    }
	
	override var description: String {
		return "NAME: \(name ?? "NIL")\nUSERNAME: \(username)\nFOLLOWER COUNT: \(followerCount)\nPROFILE PIC: \(profilePicURL ?? "NIL")\nCATEGORIES: \(GetCategoryStringFromlist(categories: categories ?? []))\nAVERAGE LIKES: \(averageLikes ?? -404)"
	}
}

class Comapny: NSObject {
    var accountBalance: Double?
    var account_ID: String?
    var logo: String?
    var name: String?
    var owner: String?
    var referralcode: String?
    var website: String?
    init(dictionary: [String: Any]) {
        self.accountBalance = dictionary["accountBalance"] as? Double ?? 0
        self.account_ID = dictionary["account_ID"] as? String ?? ""
        self.logo = dictionary["logo"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.owner = dictionary["owner"] as? String ?? ""
        self.referralcode = dictionary["referralcode"] as? String ?? ""
        self.website = dictionary["website"] as? String ?? ""
    }
}

// Structure for Bank information
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

//added by ram
class DwollaCustomerFSList: NSObject {
    
    var acctID = ""
    var firstName = ""
    var lastName = ""
    var customerURL = ""
    var customerFSURL = ""
    var isFSAdded = false
    var mask = ""
    var name = ""
    
    init(dictionary: [String: Any]) {
        
        self.acctID = dictionary["accountID"] as! String
        self.firstName = dictionary["firstname"] as! String
        self.lastName = dictionary["lastname"] as! String
        self.customerURL = dictionary["customerURL"] as! String
        self.customerFSURL = dictionary["customerFSURL"] as! String
        self.isFSAdded = dictionary["isFSAdded"] as! Bool
        self.mask = dictionary["mask"] as! String
        self.name = dictionary["name"] as! String
    }
    
}

// Structure for Stripe details
class StripeAccDetail: NSObject {
    
    var access_token = ""
    var livemode = false
    var refresh_token = ""
    var token_type = ""
    var stripe_publishable_key = ""
    var stripe_user_id = ""
    var scope = ""
    
    init(dictionary: [String: Any]) {
        
        self.access_token = dictionary["access_token"] as! String
        self.livemode = dictionary["livemode"] as! Bool
        self.refresh_token = dictionary["refresh_token"] as! String
        self.token_type = dictionary["token_type"] as! String
        self.stripe_publishable_key = dictionary["stripe_publishable_key"] as! String
        self.stripe_user_id = dictionary["stripe_user_id"] as! String
        self.scope = dictionary["scope"] as! String
    }
    
}

//Structure for transaction History
class TransactionHistory: NSObject {
    
    var Amount = 0.0
    var To = ""
    var createdAt = ""
    var from = ""
    var id = ""
    var status = ""
    var type = ""
    var fee = 0.0
    
    init(dictionary: [String: Any]) {
        
        self.Amount = dictionary["Amount"] as! Double
        self.To = dictionary["To"] as! String
        self.createdAt = dictionary["createdAt"] as! String
        self.from = dictionary["from"] as! String
        self.id = dictionary["id"] as! String
        self.status = dictionary["status"] as! String
        self.type = dictionary["type"] as! String
        self.fee = dictionary["fee"] as? Double ?? 0.0

    }
    
}

// Structure for transaction Information
class TransactionInfo: NSObject {
    
    var acctID = ""
    var firstName = ""
    var lastName = ""
    var customerURL = ""
    var customerFSURL = ""
    var mask = ""
    var name = ""
    var transactionURL = ""
    var amount = ""
    var currency = ""
    
    init(dictionary: [String: Any]) {
        
        self.acctID = dictionary["accountID"] as! String
        self.firstName = dictionary["firstname"] as! String
        self.lastName = dictionary["lastname"] as! String
        self.customerURL = dictionary["customerURL"] as! String
        self.customerFSURL = dictionary["FS"] as! String
        self.mask = dictionary["mask"] as! String
        self.name = dictionary["name"] as! String
        self.transactionURL = dictionary["transferURL"] as! String
        self.amount = dictionary["currency"] as! String
        self.currency = dictionary["currency"] as! String
    }
    
}

//Structure for post
/*
struct Post {
	let image: String?
	let instructions: String
    let captionMustInclude: String?
	let products: [Product]?
	let post_ID: String
	let PostType: TypeofPost
	var confirmedSince: Date?
	var isConfirmed: Bool
    var denyMessage: String?
    var status: String?
	var hashtags: [String]
	var keywords: [String]
}
*/
struct Post {
    let image: String?
    let instructions: String
    let captionMustInclude: String?
    let products: [Product]?
    var post_ID: String
    let PostType: String
    //let PostType: TypeofPost
    var confirmedSince: Date?
    var isConfirmed: Bool
    var hashCaption: String
    var status: String
    var hashtags: [String]
    var keywords: [String]
    var isPaid: Bool?
    var PayAmount: Double?
    var denyMessage: String?
    
    func isFinished() -> [String] {
        var returnValue: [String] = []
        if instructions == "" {
            returnValue.append("instructions")
        }
        if hashtags == [] && keywords == [] {
            returnValue.append("hash and keywords")
        }
        if hashtags.contains("") {
            returnValue.append("empty hash")
        }
        if keywords.contains("") {
            returnValue.append("empty keyword")
        }
        return returnValue
    }
    
    func GetSummary(maxItems: Int = 5) -> String {
        var all = /*--->*/ [String](/*GROSS*/) //ew ~Marco Jan 18 2020
        for p in keywords {
            all.append("\"\(p)\"")
        }
        for h in hashtags {
            all.append("#\(h)")
        }
        
        if all.count == 0 {
            if maxItems == 5 {
                return "Post"
            } else {
                return "Incomplete Post"
            }
        } else {
            
            var str = ""
            for i in 0...(all.count - 1) {
                if i < maxItems {
                    str += all[i] + ", "
                }
            }
            str = String(str.dropLast(2))
            return str
        }
    }
    
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
    var followers: [String]?
}

class CompanyDetails: NSObject {
    var name: String
    var logo: String?
    var mission: String
    var website: String?
    var account_ID: String?
    var userId: String?
    var accountBalance: Double?
    var owner: String?
    var referralcode: String?
    var followers: [String]?
    
    
    init(dictionary:[String: AnyObject]){
        
        self.name  = dictionary["name"] as! String
        self.logo  = dictionary["logo"] as? String ?? ""
        self.mission = dictionary["mission"] as! String
        self.website  = dictionary["website"] as? String ?? ""
        self.account_ID  = dictionary["account_ID"] as? String ?? ""
        self.userId  = dictionary["userId"] as? String ?? ""
        self.accountBalance  = dictionary["accountBalance"] as? Double ?? 0.0
        self.owner  = dictionary["owner"] as? String ?? ""
        self.referralcode  = dictionary["referralcode"] as? String ?? ""
        self.followers  = dictionary["followers"] as? [String] ?? []
        
    }
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

enum Status: String {
    case available, accepted, rejected
}
    

//Amount refound funcs
class Deposit: NSObject {
    var userID: String?
    var currentBalance: Double?
    var totalDepositAmount: Double?
    var totalDeductedAmount: Double?
    var lastDeductedAmount: Double?
    var lastDepositedAmount: Double?
    var lastTransactionHistory: TransactionDetails?
    var depositHistory: [Any]?
    
    init(dictionary: [String: Any]) {
        
        self.userID = dictionary["userID"] as? String
        self.currentBalance = dictionary["currentBalance"] as? Double
        self.totalDepositAmount = dictionary["totalDepositAmount"] as? Double
        self.totalDeductedAmount = dictionary["totalDeductedAmount"] as? Double
        self.lastDeductedAmount = dictionary["lastDeductedAmount"] as? Double
        self.lastDepositedAmount = dictionary["lastDepositedAmount"] as? Double
        self.lastTransactionHistory = TransactionDetails.init(dictionary: dictionary["lastTransactionHistory"] as! [String : Any])
        self.depositHistory = dictionary["depositHistory"] as? [Any]
        
    }
    
}

class TransactionDetails: NSObject {
    var id: String?
    var status: String?
    var type: String?
    var currencyIsoCode: String?
    var amount: String?
    var createdAt: String?
    var updatedAt: String?
    var transactionType: String?
    var cardDetails: Any?
    var userName: String?
    var offerName: String?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.status = dictionary["status"] as? String
        self.type = dictionary["type"] as? String
        self.currencyIsoCode = dictionary["currencyIsoCode"] as? String
        self.amount = dictionary["amount"] as? String
        self.createdAt = dictionary["createdAt"] as? String
        self.updatedAt = dictionary["updatedAt"] as? String
        if dictionary.keys.contains("creditCard") {
            if dictionary["creditCard"] != nil {
                self.cardDetails = dictionary["creditCard"]
            }
        }else if dictionary.keys.contains("paypalAccount") {
            if dictionary["creditCard"] != nil {
                self.cardDetails = dictionary["paypalAccount"]
            }
        }else if dictionary.keys.contains("cardDetails") {
            if dictionary["cardDetails"] != nil {
                self.cardDetails = dictionary["cardDetails"]
            }
        }else if dictionary.keys.contains("paidDetails") {
            if dictionary["paidDetails"] != nil {
                self.cardDetails = dictionary["paidDetails"]
            }
        }
        self.userName = dictionary["userName"] as? String
        self.offerName = dictionary["offerName"] as? String
    }
    
}

var FreePass = false //If user has a newer app version; Not beta code required.

