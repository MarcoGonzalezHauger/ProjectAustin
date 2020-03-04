//
//  Savvy.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/22/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import Foundation
import UIKit
import Firebase

func NumberToPrice(Value: Double, enforceCents isBig: Bool = false) -> String {
	if floor(Value) == Value && isBig == false {
		return "$" + String(Int(Value))
	}
	let formatter = NumberFormatter()
	formatter.locale = Locale(identifier: "en_US")
	formatter.numberStyle = .currency
	if let formattedAmount = formatter.string(from: Value as NSNumber) {
		return formattedAmount
	}
	return ""
}

func YouShallNotPass(SaveButtonView viewToReject: UIView, returnColor rcolor: UIColor = .systemBlue) {
	
	UseTapticEngine()
	
	MakeShake(viewToShake: viewToReject)
	
	viewToReject.backgroundColor = .systemRed
	DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
		UIView.animate(withDuration: 0.8) {
			viewToReject.backgroundColor = rcolor
		}
	}
	
}


func AnimateLabelText(label: UILabel, text textstring: String) {
	let animation: CATransition = CATransition()
	animation.timingFunction = CAMediaTimingFunction(name:
		CAMediaTimingFunctionName.easeInEaseOut)
	animation.type = CATransitionType.push
	animation.subtype = CATransitionSubtype.fromTop
	label.text = textstring
	animation.duration = 0.25
	label.layer.add(animation, forKey: CATransitionType.push.rawValue)
}

// open external for google search words
func GoogleSearch(query: String) {
	let newquery = query.replacingOccurrences(of: " ", with: "+")
	if let url = URL(string: "https://www.google.com/search?q=\(newquery)") {
		UIApplication.shared.open(url, options: [:])
	}
}

func DateToAgo(date: Date) -> String {
	let i : Double = date.timeIntervalSinceNow * -1
	switch true {
		
	case i < 60 :
		return "now"
	case i < 3600:
		return "\(Int(floor(i/60)))m ago"
	case i < 21600:
		return "\(Int(floor(i/3600)))h ago"
	case i < 86400:
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.dateFormat = "h:mm a"
		formatter.amSymbol = "AM"
		formatter.pmSymbol = "PM"
		return formatter.string(from: date)
	default:
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.dateFormat = "MM/dd/YYYY"
		return formatter.string(from: date)
	}
}

func DateToCountdown(date: Date) -> String? {
	let i : Double = date.timeIntervalSinceNow
	let pluralSeconds: Bool = Int(i) % 60 != 1
	let pluralMinutes: Bool = Int(floor(i/60)) % 60 != 1
	let pluralHours: Bool = Int(floor(i/3600)) % 24 != 1
	let pluralDays: Bool = Int(floor(i/86400)) % 365 != 1
	switch true {
	case Int(i) <= 0:
		return nil
	case i < 60 :
		return "in \(Int(i)) second\(pluralSeconds ? "s" : "")"
	case i < 3600:
		return "in \(Int(floor(i/60))) minute\(pluralMinutes ? "s" : ""), \(Int(i) % 60) second\(pluralSeconds ? "s" : "")"
	case i < 86400:
		return "in \(Int(floor(i/3600))) hour\(pluralHours ? "s" : ""), \(Int(floor(Double((Int(i) % 3600) / 60)))) minute\(pluralMinutes ? "s" : "")"
	case i < 604800:
		return "in \(Int(floor(i/86400))) day\(pluralDays ? "s" : ""), \(Int(floor(Double((Int(i) % 86400) / 3600)))) hour\(pluralHours ? "s" : "")"
	default:
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.dateFormat = "MM/dd/YYYY"
		return "in " + formatter.string(from: date)
	}
}

