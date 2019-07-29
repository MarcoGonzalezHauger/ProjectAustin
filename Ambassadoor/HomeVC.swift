//
//  HomeVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/20/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit
import Firebase

protocol PresentOfferDelegate {
	func SendOffer(OfferID: String)
}

class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate, OfferCellDelegate, GlobalListener, OfferResponse, PresentOfferDelegate {
	
	func SendOffer(OfferID: String) {
		if let presentThisOffer = OfferFromID(id: OfferID) {
			ViewOffer(OfferToView: presentThisOffer)
		}
	}
	
	func OfferAccepted(offer: Offer) {
		isQue = true
		if let ip : IndexPath = currentviewoffer {
			global.AvaliableOffers[ip.row].isAccepted = true
			global.AcceptedOffers.append(global.AvaliableOffers[ip.row])
			global.AvaliableOffers.remove(at: ip.row)
			shelf.deleteRows(at: [ip], with: .right)
		}
		isQue = false
	}
	
	var isQue: Bool = false
	
	func isQueued(isQue: Bool) {
		self.isQue = isQue
	}
	
	func AvaliableOffersChanged() {
		if isQue == false {
			shelf.reloadData()
		}
	}
	
	//Offer was rejected; Remove it from the list and add it to the rejected VCs List.
	func OfferRejected(sender: Any) {
		if let ip : IndexPath = shelf.indexPath(for: sender as! UITableViewCell) {
			global.RejectedOffers.append(global.AvaliableOffers[ip.row])
			global.AvaliableOffers.remove(at: ip.row)
			shelf.deleteRows(at: [ip], with: .left)
		}
	}

	var Pager: PageVC!
	var viewoffer: Offer?
	var currentviewoffer: IndexPath?
	var appdel: AppDelegate!
	
	//simply shows the offer.
	func ViewOfferFromCell(sender: Any) {
		if let sender = sender as? OfferCell {
			viewoffer = sender.ThisOffer
			ViewOffer(OfferToView: sender.ThisOffer)
			currentviewoffer = shelf.indexPath(for: sender)
			appdel.CreateNewOfferNotification(newOffer: sender.ThisOffer)
		}
	}
	
	func ViewOffer(OfferToView theoffer: Offer) {
		debugPrint("Viewing Offer: \(theoffer.money) from \(theoffer.company)")
		viewoffer = theoffer
		performSegue(withIdentifier: "viewOfferSegue", sender: self)
	}
	
	//makes sure the offer is showing in the segue.
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "viewOfferSegue" {
			guard let newviewoffer = viewoffer else { return }
			let destination = segue.destination
			if let destination = (destination as! UINavigationController).topViewController as? OfferVC {
				destination.delegate = self
				destination.ThisOffer = newviewoffer
			}
		} else {
			debugPrint("Segue to sign up is being prepared.")
		}
	}
	
	//The Table view in which users are given offers
	@IBOutlet weak var shelf: UITableView!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return global.AvaliableOffers.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return 120
		}
		return 110
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		debugPrint("cell selected at \(indexPath.row)")
		ViewOfferFromCell(sender: shelf.cellForRow(at: indexPath) as! OfferCell)
		shelf.deselectRow(at: indexPath, animated: false)
	}
	
	@IBAction func goToInProgressOffers(_ sender: Any) {
		Pager.goToPage(index: 2, sender: self)
	}
	
	@IBAction func goToRejectedoffers(_ sender: Any) {
		Pager.goToPage(index: 0, sender: self)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = shelf.dequeueReusableCell(withIdentifier: "HomeOfferCell")  as! OfferCell
		cell.delegate = self
		cell.ThisOffer = global.AvaliableOffers[indexPath.row]
		return cell
	}
    
    var ref: DatabaseReference!
	
	override func viewDidAppear(_ animated: Bool) {
		
		//TEMPORARY MEASURE TO ALLOW FOR FASTER DEBUGGING.
		API.INSTAGRAM_ACCESS_TOKEN = "1605029612.fa083c3.815705ce93ab4ce89f21ee2aabdd7071"
		API.getProfileInfo { (user: User?) in
			DispatchQueue.main.async {
				if user != nil {
					Yourself = user
				} else {
					debugPrint("Youself user was NIL.")
				}
			}
		}
//
//		if Yourself == nil {
//			debugPrint("Yourself is nil so showing signup VC.")
//			performSegue(withIdentifier: "showSignUpVC", sender: self)
//		}
//		debugPrint(Yourself)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		appdel = UIApplication.shared.delegate as? AppDelegate
		appdel.delegate = self
		appdel.pageDelegate = self.tabBarController
		debugPrint("Home VC started to load.")
		
		//First code to be executed when opening App
		
		//declare datasource & Delegates
		shelf.delegate = self
		shelf.dataSource = self
		global.delegates.append(self)
		
		//Debugging Fake Offers
		
		let fakeoffers: [Offer] = GetFakeOffers()
		global.AvaliableOffers = fakeoffers.filter({$0.isAccepted == false})
		global.AcceptedOffers = fakeoffers.filter({$0.isAccepted == true})
		
//		let fakeusers: [User] = GetRandomTestUsers()
//        global.SocialData = GetAllUsers
        //naveen added
        _ = GetAllUsers(completion: { (users) in
            global.SocialData = users
        })
        // Creating account with call to function (uncomment to for new data to appear in Firebase)
        //let accountCreated: Bool = CreateAccount(instagramUser: "czar_chomicki")
        
        // Gets offers by on userId, will need to test data in firebase to test this, but pointer connection works
        //let offers = GetOffers(userId: "test")
		
		
        //naveen added
//        for offer in global.AcceptedOffers {
//            appdel.CreateOfferAcceptNotification(expiringOffer: offer)
//        }
        
//        for offer in global.AvaliableOffers {
//            appdel.CreateExpireNotification(expiringOffer: offer)
//        }
        

        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            
            for notification in notifications {
                print(notification.identifier)
                let acceptresults = global.AcceptedOffers.filter({ $0.offer_ID == notification.identifier })
                let availableresults = global.AvaliableOffers.filter({ $0.offer_ID == notification.identifier })

                if  acceptresults.count > 0{
                    print("1 exists in the AcceptedOffersarray")
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                }
                
                if  availableresults.count > 0{
                    print("1 exists in the AvaliableOffersarray")
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.identifier])
                }

//                //accepted offer
//                for offer in global.AcceptedOffers {
//                    if notification.identifier == offer.offer_ID{
//                        print("AcceptedOffersduplicate")
//                    }else{
//                        self.appdel.CreateOfferAcceptNotification(expiringOffer: offer)
//
//                    }
//                }
//
//                //available offer
//                for offer in global.AvaliableOffers {
//                    if notification.identifier == offer.offer_ID{
//                        print("AvaliableOffersduplicate")
//                    }else{
//                        self.appdel.CreateExpireNotification(expiringOffer: offer)
//                    }
//                }
            }
                for offer in global.AcceptedOffers {
                    self.appdel.CreateOfferAcceptNotification(accepteddOffer: offer)
                }
        
                for offer in global.AvaliableOffers {
                    self.appdel.CreateExpireNotification(expiringOffer: offer)
                }
            
        }
        debugPrint("Home VC has been loaded.")
    }
}
