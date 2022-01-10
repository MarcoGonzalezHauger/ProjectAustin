//
//  Savvy.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/22/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import Foundation
import UIKit
import Firebase
import CoreData

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

enum errorType: String {
    case noUserData, facebookError
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

func instantiateViewController(storyboard: String, reference: String) -> AnyObject{
    
    let mainStoryBoard = UIStoryboard(name: storyboard, bundle: nil)
    let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: reference)
    return redViewController
}

func setHapticMenu(user: Influencer) {
    
    let amt = NumberToPrice(Value: user.finance.balance, enforceCents: true)
    
    var shortcutItems = UIApplication.shared.shortcutItems ?? []
    if shortcutItems.count == 0{
		shortcutItems = [UIApplicationShortcutItem.init(type: "com.ambassadoor.business", localizedTitle: "Search Businesses", localizedSubtitle:nil, icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.search), userInfo: nil), UIApplicationShortcutItem.init(type: "com.ambassadoor.influencer", localizedTitle: "Search Influencers", localizedSubtitle:nil, icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.search), userInfo: nil),UIApplicationShortcutItem.init(type: "com.ambassadoor.profile", localizedTitle: "My Profile", localizedSubtitle: "Balance: \(amt)", icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.contact), userInfo: nil)]
        UIApplication.shared.shortcutItems = shortcutItems
    }else{
		shortcutItems = [UIApplicationShortcutItem.init(type: "com.ambassadoor.business", localizedTitle: "Search Businesses", localizedSubtitle:nil, icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.search), userInfo: nil), UIApplicationShortcutItem.init(type: "com.ambassadoor.influencer", localizedTitle: "Search Influencers", localizedSubtitle:nil, icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.search), userInfo: nil),UIApplicationShortcutItem.init(type: "com.ambassadoor.profile", localizedTitle: "My Profile", localizedSubtitle: "Balance: \(amt)", icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.contact), userInfo: nil)]
        shortcutItems[2] = UIApplicationShortcutItem.init(type: "com.ambassadoor.profile", localizedTitle: "My Profile", localizedSubtitle: "Balance: \(amt)", icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.contact), userInfo: nil)
         UIApplication.shared.shortcutItems = shortcutItems
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

func DateToLetterCountdownWithFormat(date: Date, format: String) -> String? {
    
    let calendar = Calendar.current
    let dateCom = calendar.dateComponents([.hour,.minute,.second], from: Date(), to: date)
	
	//MARCO
	//Added in order to make sure "3:1:1" is displayed as "3:01:01" instead.
	var minute: String = String(dateCom.minute!)
	var second: String = String(dateCom.second!)
	
	if dateCom.minute! < 10 {
		minute = "0" + minute
	}
	if dateCom.second! < 10 {
		second = "0" + second
	}
	
    switch dateCom {
    case _ where dateCom.hour! <= 0 && dateCom.minute! <= 0 && dateCom.second! <= 0:
        return "0:00"
    case _ where dateCom.hour! <= 0 && dateCom.minute! <= 0:
        return "0:\(second)"
    case _ where dateCom.hour! <= 0:
		return "\(dateCom.minute!):\(second)"
    default:
        return "\(dateCom.hour!):\(minute):\(second)"
    
    }
}

func DateToLetterCountdownWithFormat(date1: Date, date2: Date, format: String) -> String? {
    
    let calendar = Calendar.current
    let dateCom = calendar.dateComponents([.hour,.minute,.second], from: date1, to: date2)
    
	//MARCO
	//Added in order to make sure "3:1:1" is displayed as "3:01:01" instead.
	var minute: String = String(dateCom.minute!)
	var second: String = String(dateCom.second!)
	
	if dateCom.minute! < 10 {
		minute = "0" + minute
	}
	if dateCom.second! < 10 {
		second = "0" + second
	}
	
    switch dateCom {
    case _ where dateCom.hour! <= 0 && dateCom.minute! <= 0 && dateCom.second! <= 0:
        return "0:00"
    case _ where dateCom.hour! <= 0 && dateCom.minute! <= 0:
        return "0:\(second)"
    case _ where dateCom.hour! <= 0:
		return "\(dateCom.minute!):\(second)"
    default:
        return "\(dateCom.hour!):\(minute):\(second)"
    
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
		if FollowerCount >= TierThreshholds[index] {
			max = index
		} else {
			return max
		}
		index += 1
	}
	return TierThreshholds.count
}

