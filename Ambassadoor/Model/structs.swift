//
//  structs.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/22/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import Foundation
import UIKit
import CoreData

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
    @IBInspectable var cornerRadius: Float = 10 { didSet { updateCornerRadius() } }
    @IBInspectable var ShadowOpacity: Float = 0 { didSet { updateShadows() } }
    @IBInspectable var ShadowRadius: Float = 1.75 { didSet { updateShadows() } }
    @IBInspectable var ShadowColor: UIColor = UIColor.black { didSet { updateShadows() } }
    @IBInspectable var borderWidth: Float = 0.0 { didSet { updateBorder() } }
	@IBInspectable var borderColor: UIColor = GetForeColor() { didSet { updateBorder() }}
	
	func DrawShadows() {
		//draw shadow & rounded corners for offer cell
		updateCornerRadius()
		updateShadows()
		updateBorder()
    }
	
	func updateCornerRadius() {
		if cornerRadius != 0 {
			self.layer.cornerRadius = CGFloat(cornerRadius)
		}
	}
	
	func updateShadows() {
		if ShadowOpacity != 0 {
			self.layer.shadowColor = ShadowColor.cgColor
			self.layer.shadowOpacity = ShadowOpacity
			self.layer.shadowOffset = CGSize.zero
			self.layer.shadowRadius = CGFloat(ShadowRadius)
		}
	}
	
	func updateBorder() {
		if borderWidth != 0 {
			self.layer.borderWidth = CGFloat(borderWidth)
			self.layer.borderColor = borderColor.cgColor
			self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
		}
	}
	
}

//Structure for an offer that comes into username's inbox
class Offer: NSObject {
    
    var status: String
	var money: Double
    var originalAmount: Double?
    
    var company: Company?
	var posts: [Post]
	let offerdate: Date
	let offer_ID: String
	var expiredate: Date
	var allPostsConfirmedSince: Date?
    var allConfirmed: Bool?
	var isAccepted: Bool
	var isExpired: Bool {
		if self.isDefaultOffer {
			return false
		}
		if let ad = acceptedDate {
			//hour * 48
			return ad.addingTimeInterval(TimeInterval(3600 * 48 * self.posts.count)).timeIntervalSinceNow <= 0
		} else {
			return false
		}
	}
	var debugInfo: String {
		return "Offer by \(String(describing: company?.name)) for $\(String(money)) that is \(isExpired ? "" : "not ") expired."
	}
    var ownerUserID: String
    var title: String
    
    var isRefferedByInfluencer: Bool?
    var isReferCommissionPaid: Bool?
    var referralAmount: Double?
    var referralCommission: Double?
    var referralID: String?
	var enoughCashForInfluencer: Bool {
		get {
			if self.isDefaultOffer {
				return true
			}
			let pay = calculateCostForUser(offer: self, user: Yourself, increasePayVariable: self.incresePay ?? 1)
			if let cashPower = self.cashPower {
				return pay <= cashPower
			} else {
				return false
			}
		}
	}
    
    var cashPower: Double?
    
    var influencerFilter: [String: AnyObject]?
    
    var incresePay: Double?
    
	var coDetails: CompanyDetails?
	var companyDetails: CompanyDetails?
    {
		get {
			let updatedCompany = global.BusinessUser.filter({ (co1) -> Bool in
				return co1.userId ?? "" == self.businessAccountID
				}).first
			if updatedCompany == nil {
				return coDetails
			} else {
				return updatedCompany
			}
		}
	}
	var businessAccountID: String
    var accepted: [String]?
    
	var notAccepted: Bool {
		get {
			return self.variation == .canBeAccepted || self.variation == .canNotBeAccepted
		}
	}
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
    var acceptedDate: Date?
	
	
	
	//added for bars (for example)
	var mustBe21: Bool
	var verifiedDate: Date?
	
	var isDefaultOffer: Bool {
		get {
			return self.offer_ID == "XXXDefault"
		}
	}
	
    var reservedUsers: [String: [String: AnyObject]]?
	
	var isFiltered: Bool {
		get {
			if self.isDefaultOffer {
				return true
			}
			return offerIsFiliteredForUser(offer: self)
		}
	}
	
	var isCancelledByUser: Bool {
		get {
			return self.posts.filter{$0.denyMessage ?? "" == "You cancelled the offer." }.count > 0
		}
	}
    