func DateToLetterCountdown(date: Date) -> String? {
	let i : Double = date.timeIntervalSinceNow
	switch true {
	case Int(i) <= 0:
		return nil
	case i < 60 :
		return "\(Int(i))s"
	case i < 3600:
		return "\(Int(floor(i/60)))m \(Int(i) % 60)s"
	case i < 86400:
		return "\(Int(floor(i/3600)))h \(Int(floor(Double((Int(i) % 3600) / 60))))m \(Int(i) % 60)s"
	case i < 604800:
		return "\(Int(floor(i/86400)))d \(Int(floor(Double((Int(i) % 86400) / 3600))))h \(Int(floor(Double((Int(i) % 3600) / 60))))m \(Int(i) % 60)s"
	default:
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.dateFormat = "MM/dd/YYYY"
		return formatter.string(from: date)
	}
}

func NumberToStringWithCommas(number: Double) -> String {
	let numformat = NumberFormatter()
	numformat.numberStyle = NumberFormatter.Style.decimal
	return numformat.string(from: NSNumber(value:number)) ?? String(number)
}

// Tier level array
let TierThreshholds: [Double] = [0, 100, 200, 300, 500, 750, 1000, 1250, 1500, 2000, 3000, 4000, 5000, 6250, 7750, 9500, 11500, 13750, 16250, 19000, 22000, 25250, 28750]

// get Tier level based on the instagram followers count
func GetTierFromFollowerCount(FollowerCount: Double) -> Int? {
	
	var index: Int = 0
	var max: Int = 0
	while index < TierThreshholds.count {
		if FollowerCount > TierThreshholds[index] {
			max = index
		} else {
			return max
		}
		index += 1
	}
	return TierThreshholds.count
}

// get organic subscription fee amount based on instagram followers count
func GetFeeFromFollowerCount(FollowerCount: Double) -> Int? {
    
    //Tier is grouping people of similar follower count to encourage competition between users.
    
    switch FollowerCount {
    case 0...749: return 2
    case 750...1249: return 3
    case 1250...2999: return 4
    case 3000...: return 5
    default: return nil
    }
}

func makeImageCircular(image: UIImage) -> UIImage {
	let ImageLayer = CALayer()
	
	ImageLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
	ImageLayer.contents = image.cgImage
	ImageLayer.masksToBounds = true
	ImageLayer.cornerRadius = image.size.width/2
	
	UIGraphicsBeginImageContext(image.size)
	ImageLayer.render(in: UIGraphicsGetCurrentContext()!)
	let NewImage = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	
	return NewImage!;
}

func PostTypeToIcon(posttype: TypeofPost) -> UIImage {
	switch posttype {
	case .SinglePost:
		return UIImage(named: "singlepost_icon")!
	case .MultiPost:
		return UIImage(named: "multipost_icon")!
	case .Story:
		return UIImage(named: "storypost_icon")!
	}
}

func GetCategoryStringFromlist(categories: [String]) -> String {
	var finalCategories = ""
	for category in categories {
		if AllCategories.contains(category) {
			finalCategories.append(category + ", ")
		}
	}

	if finalCategories != "" {
		finalCategories = String(finalCategories.dropLast(2))
	}
	
	return finalCategories
}