// get organic subscription fee amount based on instagram followers count
func GetFeeForNewInfluencer(_ user: Influencer) -> Double {
    
    //The money faucet
    
    var fee = floor((user.basic.averageLikes) * 0.017 * 2) / 2
    if fee < 4 {
        fee = 4
    }
    return fee
    
//    switch FollowerCount {
//    case 0...749: return 4
//    case 750...1249: return 5
//    case 1250...2999: return 6
//    case 3000...4999: return 7
//    case 5000...9999: return 12
//    case 10000...: return ((FollowerCount) / 1000) * 12
//    default: return ((FollowerCount) / 1000) * 12
//    }
}

func makeImageCircular(image: UIImage) -> UIImage {
	let ImageLayer = CALayer()
	
	ImageLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
	ImageLayer.contents = image.cgImage
	ImageLayer.masksToBounds = true
	ImageLayer.cornerRadius = image.size.width/2
	ImageLayer.contentsScale = image.scale
	
	UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
	ImageLayer.render(in: UIGraphicsGetCurrentContext()!)
	let NewImage = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	
	return NewImage!
}



func GetCategoryStringFromlist(categories: [String]) -> String {
	
	return categories.joined(separator: "\n")
}

func showAlert(selfVC: UIViewController, caption: String, title: String = "Alert", okayButton: String = "OK") {
	let alert = UIAlertController(title: title, message: caption, preferredStyle: .alert)
	
	alert.addAction(UIAlertAction(title: okayButton, style: .default, handler: { (ui) in
		selfVC.dismiss(animated: true, completion: nil)
		
	}
	))
	
	selfVC.present(alert, animated: true)
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
	dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
    dateFormatterGet.timeZone = TimeZone(abbreviation: "EST")
		
	if let date = dateFormatterGet.date(from: date) {
		return date
	} else {
		
		//if the first format didn't work, it will try this one:
		dateFormatterGet.dateFormat = "yyyy/MMM/dd HH:mm:ss"
		if let date = dateFormatterGet.date(from: date) {
			return date
		} else {
			print("There was an error decoding the string")
			return Date()
		}
		
	}
	
}

