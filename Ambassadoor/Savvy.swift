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


func GetTierFromFollowerCount(FollowerCount: Double) -> Int? {
	
	//Tier is grouping people of similar follower count to encourage competition between users.
	
	switch FollowerCount {
	case 100...199: return 1
	case 200...349: return 2
	case 350...499: return 3
	case 500...749: return 4
	case 750...999: return 5
	case 1000...1249: return 6
	case 1250...1499: return 7
	case 1500...1999: return 8
	case 2000...2999: return 9
	case 3000...3999: return 10
	case 4000...4999: return 11
	case 5000...7499: return 12
	case 7500...9999: return 13
	case 10000...14999: return 14
	case 15000...24999: return 15
	case 25000...49999: return 16
	case 50000...74999: return 17
	case 75000...99999: return 18
	case 100000...149999: return 19
	case 150000...199999: return 20
	case 200000...299999: return 21
	case 300000...499999: return 22
	case 500000...749999: return 23
	case 750000...999999: return 24
	case 1000000...1499999: return 25
	case 1500000...1999999: return 26
	case 2000000...2999999: return 27
	case 3000000...3999999: return 28
	case 4000000...4999999: return 29
	case 5000000...: return 30
	default: return nil
	}
}

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
		finalCategories.append(category + ", ")
	}

	if finalCategories != "" {
		finalCategories = String(finalCategories.dropLast(2))
	}
	
	return finalCategories
}



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
								
								postfinal.append(Post.init(image: post["image"] as? String, instructions: post["instructions"] as! String, captionMustInclude: post["captionMustInclude"] as? String, products: post["products"] as? [Product] , post_ID: post["post_ID"] as! String, PostType: TextToPostType(posttype: post["PostType"] as! String), confirmedSince: post["confirmedSince"] as? Date, isConfirmed: post["isConfirmed"] as! Bool))
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
//naveen added
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

//naveen added
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

func InitializeFormAPI(completed: (() -> Void)?) {
	let ref = Database.database().reference().child("Admin").child("FormAPIKey")
	ref.observeSingleEvent(of: .value) { (Snapshot) in
		if let apikey: String = Snapshot.value as? String {
			FormAPIKey = apikey
			if let comp = completed {
				comp()
			}
		}
	}
}

var FormAPIKey: String?

var zipCodeDic: [String: String] = [:]
func GetTownName(zipCode: String, completed: @escaping (_ cityState: String?, _ zipCode: String) -> () ) {
	//print("Getting town name from zipCode=\(zipCode)")
	
	//FORM API Key, subject to change.
	
	if (zipCodeDic[zipCode] ?? "") != "" {
		completed(zipCodeDic[zipCode]!, zipCode)
		return
	}
	
	if zipCode.count < 3 {
		return
	}
	
	if let APIKey: String = FormAPIKey {
		guard let url = URL(string: "https://form-api.com/api/geo/country/zip?key=\(APIKey)&country=US&zipcode=" + zipCode) else { completed(nil, zipCode)
			return }
		var cityState: String = ""
		URLSession.shared.dataTask(with: url){ (data, response, err) in
			if err == nil {
				// check if JSON data is downloaded yet
				guard let jsondata = data else { return }
				do {
					do {
						// Deserilize object from JSON
						if let zipCodeData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
							if let result = zipCodeData["result"] {
								let city = result["city"] as! String
								let state = result["state"] as! String
								let stateDict = ["Alabama": "AL","Alaska": "AK","Arizona": "AZ","Arkansas": "AR","California": "CA","Colorado": "CO","Connecticut": "CT","Delaware": "DE","Florida": "FL","Georgia": "GA","Hawaii": "HI","Idaho": "ID","Illinois": "IL","Indiana": "IN","Iowa": "IA","Kansas": "KS","Kentucky": "KY","Louisiana": "LA","Maine": "ME","Maryland": "MD","Massachusetts": "MA","Michigan": "MI","Minnesota": "MN","Mississippi": "MS","Missouri": "MO","Montana": "MT","Nebraska": "NE","Nevada": "NV","New Hampshire": "NH","New Jersey": "NJ","New Mexico": "NM","New York": "NY","North Carolina": "NC","North Dakota": "ND","Ohio": "OH","Oklahoma": "OK","Oregon": "OR","Pennsylvania": "PA","Rhode Island": "RI","South Carolina": "SC","South Dakota": "SD","Tennessee": "TN","Texas": "TX","Utah": "UT","Vermont": "VT","Virginia": "VA","Washington": "WA","West Virginia": "WV","Wisconsin": "WI","Wyoming": "WY"]
								cityState = city + ", " + (stateDict[state] ?? state)
							}
						}
						DispatchQueue.main.async {
							zipCodeDic[zipCode] = cityState
							completed(cityState, zipCode)
						}
					}
				} catch {
					print("JSON Downloading Error!")
				}
			}
		}.resume()
	} else {
		InitializeFormAPI {
			GetTownName(zipCode: zipCode, completed: completed)
		}
	}
}

func OpenAppStoreID(id: String) {
	if let url = URL(string: "itms-apps://itunes.apple.com/\(id)"),
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

func CategoriesToStrings(categories: [Category]) -> [String] {
	var newCats: [String] = []
	for x in categories {
		newCats.append(x.rawValue)
	}
	return newCats
}

func StringsToCategories(strings: [String]) -> [Category] {
	var newCats: [Category] = []
	for x in strings {
		if let cat: Category = Category(rawValue: x) {
			newCats.append(cat)
		}
	}
	return newCats
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

func GetTierForInfluencer(influencer: User) -> Int {
	if influencer.isDefaultOfferVerify {
		return (GetTierFromFollowerCount(FollowerCount: influencer.followerCount) ?? 0) + 1
	} else {
		return GetTierFromFollowerCount(FollowerCount: influencer.followerCount) ?? 0
	}
}
