//
//  AppDelegate.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/18/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import UIKit
import CoreData
import Firebase
import UserNotifications
import FirebaseInstanceID
import FirebaseCore
import FirebaseMessaging
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    enum ShortcutIdentifier: String {
        case Business = "com.ambassadoor.business"
        case Influencer = "com.ambassadoor.influencer"
        case Profile = "com.ambassadoor.profile"
    }
    
    var timer: DispatchSourceTimer?

	func AskForNotificationPermission() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert]) { (worked, error) in
		}
	}
	
	func sendOffer(id: String) {
//		pageDelegate?.selectedIndex = 2
//		delegate?.SendOffer(OfferID: id)
	}
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void){
        print(shortcutItem.type)

//        if let userID = UserDefaults.standard.value(forKey: "userID") as? String{
//            fetchSingleUserDetails(userID: userID) { (status, user) in
//                Yourself = user
//               let viewReference = instantiateViewController(storyboard: "Main", reference: "TabBarReference") as! TabBarVC
//                self.handleHapticActions(shortcutItem, user: Yourself, tabController: viewReference)
//                self.window?.rootViewController = viewReference
//            }
//        }

    }
	
    // received user notification here
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		let identifier = response.notification.request.identifier
		//print("actionID: \(identifier)")
		if identifier.hasPrefix("new") {
			let offer_ID: String = String(identifier.dropFirst(3))
			sendOffer(id: offer_ID)
		} else if identifier.hasPrefix("accept") {
			let offer_ID: String = String(identifier.dropFirst(6))
			sendOffer(id: offer_ID)
		}
        //naveeen added
        else if identifier.hasPrefix("expire"){
            let offer_ID: String = String(identifier.dropFirst(6))
            sendOffer(id: offer_ID)
        }else{
            sendOffer(id: identifier)
        }

		completionHandler()
        
        
	}
    
    // user notification present here
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let id = notification.request.identifier
        print("Received notification with ID = \(id)")
        
        completionHandler([.sound, .alert])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        
        let deviceTokenString1 = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("deviceToken1=",deviceTokenString1)
        
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                global.deviceFIRToken = result.token
                //print("avvv=",InstanceID.instanceID().token()!)
            }
        }
        
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error){
        
    }

	
	//var delegate: PresentOfferDelegate?
	var pageDelegate: UITabBarController?
	
	
	var window: UIWindow?
    
    override init() {
        
    }
    
    private func handleHapticActions(_ shortcutItem: UIApplicationShortcutItem, user: User, tabController: TabBarVC) {
        
        let shortcutType = shortcutItem.type
        
        let checkIfIdentifier = ShortcutIdentifier.init(rawValue: shortcutType)
        
        switch checkIfIdentifier {
        case .Business:
            global.identifySegment = "shortcut_business"
            tabController.selectedIndex = 0
        case .Influencer:
            global.identifySegment = "shortcut"
            tabController.selectedIndex = 0
        case .Profile:
            tabController.selectedIndex = 1
        default:
            tabController.selectedIndex = 2
        }
        
    }
    

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = false
        
        global.cachedImageList.removeAll()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AppImageData")
        request.returnsObjectsAsFaults = false
		
        let context = self.persistentContainer.viewContext
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let cachedData = CachedImages.init(object: data)
                if cachedData.imagedata != nil {
                    let afterSevenDays = cachedData.date!.afterDays(numberOfDays: 7)
                    if Date.getcurrentESTdate().timeIntervalSince1970 > afterSevenDays.timeIntervalSince1970{
                        removeCoreDataObject(object:cachedData.object!)
                    }else{
                        global.cachedImageList.append(cachedData)
                    }
                }else{
                    if cachedData.object != nil {
                        removeCoreDataObject(object:cachedData.object!)
                    }
                    
                }
                
			}
			print("coredatecount=",global.cachedImageList.count)
		}catch {
			
			print("Failed")
		}
		
		ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
		
		UNUserNotificationCenter.current().delegate = self
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            guard granted else {return}
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
                NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification(_:)), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
            }
        }
		