// get offer information using offerID
func OfferFromID(id: String, completion:@escaping(_ offer:Offer?)->()) {
	print("attempting to find offer with ID \(id)")
	
	////    return global.AvaliableOffers.filter { (ThisOffer) -> Bool in
	////        return ThisOffer.offer_ID == id
	////    }[0]
	//
	//    //naveen added
	//    let val =  global.AvaliableOffers.filter { (ThisOffer) -> Bool in
	//        return ThisOffer.offer_ID == id
	//    }
	//    return val.count > 0 ? val[0] : global.AvaliableOffers[0];
	
	print(UserDefaults.standard.object(forKey: "userid") as! String)
	print(UserDefaults.standard.object(forKey: "token") as! String)
	//naveen added
	if UserDefaults.standard.object(forKey: "userid") != nil &&  UserDefaults.standard.object(forKey: "token") != nil {
		
		let userid = UserDefaults.standard.object(forKey: "userid") as! String
		let ref = Database.database().reference().child("SentOutOffersToUsers").child(userid).child(id)
		ref.observeSingleEvent(of: .value, with: {(snapshot) in
			print(snapshot.childrenCount)
			if let offer = snapshot.value as? [String: AnyObject] {
				var offerDictionary = offer as? [String: AnyObject]
				//company detail fetch data
				let compref = Database.database().reference().child("companies").child(offerDictionary!["ownerUserID"] as! String).child(offerDictionary!["company"] as! String)
				compref.observeSingleEvent(of: .value, with: { (dataSnapshot) in
					if let company = dataSnapshot.value as? [String: AnyObject] {
						let companyDetail = Company.init(name: company["name"] as! String, logo:
							company["logo"] as? String, mission: company["mission"] as! String, website: company["website"] as! String, account_ID: company["account_ID"] as! String, instagram_name: company["name"] as! String, description: company["description"] as! String)
						
						offerDictionary!["company"] = companyDetail as AnyObject
						
						//post detail fetch data
						if let posts = offerDictionary!["posts"] as? NSMutableArray{
							var postfinal : [Post] = []
							
							for postv in posts {
								var post = postv as! [String:AnyObject]
								var productfinal : [Product] = []
								
								if let products = post["products"] as? NSMutableArray{
									for productDic in products {
										let product = productDic as! [String:AnyObject]
										productfinal.append(Product.init(image: (product["image"] as! String), name: product["name"] as! String, price: product["price"] as! Double, buy_url: product["buy_url"] as! String, color: product["color"] as! String, product_ID: product["product_ID"] as! String))
									}
									post["products"] = productfinal as AnyObject
								}
								
								postfinal.append(Post.init(image: post["image"] as? String, instructions: post["instructions"] as! String, products: post["products"] as? [Product] , post_ID: post["post_ID"] as! String, PostType: TextToPostType(posttype: post["PostType"] as! String), confirmedSince: post["confirmedSince"] as? Date, isConfirmed: post["isConfirmed"] as! Bool,denyMessage: post["denyMessage"] as? String ?? "",status: post["status"] as? String ?? "", hashtags: post["hashtags"] as? [String] ?? [], keywords: post["keywords"] as? [String] ?? []))
							}
							offerDictionary!["posts"] = postfinal as AnyObject
							let userInstanceOffer = Offer(dictionary: offerDictionary!)
							DispatchQueue.main.async {
								completion(userInstanceOffer)
							}
							
						}else{
							
						}
						
					}else{
						
					}
					
				}, withCancel: nil)
				
			}
		}, withCancel: nil)
		
	}else{
	}
}

func CompressNumber(number: Double) -> String {
	switch number {
	case 0...9999:
		return NumberToStringWithCommas(number: number)
	case 10000...99999:
		return "\(floor(number/100) / 10)K"
	case 100000...999999:
		return "\(floor(number/1000))K"
	case 1000000...9999999:
		return "\(floor(number/100000) / 10)M"
	case 10000000...999999999:
		return "\(floor(number/1000000))M"
	default:
		return String(number)
	}
}

func PostTypeToText(posttype: TypeofPost) -> String {
	switch posttype {
	case .SinglePost:
		return "Single Post"
	case .MultiPost:
		return "Multi Post"
	case .Story:
		return "Story Post"
	}
}

func TextToPostType(posttype: String) -> TypeofPost {
	switch posttype {
	case "Single Post":
		return .SinglePost
	case "Multi Post":
		return .MultiPost
	case "Story Post":
		return .Story
	default:
		return .SinglePost
	}
}


func TextToGender(gender: String) -> Gender {
	switch gender {
	case "Male":
		return .Male
	case "Female":
		return .Female
	case "Other":
		return .Other
	default:
		return .Other
	}
}

// Open App Store Application
func OpenAppStoreID(id: String) {
	if let url = URL(string: "https://apps.apple.com/us/app/\(id)"),
		UIApplication.shared.canOpenURL(url){
		if #available(iOS 10.0, *) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		} else {
			UIApplication.shared.openURL(url)
		}
	}
}

//String To Date conversion
func getDateFromString(date: String) -> Date {
	let dateFormatterGet = DateFormatter()
	dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
	
	let dateFormatterPrint = DateFormatter()
	dateFormatterPrint.dateFormat = "MMM dd,yyyy"
	
	if let date = dateFormatterGet.date(from: date) {
		//print(dateFormatterPrint.string(from: date))
		return date
	} else {
		print("There was an error decoding the string")
		return Date()
		
	}
	
}