//String To Date conversion
func getESTDateFromString(date: String) -> Date {
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.timeZone = TimeZone(abbreviation: "EST")
    dateFormatterGet.dateFormat = "yyyy/MMM/dd HH:mm:ssZ"
    //print("currentDate =",Date())
//    let dateFormatterPrint = DateFormatter()
//    dateFormatterPrint.timeZone = TimeZone(abbreviation: "IST")
//    dateFormatterPrint.dateFormat = "yyyy-MM-dd HH:mm:ss"
//    dateFormatterPrint.string(from: estDate)
    
    if let date = dateFormatterGet.date(from: date) {
        //print(dateFormatterPrint.string(from: date))
        return date
    } else {
		dateFormatterGet.dateFormat = "yyyy/MMM/dd HH:mm:ss"
		if let date = dateFormatterGet.date(from: date) {
			return date
		} else {
			print("There was an error decoding the string")
			print(date)
			return Date()
		}
    }
    
}
// after signout user change local values and logout to instagram
func signOutofAmbassadoor() {
    UserDefaults.standard.set(nil, forKey: "token")
    UserDefaults.standard.set(nil, forKey: "userid")
    UserDefaults.standard.set(nil, forKey: "userID")
    UserDefaults.standard.set(nil, forKey: "email")
    UserDefaults.standard.set(nil, forKey: "password")
    UIApplication.shared.applicationIconBadgeNumber = 0
    for timer in global.allTimers {
        if timer != nil {
            timer.invalidate()
        }
    }
    global.allTimers.removeAll()
    API.instaLogout()
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

/// Check If User Facebook access token expires or not.
/// - Parameters:
///   - accessToken: Send user current access token
///   - completion: Callback with true or false
/// - Returns: true if accesstoken is not expires otherwise false
func checkIfAccessTokenExpires(accessToken: String, completion: @escaping(_ status: Bool)->()){
    
    let urlString = "https://graph.facebook.com/app/?access_token=\(accessToken)"
    
    let url = URL(string: urlString)!
    
    let session = URLSession.shared
    var request = URLRequest(url: url)
    request.httpMethod = "Get"
    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
    
    let task = session.dataTask(with: request) { (data, response, error) in
        if error == nil && data != nil {
            
            do {

                let decoded = try JSONSerialization.jsonObject(with: data!, options: [])
                
                if let dictFromJSON = decoded as? [String: AnyObject] {
                    if (dictFromJSON ["error"] as? [String: AnyObject]) != nil{
                        completion(false)
                    }else{
                        completion(true)
                    }
                }else{
                    completion(true)
                }
            } catch {
                completion(true)
            }
        
        }else{
            completion(false)
        }
        
    }
    task.resume()
}


/// Calculate average likes by last three month posts count and total likes of the posts
/// - Parameters:
///   - instagramID: Send user current Instagram ID
///   - userToken: Send current Facebook accesstoken
func AverageLikes(instagramID: String, userToken: String) {
    
    API.calculateAverageLikes(userID: instagramID, longLiveToken: userToken) { (recentMedia, error) in
        
        if error == nil {
        
        if let recentMediaDict = recentMedia as? [String: AnyObject] {
            
            if let mediaData = recentMediaDict["data"] as? [[String: AnyObject]]{
                
                
                var numberOfPost = 0
                var numberOfLikes = 0
                var numberOfCall = 0
                
                for (index,mediaObject) in mediaData.enumerated() {
                    
                    if let mediaID = mediaObject["id"] as? String {
                        
                        GraphRequest(graphPath: mediaID, parameters: ["fields":"like_count,timestamp","access_token":userToken]).start { connection, recentMediaDetails, error in
                            numberOfCall += 1
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
                            
                            
                            if numberOfCall == mediaData.count{
                                
                                if numberOfPost != 0 {
                                
                                if Double(numberOfLikes/numberOfPost) != nil{
                                    //let avgLikes = round(Double(numberOfLikes/numberOfPost))
                                    let avgLikes = (Double(numberOfLikes)/Double(numberOfPost)).rounded(.up)
                                    print("rounddouble=",avgLikes)
                                    let userData: [String: Any] = ["averageLikes": avgLikes]
                                    //Yourself.averageLikes = avgLikes
                                    Myself.basic.averageLikes = Double(avgLikes)
                                    Myself.UpdateToFirebase(alsoUpdateToPublic: true) { error in
                                        
                                    }
//                                    let privatePath = "\(Myself.userId)/basic"
//                                    let publicPath = "\(Myself.userId)"
//                                    //newUpdateUserDetails(privatePath: privatePath, publicPath:publicPath,  userData: userData)
//                                    newUpdateAverageLikes(privatePath: privatePath, publicPath: publicPath, userData: userData)
                                    
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
    
//        GraphRequest(graphPath: NewAccount.id + "/media", parameters: [:]).start(completionHandler: { (connection, recentMedia, error) -> Void in
//        })
    
}

/// Upload instagram profile image to firebase store
/// - Parameters:
///   - profileUrl: Instagram profile image
///   - id: Instagram ID
///   - completion: Callback with firestore readable image url optional and status true or false
/// - Returns: empty 
func updateFirebaseProfileURL(profileUrl: String, id: String, completion: @escaping(_ url: String?,_ status: Bool)-> ()) {
        downloadImage(profileUrl) { (image) in
            if image != nil{
            uploadImageToFIR(image: image!, childName: "profile", path: id) { (url, errorStatus) in
                if !errorStatus{
                   completion(url,true)
                }else{
                   completion(nil,false)
                }
        }
            }else{
                completion(nil,false)
            }
        
    }
        
    
}

protocol refreshDelegate {
	func refreshOfferDate()
}

var refreshDelegates: [refreshDelegate] = []

func downloadDataBeforePageLoad(reference: TabBarVC? = nil){

    
//	getObserveFollowerCompaniesOffer() { (status, offers) in
//
//        if status {
//			global.followOfferList = offers
//        }
//
//    }
    
//    startListeningToMyself(userId: Myself.userId)

    
    
//    getObserveAllOffer() { (status, allOffer) in
//        if status{
//			global.allOfferList = allOffer
//        }
//
//    }
    
    
//    if reference != nil {
//        getAcceptedOffers { (status, offers) in
//
//            if status{
//				global.allInprogressOffer = offers
//				let badge = offers.filter{CheckIfOferIsActive(offer: $0)}.count
//				reference!.tabBar.items![3].badgeValue = badge == 0 ? nil : String(badge)
//				UIApplication.shared.applicationIconBadgeNumber = offers.filter{$0.variation == .inProgress}.count
//
//            }
//
////            if let searchView = reference?.viewControllers![0] as? SearchMenuVC{
////                searchView.viewDidLoad()
////            }
//
//        }
//    }

//    getFollowingList { (status, usersList) in
//
//        if status{
//            //self.userList = usersList
//            global.userList.removeAll()
//            global.userList = usersList
//        }
//
//    }
    
//    getFollowerList { (statusFollower, followerList) in
//
//
//
//        getFollowingAcceptedOffers { (status, offers) in
//            global.followerList.removeAll()
//            if statusFollower{
//
//                global.followerList.append(contentsOf: followerList)
//
//            }
//
//            if status{
//
//                global.followerList.append(contentsOf: offers)
//                let sorted = global.followerList.sorted { (objOne, objTwo) -> Bool in
//                return (objOne.startedAt.compare(objTwo.startedAt) == .orderedDescending)
//                }
//                global.followerList = sorted
//            }
//
//        }
//    }
    
//    getFollowedByList { (status, users) in
//
//        if status{
//            global.influencerList.removeAll()
//            global.influencerList = users
//            NotificationCenter.default.post(name: Notification.Name("updatefollowedBy"), object: nil, userInfo: ["userinfo":"1"])
//
//        }
//
//    }
}


func saveCoreDataUpdate(object: NSManagedObject) {
    
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    //print(paths[0])
    do {
        try object.managedObjectContext?.save()
    } catch {
        print("Failed saving")
    }
    
}

func removeCoreDataObject(object: NSManagedObject) {
    
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    
    //print(paths[0])
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    do {
        context.delete(object)
        try context.save()
    } catch {
        print("Failed saving")
    }
    
}


//returns a list of ERRORS

func isDeseralizable(dictionary: [String: AnyObject], type: structType) -> [String] {
	var necessaryItems: [String] = []
	var errors: [String] = []
	switch type {
	case .offer:
		necessaryItems = [] //["status", "money", "posts", "offer_ID", "offerdate", "ownerUserID", "title", "isAccepted", "expiredate", "cashPower"]
	case .businessDetails:
		necessaryItems = ["name", "mission"]
	}
	for i in necessaryItems {
		if dictionary[i] == nil {
			errors.append("Dictionary[\(i)] returned NIL")
		}
	}
	return errors
}

enum structType {
	case offer
	case businessDetails
}