//        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
//
//            if let userID = UserDefaults.standard.value(forKey: "userID") as? String{
//                fetchSingleUserDetails(userID: userID) { (status, user) in
//                    Yourself = user
//                   let viewReference = instantiateViewController(storyboard: "Main", reference: "TabBarReference") as! TabBarVC
//                    self.handleHapticActions(shortcutItem, user: Yourself, tabController: viewReference)
//                    self.window?.rootViewController = viewReference
//
//                }
//            }
//
//            return true
//        }
        
        self.signInAction()
        
        GetDevelopmentSettings { (development) in
            if development != nil{
            //global.InstagramAPI = APImode(rawValue: development!)!
            }
        }
		
		preDownloadInterests()
        
		return true
	}
    
    
	func signInAction() {
//		ConvertEntireDatabase(iUnderstandWhatThisFunctionDoes: true)
//		return
		
		let eMail: String! = UserDefaults.standard.object(forKey: "email") as? String
		let passWord: String! = UserDefaults.standard.object(forKey: "password") as? String
		
        if eMail == nil || passWord == nil || AccessToken.current == nil || !NetworkReachability.isConnectedToNetwork() {
			let viewReference = instantiateViewController(storyboard: "LoginSetup", reference: "SignUp") as! WelcomeVC
            self.window?.rootViewController = viewReference
//            let mainStoryBoard = UIStoryboard(name: "Welcome", bundle: nil)
//            let redViewController = mainStoryBoard.instantiateInitialViewController()
//			  self.window?.rootViewController = redViewController
			return
		}
		
		let ref = Database.database().reference().child("Accounts/Private/Influencers")
		let query = ref.queryOrdered(byChild: "email").queryEqual(toValue: eMail)
		query.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapValue = snapshot.value as? [String: Any]{
                let thisInf = Influencer.init(dictionary: snapValue.values.first as! [String : Any], userId: snapValue.keys.first!)
			
			if thisInf.password == passWord?.md5() {
				
				Myself = thisInf
				
				if AccessToken.current != nil {
					
					setHapticMenu(user: Myself)
					InitializeAmbassadoor()
					AverageLikes(instagramID: Myself.instagramAccountId, userToken: Myself.instagramAuthToken)
					let viewReference = instantiateViewController(storyboard: "Main", reference: "TabBarReference") as! TabBarVC
                    viewReference.delegate = viewReference
					downloadDataBeforePageLoad()
					self.window?.rootViewController = viewReference
					
				} else {
					
					self.callIfAccessTokenExpired(userID: Myself.userId, instaID: Myself.instagramAccountId)
					
				}
			} else {
				let viewReference = instantiateViewController(storyboard: "LoginSetup", reference: "SignUp") as! WelcomeVC
				self.window?.rootViewController = viewReference
			}
            
        }else{
            let viewReference = instantiateViewController(storyboard: "LoginSetup", reference: "SignUp") as! WelcomeVC
            self.window?.rootViewController = viewReference
        }
			
		})

    }
    
    func callIfAccessTokenExpired(userID: String, instaID: String) {
        
        API.facebookLoginAct(userIDBusiness: instaID, owner: self.window!.rootViewController!) { (userDetail, longliveToken, error) in
            if error == nil {
                
                if let userDetailDict = userDetail as? [String: AnyObject]{
                    
                    if let id = userDetailDict["id"] as? String {
                        Myself.instagramAccountId = id
                    }
                    if let followerCount = userDetailDict["followers_count"] as? Int {
                        Myself.basic.followerCount = Double(followerCount)
                    }
                    if let name = userDetailDict["name"] as? String {
                        Myself.basic.name = name
                    }
                    if let pic = userDetailDict["profile_picture_url"] as? String {
                        Myself.basic.profilePicURL = pic
                    }
                    if let username = userDetailDict["username"] as? String {
                        Myself.basic.username = username
                    }
                    
                    Myself.instagramAuthToken = longliveToken!
                    //updateFirebaseProfileURL(profileUrl: NewAccount.profilePicture, id: NewAccount.id) {
                    updateFirebaseProfileURL(profileUrl: Myself.basic.profilePicURL, id: Myself.basic.username) { (url, status) in
                        
                        if status{
                            Myself.basic.profilePicURL = url!
                        }
                        self.updateLoginDetailsToServer(userID: userID, user: Myself)
                    }
                    
                    
                    
                }else{
                    
                }
                
            }else{
                
               
            }
        }
        
    }
    
    func updateLoginDetailsToServer(userID: String, user: Influencer) {
        
        Myself.tokenFIR = global.deviceFIRToken
        
        Myself.UpdateToFirebase(alsoUpdateToPublic: true) { (error) in
            
            if error{
                let viewReference = instantiateViewController(storyboard: "LoginSetup", reference: "SignUp") as! WelcomeVC
                self.window?.rootViewController = viewReference
                return
            }
            setHapticMenu(user: Myself)
            InitializeAmbassadoor()
            AverageLikes(instagramID: NewAccount.id, userToken: NewAccount.authenticationToken)
            downloadDataBeforePageLoad()
            let viewReference = instantiateViewController(storyboard: "Main", reference: "TabBarReference") as! TabBarVC
            //downloadDataBeforePageLoad(reference: viewReference)
            self.window?.rootViewController = viewReference
            
        }
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool{
        if (ApplicationDelegate.shared.application(app, open: url, options: options)){
            return true
        }
        else {
            return true
        }
        
    }
    @objc func tokenRefreshNotification(_ notification: Notification) {
            
    
            InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                    print("Error fetching remote instange ID: \(error)")
                } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
                    global.deviceFIRToken = result.token
                }
            }
        }
    //checking internet connection and latest app version. if not updated version go to the app store page
    func versionUpdateValidation(){
        if !NetworkReachability.isConnectedToNetwork() || !canReachGoogle() {
//            let alertMessage = "Make sure your device is connected to the internet.";
//
//            let topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
//            topWindow?.rootViewController = UIViewController()
//            topWindow?.windowLevel = UIWindow.Level.alert + 1
//            let alert = UIAlertController(title: "No Internet Connection!", message: alertMessage, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "confirm"), style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
//
//                //if not connect to internet automatically open to direct network connection page Note:this func not allowed for apple
////                if let url = URL.init(string: "App-Prefs:root=WIFI") {
////                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
////                }
//
//                // important to hide the window after work completed.
//                // this also keeps a reference to the window until the action is invoked.
//                topWindow?.isHidden = true // if you want to hide the topwindow then use this
//                // topWindow = nil // if you want to hide the topwindow then use this
//
//                //if not connected to internet automatically open settings page
//                if let url = URL.init(string: UIApplication.openSettingsURLString) {
//                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                }
//
//            }))
//            topWindow?.makeKeyAndVisible()
//            topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }else{
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            
            let ref = Database.database().reference().child("LatestAppVersion").child("Influencerversion")
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let latestVersion = snapshot.value as! String
                global.appVersion = latestVersion
                let versionCompare = appVersion!.compare(latestVersion, options: .numeric)
                if versionCompare == .orderedDescending || versionCompare == .orderedSame {
					FreePass = true
                    print("This version is ABOVE.")
                }else{
                    let alertMessage = "A new version of Application is available, Please update to version " + latestVersion;

                    let topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
                    topWindow?.rootViewController = UIViewController()
                    topWindow?.windowLevel = UIWindow.Level.alert + 1
                    let alert = UIAlertController(title: "Update is avaliable", message: alertMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "confirm"), style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
                        // continue your work
                        
                        // important to hide the window after work completed.
                        // this also keeps a reference to the window until the action is invoked.
                        topWindow?.isHidden = true // if you want to hide the topwindow then use this
                        //            topWindow? = nil // if you want to hide the topwindow then use this
                        
                        OpenAppStoreID(id: "ambassadoor/id1483075744")
                        
                        
                    }))
                    topWindow?.makeKeyAndVisible()
                    topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            })
        }
        
    }
    
    // checking internet reach connection
    func canReachGoogle() -> Bool
    {
        let url = URL(string: "https://8.8.8.8")
        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        let task = urlSession.dataTask(with: url!)
        { data, response, error in
            if error != nil
            {
                success = false
            }
            else
            {
                success = true
            }
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        return success
    }
    
    private var urlSession:URLSession = {
        var newConfiguration:URLSessionConfiguration = .default
        newConfiguration.waitsForConnectivity = false
        newConfiguration.allowsCellularAccess = true
        return URLSession(configuration: newConfiguration)
    }()
    
    // Update User details, OfferList and completed offer verification for every 4 secs
    
    // after close the app stop the timer
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    // get user details From FIR
    
    
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
		globalTimer.timer.fire()
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.versionUpdateValidation()

		globalTimer.timer.fire()
        
	}

	func applicationWillTerminate(_ application: UIApplication) {
		self.stopTimer()
		self.saveContext()
	}
    
    //MARK: Current Location
    


	// MARK: - Core Data stack

	lazy var persistentContainer: NSPersistentContainer = {
	    /*
	     The persistent container for the application. This implementation
	     creates and returns a container, having loaded the store for the
	     application to it. This property is optional since there are legitimate
	     error conditions that could cause the creation of the store to fail.
	    */
	    let container = NSPersistentContainer(name: "Ambassadoor")
	    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
	        if let error = error as NSError? {
	            // Replace this implementation with code to handle the error appropriately.
	            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	             
	            /*
	             Typical reasons for an error here include:
	             * The parent directory does not exist, cannot be created, or disallows writing.
	             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
	             * The device is out of space.
	             * The store could not be migrated to the current model version.
	             Check the error message to determine what the actual problem was.
	             */
	            fatalError("Unresolved error \(error), \(error.userInfo)")
	        }
	    })
	    return container
	}()

	// MARK: - Core Data Saving support
	func saveContext () {
	    let context = persistentContainer.viewContext
	    if context.hasChanges {
	        do {
	            try context.save()
	        } catch {
	            // Replace this implementation with code to handle the error appropriately.
	            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	            let nserror = error as NSError
	            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
	        }
	    }
	}

}