	var isForTesting: Bool {
		get {
			return self.companyDetails?.isForTesting ?? false
		}
	}
    
	
	var variation: OfferVariation {
		get {
			let isFollowed: Bool = Yourself.businessFollowing!.contains(self.businessAccountID)
			let isAccepted2 = self.accepted?.contains(Yourself.id) ?? false
			if !(isAccepted || isAccepted2) {
				if self.isDefaultOffer {
					return .canBeAccepted
				}
				if isFollowed {
					return .canBeAccepted
				}
				if let diff = Calendar.current.dateComponents([.hour], from: offerdate, to: Date()).hour, diff > 168 {
					return .canBeAccepted
				}
				
				return isFiltered ? .canBeAccepted : .canNotBeAccepted
			} else {
				let total = posts.count
				let postedCount = (posts.filter {$0.status == "posted"}).count
				let verifiedCount = (posts.filter {$0.status == "verified"}).count
				let rejectedCount = (posts.filter {$0.status == "rejected" || $0.status == "denied"}).count
				let paidCount = (posts.filter {$0.status == "paid"}).count
				let missing = total - (postedCount + verifiedCount + rejectedCount + paidCount)
				let notPostedCount = isExpired ? 0 : missing
				let expiredCount = isExpired ? missing : 0
				
				if notPostedCount == 0 {
					if rejectedCount == total {
						return .allPostsDenied
					} else {
						if expiredCount == total {
							return .didNotPostInTime
						}
						if paidCount == verifiedCount + postedCount {
							return .hasBeenPaid
						}
						return .hasBeenPaid
					}
				} else {
					return .inProgress
				}
			}
		}
	}
	
	
	
	
	
    
    init(dictionary: [String: AnyObject]) throws {
//        let err = isDeseralizable(dictionary: dictionary, type: .offer)
//		if err.count > 0 {
//			throw NSError(domain: err.joined(separator: ", "), code: 101, userInfo: ["class": "Offer Class", "value": dictionary])
//		}
		self.acceptedDate =  ((dictionary["updatedDate"] as? String) != nil) ? getDateFromString(date: dictionary["updatedDate"] as! String) : nil
        self.status = dictionary["status"] as! String
        self.money = dictionary["money"] as! Double
        self.originalAmount = dictionary["originalAmount"] as? Double ?? 0.0
        self.company = nil
		if let companyDetails = dictionary["companyDetails"] as? [String: AnyObject] {
			self.company = Company.init(dictionary: companyDetails)
        }
		
		
        
        var postVal = [Post]()
        
        /*
         ["image":post.image!,"instructions":post.instructions,"captionMustInclude":post.captionMustInclude!,"products":product,"post_ID":post.post_ID,"PostType": post.PostType,"confirmedSince":"" ,"isConfirmed":post.isConfirmed,"hashCaption":post.hashCaption,"status": post.status,"hashtags": post.hashtags, "keywords": post.keywords, "isPaid": post.isPaid ?? false, "PayAmount": post.PayAmount ?? 0.0]
         */
		
		if let posDict = dictionary["posts"] as? [[String: AnyObject]]{
			
			for post in posDict {
                do {
                    var thisPost = try Post.init(dictionary: post)
                    if !thisPost.hashtags.contains("ad") {
                        thisPost.hashtags.append("ad")
                    }
                    postVal.append(thisPost)
                } catch let error {
                    print(error)
                }
				
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
        self.incresePay = dictionary["incresePay"] as? Double ?? 1.0
        
		if var comDetailsDict = dictionary["companyDetails"] as? [String: AnyObject] {
			do {
				comDetailsDict["userId"] = dictionary["ownerUserID"]
			 self.coDetails = try CompanyDetails.init(dictionary: comDetailsDict)
			} catch let error {
				print(error)
			}
        }
//		print(dictionary)
		//		print("\nGoing To Fail Now\n")
		if let coId = dictionary["ownerUserID"] as? String {
			self.businessAccountID = coId
		} else {
			if let companyDeets = dictionary["companyDetails"] as? [String: AnyObject] {
				self.businessAccountID = companyDeets["userId"] as? String ?? ((dictionary["company"] as? String) ?? "BRUV")
			} else {
				self.businessAccountID = (dictionary["company"] as? String) ?? "BRUV"
			}
		}
			
		//in case it doesn't have this information, we want to be safe legally.
		self.mustBe21 = dictionary["mustBeTwentyOne"] as? Bool ?? true
		self.verifiedDate = dictionary["verifiedDate"] as? Date
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
        self.reservedUsers = dictionary["reservedUsers"] as? [String: [String: AnyObject]] ?? [:]
        self.allConfirmed = dictionary["allConfirmed"] as? Bool ?? false
        //self.isForTesting = dictionary["isForTesting"] as? Bool ?? false
        
    }
}

class InfluencerAuthenticationUser: NSObject {
    
    var email: String
    var createdAt: String
    var password: String
    var SignedIn: String
    var userid: String
    var username: String
    
    init(dictionary: [String: AnyObject]){
        
        self.email = dictionary["email"] as? String ?? ""
        self.createdAt = dictionary["createdAt"] as? String ?? ""
        self.password = dictionary["password"] as? String ?? ""
        self.SignedIn = dictionary["SignedIn"] as? String ?? ""
        self.userid = dictionary["userid"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""

        
    }
    
}

//Strcuture for users
class User: NSObject {
	let name: String?
	let username: String
	let followerCount: Double
	var profilePicURL: String?
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
    var version: String?
    var isForTesting: Bool
    //followerCount
    init(dictionary: [String: Any]) throws {
        guard let name = dictionary["name"] as? String else{
            throw NSError(domain: "name returned nil", code: 101, userInfo: ["class": "userclass", "value":dictionary])
        }
        self.name = name
        
        guard let username = dictionary["username"] as? String else{
            throw NSError(domain: "username returned nil", code: 101, userInfo: ["class": "userclass", "value":dictionary])
        }
        self.username = username
        
        guard let followerCount = dictionary["followerCount"] as? Int64 else {
            throw NSError(domain: "followerCount returned nil", code: 101, userInfo: ["class": "userclass", "value":dictionary])
        }
        self.followerCount = Double(followerCount)
        
        guard let profilePic = dictionary["profilePicture"] as? String else {
            throw NSError(domain: "profilePic returned nil", code: 101, userInfo: ["class": "userclass", "value":dictionary])
        }
        self.profilePicURL = profilePic
        
        guard let averageLikes = dictionary["averageLikes"] as? Double else {
            throw NSError(domain: "averageLikes returned nil", code: 101, userInfo: ["class": "userclass", "value":dictionary])
        }
		self.averageLikes = averageLikes
        
        guard let id =  dictionary["id"] as? String else {
             throw NSError(domain: "id returned nil", code: 101, userInfo: ["class": "userclass", "value":dictionary])
        }
        self.id = id
        
		self.zipCode = dictionary["zipCode"] as? String
        self.gender = Gender(rawValue: dictionary["gender"] as? String ?? "Male")
        //self.gender = (dictionary["gender"] as? Gender.RawValue).map { Gender(rawValue: $0) }!
        self.isBankAdded = dictionary["isBankAdded"] as! Bool 
        self.yourMoney = dictionary["yourMoney"] as? Double ?? 0.0
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
		if self.businessFollowing!.contains("") {
			self.businessFollowing = self.businessFollowing!.filter{$0 != ""}
		}
        self.email = dictionary["email"] as? String ?? ""
        self.version = dictionary["version"] as? String ?? "0.0.0"
        self.isForTesting = dictionary["isForTesting"] as? Bool ?? false
    }
	
	override var description: String {
		return "NAME: \(name ?? "NIL")\nUSERNAME: \(username)\nFOLLOWER COUNT: \(followerCount)\nPROFILE PIC: \(profilePicURL ?? "NIL")\nCATEGORIES: \(GetCategoryStringFromlist(categories: categories ?? []))\nAVERAGE LIKES: \(averageLikes ?? -404)\nVERSION: \(version)\nisForTesting: \(isForTesting)"
	}
}

class Follower: NSObject {
    
    var identifier: String?
    var user: User?
    var startedAt: String?
    
    init(dictionary: [String: AnyObject]){
        self.identifier = dictionary["identifier"] as? String ?? ""
        if let userDict = dictionary["user"] as? [String: AnyObject] {
        do {
            self.user = try User.init(dictionary: userDict)
        } catch let error {
            print(error)
        }
        }
        self.startedAt = dictionary["startedAt"] as? String ?? ""
    }
}

class FollowingInformation: NSObject {
    
    var identifier: String?
    var user: User?
    var startedAt: Date
    var startedAtString: String?
    var offer: Offer?
    var tag: String?
    
    init(dictionary: [String: AnyObject]){
        self.identifier = dictionary["identifier"] as? String ?? ""
        if let userDict = dictionary["user"] as? [String: AnyObject] {
            do {
                self.user = try User.init(dictionary: userDict)
            } catch let error {
                print(error)
            }
        
        }
        if let date = dictionary["startedAt"] as? String {
            self.startedAt = getDateFromString(date: date)
        }else{
            let curDateStr = Date.getStringFromDate(date: Date())
            let currentDate = Date.getDateFromString(date: curDateStr!)!
            self.startedAt = currentDate
        }
        //self.startedAtString = dictionary["startedAt"] as? String ?? ""
        self.startedAtString = Date.getDateFromStringWithConvertedFormatFormat(date: dictionary["startedAt"] as? String ?? "", format: "MMM dd YYYY")
        if let offer = dictionary["offer"] as? [String: AnyObject]{
            do {
                self.offer = try Offer.init(dictionary: offer)
            } catch let error {
                print(error)
            }
            
        }
        self.tag = dictionary["tag"] as? String ?? ""
        
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

struct Post {
    let image: String?
    let instructions: String
    let captionMustInclude: String?
    //let products: [Product]?
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
    
    init(dictionary: [String: AnyObject]) throws {
        self.image = dictionary["image"] as? String
        self.instructions = dictionary["instructions"] as! String
        self.captionMustInclude = ""
//        self.products = dictionary["products"] as? [Product]
        self.post_ID = dictionary["post_ID"] as! String
        PostType = dictionary["PostType"] as! String
        self.confirmedSince = Date.getDateFromString(date: dictionary["confirmedSince"] as? String ?? "") ?? nil
        self.isConfirmed = dictionary["isConfirmed"] as! Bool
        self.hashCaption = dictionary["hashCaption"] as? String ?? ""
        guard let status = dictionary["status"] as? String else{
            throw NSError(domain: "post status returned nil", code: 101, userInfo: ["class": "Post Struct", "value":dictionary])
        }
        self.status = status
        self.hashtags = dictionary["hashtags"] as? [String] ?? []
        self.keywords = dictionary["keywords"] as? [String] ?? []
        self.isPaid = dictionary["isPaid"] as? Bool
        PayAmount = dictionary["PayAmount"] as? Double ?? 0.0
        self.denyMessage = dictionary["denyMessage"] as? String ?? ""
    }
    
}
//struct for company
class Company: NSObject {
	var userID: String?
	let account_ID: String?
	var name: String
	var logo: String?
	var mission: String
	var website: String
	let owner_email: String
	let companyDescription: String
	var accountBalance: Double
	var referralcode: String?
	var isForTesting: Bool
	
	
	init(dictionary: [String: Any]) {
		self.account_ID = dictionary["account_ID"] as? String
		self.name = dictionary["name"] as! String
		self.logo = dictionary["logo"] as? String
		self.mission = dictionary["mission"] as! String
		self.website = dictionary["website"] as! String
		self.owner_email = (dictionary["owner"] as? String) ?? ""
		self.companyDescription = dictionary["description"] as! String
		self.accountBalance = dictionary["accountBalance"] as! Double
		self.referralcode = dictionary["referralcode"] as? String ?? ""
		self.userID = dictionary["userId"] as? String ?? ""
		self.isForTesting = dictionary["isForTesting"] as? Bool ?? false
	}
}

class CompanyUser: NSObject {
	var userID: String?
	var token: String?
	var email: String?
	var refreshToken: String?
	var isCompanyRegistered: Bool?
	var companyID: String?
	var deviceFIRToken: String?
	var businessReferral: String?
	var isForTesting: Bool
	
	
	init(dictionary: [String: Any]) {
		
		self.userID = dictionary["userID"] as? String
		self.token = dictionary["token"] as? String
		self.email = dictionary["email"] as? String
		self.refreshToken = dictionary["refreshToken"] as? String
		self.isCompanyRegistered = dictionary["isCompanyRegistered"] as? Bool
		self.companyID = dictionary["companyID"] as? String
		self.deviceFIRToken = dictionary["deviceFIRToken"] as? String ?? ""
		self.businessReferral = dictionary["businessReferral"] as? String ?? ""
		self.isForTesting = dictionary["isForTesting"] as? Bool ?? false
	}
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
	var isForTesting: Bool
	var isOfficialAmbassadoorAccount: Bool {
		get {
			return self.userId ?? "" == "C2bxiVNW58UxcPiBe2rihN81e302"
		}
	}
    
    
    init(dictionary:[String: AnyObject]) throws {
		
		let err = isDeseralizable(dictionary: dictionary, type: .businessDetails)
		if err.count > 0 {
			throw NSError(domain: err.joined(separator: ", "), code: 101, userInfo: ["class": "Business Details Class", "value": dictionary])
		}
        
        self.name  = dictionary["name"] as! String
        self.logo  = dictionary["logo"] as? String ?? ""
        self.mission = dictionary["mission"] as! String
        self.website  = dictionary["website"] as? String ?? ""
        self.account_ID  = dictionary["account_ID"] as? String ?? ""
        self.userId = dictionary["userId"] as? String
        self.accountBalance  = dictionary["accountBalance"] as? Double ?? 0.0
        self.owner  = dictionary["owner"] as? String ?? ""
        self.referralcode  = dictionary["referralcode"] as? String ?? ""
        self.followers  = dictionary["followers"] as? [String] ?? []
        self.isForTesting = dictionary["isForTesting"] as? Bool ?? false
		if self.userId == "lztskONVPcSnisJkoTcWn4F16MI2" {
			self.isForTesting = true
		}
    }
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

class businessDeposit: NSObject {
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
		self.currentBalance = dictionary["currentBalance"] as? Double ?? 0.0
		self.totalDepositAmount = dictionary["totalDepositAmount"] as? Double ?? 0.0
		self.totalDeductedAmount = dictionary["totalDeductedAmount"] as? Double ?? 0.0
		self.lastDeductedAmount = dictionary["lastDeductedAmount"] as? Double ?? 0.0
		self.lastDepositedAmount = dictionary["lastDepositedAmount"] as? Double ?? 0.0
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

class CachedImages: NSObject {
    var link: String?
    var imagedata: Data?
    var object: NSManagedObject?
    var date: Date?
    
    init(object: NSManagedObject) {
        self.link = (object.value(forKey: "url") as! NSString) as String
        self.imagedata = (object.value(forKey: "imagedata") as! Data)
        self.date = (object.value(forKey: "updatedDate") as? Date ?? Date.getcurrentESTdate())
        self.object = object
    }
}

var FreePass = false //If user has a newer app version; Not beta code required.

enum SuspiciousFlags: String {
    case zeroPost = "User has made zero post",
    veryLowFollowers = "like to follow ratio very low",
    moreLikesThanFollowers = "This person gets more likes than followers.",
    overMoneyExcess = "Suspicoius Offer Money"
    
}

class TemplateOffer: Offer {
	var targetCategories: [String]
	var locationFilter: String
	var lastEdited: Date
	var isStatistic: Bool
	

	override init(dictionary: [String: AnyObject])throws {
		self.locationFilter = dictionary["locationFilter"] as? String ?? ""
		self.targetCategories = dictionary["targetCategories"] as? [String] ?? []
		self.isStatistic = false
		self.targetCategories = []
		self.lastEdited = Date()
		try super.init(dictionary: dictionary)
		self.category = dictionary["category"] as? [String] ?? []
		self.title = dictionary["title"] as? String ?? ""
		self.genders = dictionary["genders"] as? [String] ?? []
		self.user_IDs = dictionary["user_IDs"] as? [String] ?? []
		self.status = dictionary["status"] as? String ?? ""
	}
	
	func GetSummary() -> String {
		var lines: [String] = []
		if self.posts.count == 1 {
			lines.append("This Offer has 1 Post.")
		} else if self.posts.count == 0 {
			lines.append("This Offer doesn't have posts yet.")
		} else {
			lines.append("This Offer has \(self.posts.count) Posts:")
		}
		var index = 1
		for post in self.posts {
			lines.append("• Post #\(index): \(post.GetSummary(maxItems: 2))")
			index += 1
		}
		lines.append("")
		//lines.append("Has been sent to \(user_IDs.count) influencer\(user_IDs.count != 1 ? "s" : "").")
		return lines.joined(separator: "\n")
	}
}
