//
//  AppDelegate.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/18/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit
import CoreData
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

	func AskForNotificationPermission() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert]) { (worked, error) in
		}
	}
	
	func sendOffer(id: String) {
		pageDelegate?.selectedIndex = 2
		delegate?.SendOffer(OfferID: id)
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		let identifier = response.notification.request.identifier
		debugPrint("actionID: \(identifier)")
		if identifier.hasPrefix("new") {
			let offer_ID: String = String(identifier.dropFirst(3))
			sendOffer(id: offer_ID)
		} else if identifier.hasPrefix("Accept") {
//			let offer_ID: String = String(identifier.dropFirst(6))
			sendOffer(id: identifier)
		}
        //naveeen added
        else if identifier.hasPrefix("Available"){
//            let offer_ID: String = String(identifier.dropFirst(6))
            sendOffer(id: identifier)
        }
        
		completionHandler()
	}
    
    //naveen added func
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let id = notification.request.identifier
        print("Received notification with ID = \(id)")
        
        completionHandler([.sound, .alert])
    }

	
	var delegate: PresentOfferDelegate?
	var pageDelegate: UITabBarController?
	
	func CreateExpireNotification(expiringOffer: Offer) {
//		let content = UNMutableNotificationContent()
//		content.title = "Offer Will Expire in 1h"
//		content.body = "An offer by \(expiringOffer.company.name) for \(NumberToPrice(Value: expiringOffer.money)) is about to expire."
//		downloadImage(expiringOffer.company.logo ?? "") { (logo) in
//			if let logo = logo {
//				if let attachment = UNNotificationAttachment.make(identifier: "logo", image: logo, options: nil) {
//					content.attachments = [attachment]
//				}
//			}
//
//			let request = UNNotificationRequest.init(identifier: "expire\(expiringOffer.offer_ID)", content: content, trigger: UNTimeIntervalNotificationTrigger.init(timeInterval: 10, repeats: false))
//			UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//        }
        
        //naveen added
        let dateComponents = DateComponents(year: Calendar.current.component(.year, from: expiringOffer.expiredate), month: Calendar.current.component(.month, from: expiringOffer.expiredate), day: Calendar.current.component(.day, from: expiringOffer.expiredate))
        let yourFireDate = Calendar.current.date(from: dateComponents)
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey:
            "Offer Will Expire in 1h", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "An offer by \(expiringOffer.company.name) for \(NumberToPrice(Value: expiringOffer.money)) is about to expire.", arguments: nil)
        content.categoryIdentifier = "\(expiringOffer.offer_ID)"
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        downloadImage(expiringOffer.company.logo ?? "") { (logo) in
            if let logo = logo {
                if let attachment = UNNotificationAttachment.make(identifier: "logo", image: logo, options: nil) {
                    content.attachments = [attachment]
                }
            }
            
            let dateComponents2 = Calendar.current.dateComponents(Set(arrayLiteral: Calendar.Component.year, Calendar.Component.month, Calendar.Component.day), from: yourFireDate!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents2, repeats: false)
            let request = UNNotificationRequest(identifier: "\(expiringOffer.offer_ID)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                if error != nil {
                    //handle error
                } else {
                    //notification set up successfully
                }
                
            })
        }

        
		}
    
	
    //naveen added func
    func CreateOfferAcceptNotification(accepteddOffer: Offer) {
        let content = UNMutableNotificationContent()
        content.title = "Offer Accepted"
        content.body = "An offer by \(accepteddOffer.company.name) for \(NumberToPrice(Value: accepteddOffer.money)) is Accepted."
        downloadImage(accepteddOffer.company.logo ?? "") { (logo) in
            if let logo = logo {
                if let attachment = UNNotificationAttachment.make(identifier: "logo", image: logo, options: nil) {
                    content.attachments = [attachment]
                }
            }
            let request = UNNotificationRequest.init(identifier: "\(accepteddOffer.offer_ID)", content: content, trigger: UNTimeIntervalNotificationTrigger.init(timeInterval: 15, repeats: false))
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        
    }
    
	func CreateNewOfferNotification(newOffer: Offer) {
		let content = UNMutableNotificationContent()
		content.title = "New Offer"
		content.body = "\(newOffer.company.name) will pay you \(NumberToPrice(Value: newOffer.money)) for \(newOffer.posts.count) posts."
		downloadImage(newOffer.company.logo ?? "") { (logo) in
			if let logo = logo {
				if let attachment = UNNotificationAttachment.make(identifier: "logo", image: logo, options: nil) {
					content.attachments = [attachment]
				}
			}
			
			//Time inverval is for debug only.
			
			let request = UNNotificationRequest.init(identifier: "new\(newOffer.offer_ID)", content: content, trigger: UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false))
			UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
		}
	}
	
	var window: UIWindow?
    
    override init() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
    }

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		AskForNotificationPermission()
		
		// Define the custom actions.
		
		UNUserNotificationCenter.current().delegate = self
		
		return true
	}

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
		globalTimer.timer.fire()
	}

	func applicationWillTerminate(_ application: UIApplication) {
		
		self.saveContext()
	}

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