//String To Date conversion
func getESTDateFromString(date: String) -> Date {
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.timeZone = TimeZone(abbreviation: "EST")
    dateFormatterGet.dateFormat = "yyyy/MMM/dd HH:mm:ss"
    print("currentDate =",Date())
//    let dateFormatterPrint = DateFormatter()
//    dateFormatterPrint.timeZone = TimeZone(abbreviation: "IST")
//    dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
//    dateFormatterPrint.string(from: estDate)
    
    if let date = dateFormatterGet.date(from: date) {
        //print(dateFormatterPrint.string(from: date))
        return date
    } else {
        print("There was an error decoding the string")
        return Date()
        
    }
    
}
// after signout user change local values and logout to instagram
func signOutofAmbassadoor() {
    UserDefaults.standard.set(nil, forKey: "token")
    UserDefaults.standard.set(nil, forKey: "userid")
    API.instaLogout()
    Yourself = nil
}

func getStringFromTodayDate() -> String {
	let formatter = DateFormatter()
	// initially set the format based on your datepicker date / server String
	formatter.dateFormat = "yyyy/MMM/dd HH:mm:ss"
	
	let myString = formatter.string(from: Date())
	
	return myString
}


func randomString(length: Int) -> String {
    let letters = "ABCDEFGHIJKLMNPQRSTUVWXYZ123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}

func MakeShake(viewToShake thisView: UIView, coefficient: Float = 1) {
	let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
	animation.timingFunction = CAMediaTimingFunction(name: .linear)
	animation.duration = 0.6
	animation.values = [-20.0 * coefficient, 20.0 * coefficient, -20.0 * coefficient, 20.0 * coefficient, -10.0 * coefficient, 10.0 * coefficient, -5.0 * coefficient, 5.0 * coefficient, 0 ]
	thisView.layer.add(animation, forKey: "shake")
}


func GetSortedOffers(offer:[Offer]) -> [Offer] {
    var sortedlist = offer
//
//    //This sort function makes sure of the following: The expired Offers go to the bottom, and then rest are sorted by time remaining decending.
//    sortedlist.sort { (Offer1, Offer2) -> Bool in
//        if Offer1.offerdate == Offer2.offerdate {
//            return Offer1.offerdate < Offer2.offerdate
//        }
//        return !Offer1.isExpired
	//    }
	
	sortedlist = sortedlist.sorted(by: {$0.offerdate > $1.offerdate})
	
	return sortedlist
}

// get tier level
func GetTierForInfluencer(influencer: User) -> Int {
	if influencer.isDefaultOfferVerify {
		return (GetTierFromFollowerCount(FollowerCount: influencer.followerCount) ?? 0) + 1
	} else {
		return GetTierFromFollowerCount(FollowerCount: influencer.followerCount) ?? 0
	}
}

// compare and verify Offer post and instagram post. and update sendoutoffer and influencerInstagrampost to FIR
func CheckForCompletedOffers(completion: (() -> Void)?) {
	print("Checking for completed Offers.")
	API.getRecentMedia { (mediaData: [[String:Any]]?) in
		for OfferIndex in 0..<(global.AcceptedOffers.count) {
			if global.AcceptedOffers[OfferIndex].isAccepted {
				if !global.AcceptedOffers[OfferIndex].allConfirmed {
					//get instagram user media data
					for var postVal in mediaData!{
                        //if let captionVal = (postVal["caption"] as? [String:Any]) {
						if let captionVal = (postVal["caption"] as? String) {
							let instacaption = captionVal
							if instacaption.contains("#ad"){
								print("Has #ad")
								for PostIndex in 0..<(global.AcceptedOffers[OfferIndex].posts.count) {
									print("On Post")
									if !global.AcceptedOffers[OfferIndex].posts[PostIndex].isConfirmed{
										print("Isn't Confirmed.")
										let hashtags = global.AcceptedOffers[OfferIndex].posts[PostIndex].hashtags
										let phrases = global.AcceptedOffers[OfferIndex].posts[PostIndex].keywords
										print("POST CAPTION: " + instacaption)
										//                                        postCaption.append("#ad.")
										//                                        postCaption.append(post.captionMustInclude!)
										
										var isGood = true
										for h in hashtags {
											if !instacaption.contains("#\(h)") {
												isGood = false
											}
										}
										
										for p in phrases {
											if !instacaption.contains(p) {
												isGood = false
											}
										}
										
										if isGood {
											print("Good Caption")
											global.AcceptedOffers[OfferIndex].posts[PostIndex].isConfirmed = true
											global.AcceptedOffers[OfferIndex].posts[PostIndex].confirmedSince = Date()
                                            postVal["status"] = "posted"
                                            postVal["type"] = "carousel"
                                            postVal["images"] = Yourself.profilePicURL ?? ""
                                            instagramPostUpdate(offerID: global.AcceptedOffers[OfferIndex].offer_ID, post: [global.AcceptedOffers[OfferIndex].posts[PostIndex].post_ID:postVal])
                                            let pushParam = ["offer":global.AcceptedOffers[OfferIndex].title,"token":Yourself.tokenFIR,"user":Yourself.username] as [String : AnyObject]
                                            sendPushNotification(params: pushParam)
                                            SentOutOffersUpdate(offer: global.AcceptedOffers[OfferIndex], post_ID: global.AcceptedOffers[OfferIndex].posts[PostIndex].post_ID, status: "posted")
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

func sendPushNotification(params: [String: AnyObject]){
    
    let urlString = "https://us-central1-amassadoor.cloudfunctions.net/" + "sendNotificationToInstagramDetected"
    
    let url = URL(string: urlString)!
    
    let session = URLSession.shared
    var request = URLRequest(url: url)
    request.httpMethod = "Post"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
    } catch let error {
        print(error.localizedDescription)
    }
    
    let task = session.dataTask(with: request) { (data, response, error) in
        if error != nil {
        let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        print("result=",dataString!)
        }
        
    }
    task.resume()
}

func ResortLocation() {
	
}

let impact = UIImpactFeedbackGenerator()
func UseTapticEngine() {
	impact.impactOccurred()
}

func GetForeColor() -> UIColor {
	if #available(iOS 13.0, *) {
		return .label
	} else {
		return .black
	}
}

func GetBackColor() -> UIColor {
	if #available(iOS 13.0, *) {
		return .systemBackground
	} else {
		return .white
	}
}

//refund funcs
func serializeTransactionDetails(transaction: TransactionDetails) -> [String: Any] {
    
	let transactionSerialize = ["id":transaction.id as Any,
								"userName":transaction.userName as Any,
								"status":transaction.status as Any,
								"offerName":transaction.offerName as Any,
								"type":transaction.type as Any,
								"currencyIsoCode":transaction.currencyIsoCode as Any,
								"amount":transaction.amount as Any,
								"createdAt":transaction.createdAt as Any,
								"updatedAt":transaction.updatedAt as Any,
								"cardDetails":transaction.cardDetails as Any] as [String: Any]
    
    return transactionSerialize
}

func sendDepositAmount(deposit: Deposit,companyUserID: String) {
    
    let ref = Database.database().reference().child("BusinessDeposit").child(companyUserID)
    var offerDictionary: [String: Any] = [:]

    offerDictionary = serializeDepositDetails(deposit: deposit)
	ref.updateChildValues(offerDictionary)
}

func serializeDepositDetails(deposit: Deposit) -> [String: Any] {
	let transactionData = serializeTransactionDetails(transaction: deposit.lastTransactionHistory!)
	let depositSerialize = ["userID":deposit.userID! as Any,
							"currentBalance":deposit.currentBalance! as Any,
							"totalDepositAmount":deposit.totalDepositAmount as Any,
							"totalDeductedAmount":deposit.totalDeductedAmount as Any,
							"lastDeductedAmount":deposit.lastDeductedAmount as Any,
							"lastDepositedAmount":deposit.lastDepositedAmount as Any,
							"lastTransactionHistory":transactionData as Any,
							"depositHistory":deposit.depositHistory as Any] as [String : Any]
	
    return depositSerialize
}


