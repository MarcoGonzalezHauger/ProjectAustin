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
//		if let presentThisOffer = OfferFromID(id: OfferID) {
//			ViewOffer(OfferToView: presentThisOffer)
//        }else{
//
//        }
        
        //naveen added
        OfferFromID(id: OfferID, completion: {(offer)in
            self.ViewOffer(OfferToView: offer!)
        })
	}
	
	func OfferAccepted(offer: Offer) {
		isQue = true
		if let ip : IndexPath = currentviewoffer {
//            self.appdel.CreateOfferAcceptNotification(accepteddOffer: global.AvaliableOffers[ip.row])
			global.AvaliableOffers[ip.row].isAccepted = true
            global.AvaliableOffers[ip.row].status = "accepted"
			global.AcceptedOffers.append(global.AvaliableOffers[ip.row])
			global.AvaliableOffers.remove(at: ip.row)
			shelf.deleteRows(at: [ip], with: .right)
            
            //accept offer notifications
            //naveen added
//            UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
//
//                for notification in notifications {
//                    print(notification.identifier)
//                    if global.AvaliableOffers[ip.row].offer_ID == notification.identifier {
//                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.identifier])
//
//                        self.appdel.CreateOfferAcceptNotification(accepteddOffer: global.AvaliableOffers[ip.row])
//
//                    }
//
//                }
//
//            }

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
			
			if global.AvaliableOffers[ip.row].offer_ID == "XXXDefault" {
				let alert = UIAlertController(title: "Verification Offer", message: "You can not reject this offer because it is the verification offer.", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.present(alert, animated: true)
				return
			}
			
            //naveen added
            let prntRef  = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(global.AvaliableOffers[ip.row].offer_ID)
            prntRef.updateChildValues(["isAccepted":false])
            prntRef.updateChildValues(["status":"rejected"])
            
            global.AvaliableOffers[ip.row].isAccepted = false
            global.AvaliableOffers[ip.row].status = "rejected"
            
            if global.AvaliableOffers[ip.row].expiredate > Date().addMinutes(minute: 60) {
                let expireDate = Date.getStringFromDate(date: Date().addMinutes(minute: 60))!

                prntRef.updateChildValues(["expiredate":expireDate])
                global.AvaliableOffers[ip.row].expiredate = Date().addMinutes(minute: 60)
            }else{
                prntRef.updateChildValues(["isExpired":true])

            }
            
            // **********
            
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
            //naveen commented
//			appdel.CreateNewOfferNotification(newOffer: sender.ThisOffer)
		}
	}
	
	func ViewOffer(OfferToView theoffer: Offer) {
//		print("Viewing Offer: \(theoffer.money) from \(theoffer.company)")
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
			print("Segue to sign up is being prepared.")
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
		print("cell selected at \(indexPath.row)")
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
//		API.INSTAGRAM_ACCESS_TOKEN = "1605029612.fa083c3.815705ce93ab4ce89f21ee2aabdd7071"
////        //naveen login
//        API.INSTAGRAM_ACCESS_TOKEN = "3225555942.a92e22c.e7bf50100dfc4b12b93138cde8463ede"
//
//		API.getProfileInfo { (user: User?) in
//			DispatchQueue.main.async {
//				if user != nil {
//					Yourself = user
//				} else {
//					print("Youself user was NIL.")
//				}
//			}
//		}

        
//        print(API.INSTAGRAM_ACCESS_TOKEN)
//		if Yourself == nil {
//			print("Yourself is nil so showing signup VC.")
//			performSegue(withIdentifier: "showSignUpVC", sender: self)
//        }else{
//            //naveen added
//            var fakeoffers: [Offer] = []
//            getOfferList { (Offers) in
//                print(Offers.count)
//                fakeoffers = Offers
//                global.AvaliableOffers = fakeoffers.filter({$0.isAccepted == false})
//                global.AcceptedOffers = fakeoffers.filter({$0.isAccepted == true})
//            }
//        }
//		print(Yourself)
        
        
        if  Yourself == nil {
			print("Yourself is nil.")
            if UserDefaults.standard.object(forKey: "token") != nil  {
				API.INSTAGRAM_ACCESS_TOKEN = UserDefaults.standard.object(forKey: "token") as! String
				let ref = Database.database().reference().child("users").child(UserDefaults.standard.object(forKey: "userid") as! String).child("id")
				print("USER ID: \(UserDefaults.standard.object(forKey: "userid") as! String)")
				ref.observeSingleEvent(of: .value) { (snapshot) in
					if snapshot.exists() == false {
						self.performSegue(withIdentifier: "showSignUpVC", sender: self)
					} else {
						self.GetUser()
					}
				}
            } else {
                // not exist
                performSegue(withIdentifier: "showSignUpVC", sender: self)
            }
        }
        
        
	}
	
	func GetUser() {
		print("Getting user information.")
		API.getProfileInfo { (user: User?) in
			//                    DispatchQueue.main.async {
			if user != nil {
				Yourself = user
				CreateAccount(instagramUser: user!) { (userVal, alreadyRegistered) in
					Yourself = userVal
					if alreadyRegistered {
						UserDefaults.standard.set(API.INSTAGRAM_ACCESS_TOKEN, forKey: "token")
						UserDefaults.standard.set(Yourself.id, forKey: "userid")
					}
					
				}
				
				//naveen added
				var youroffers: [Offer] = []
				getOfferList { (Offers) in
					//                            print(Offers.count)
					youroffers = Offers
					//                                global.AvaliableOffers = youroffers.filter({$0.isAccepted == false})
					//                                global.AcceptedOffers = youroffers.filter({$0.isAccepted == true})
					global.AvaliableOffers = youroffers.filter({$0.status == "available"})
					global.AvaliableOffers = GetSortedOffers(offer: global.AvaliableOffers)
					global.AcceptedOffers = youroffers.filter({$0.status == "accepted"})
					global.AcceptedOffers = GetSortedOffers(offer: global.AcceptedOffers)
					global.RejectedOffers = youroffers.filter({$0.status == "rejected"})
					
					
					//post verify check
					
					//get instagram user media data
					API.getRecentMedia { (mediaData: [[String:Any]]?) in
						for postVal in mediaData!{
							if let captionVal = (postVal["caption"] as? [String:Any]) {
								var instacaption = captionVal["text"] as! String
								if instacaption.contains("#ad"){
									instacaption = instacaption.replacingOccurrences(of: " #ad ", with: "")
									instacaption = instacaption.replacingOccurrences(of: "#ad ", with: "")
									instacaption = instacaption.replacingOccurrences(of: " #ad", with: "")
									instacaption = instacaption.replacingOccurrences(of: "#ad", with: "")
									
									for offer in global.AcceptedOffers {
										if !offer.allConfirmed {
											for post in offer.posts {
												let postCaption = post.captionMustInclude!
												if instacaption.contains(postCaption) {
													instagramPostUpdate(offerID: offer.offer_ID, post: [post.post_ID:postVal])
													SentOutOffersUpdate(offer: offer, post_ID: post.post_ID)
												}
											}
										}
										
									}
									
								}
								
								
							}else{
								
							}
							
						}
						
					}
					
					
					UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
						var newavailableresults: [Offer] = []
						for notification in notifications {
							print(notification.identifier)
							var identifier = notification.identifier
							
							if identifier.hasPrefix("new") {
								identifier = String(identifier.dropFirst(3))
							} else if identifier.hasPrefix("accept") {
								identifier = String(identifier.dropFirst(6))
							}
								//naveeen added
							else if identifier.hasPrefix("expire"){
								identifier = String(identifier.dropFirst(6))
							}else{
							}
							newavailableresults = global.AvaliableOffers.filter({ $0.offer_ID != identifier })
							
							
						}
						
						for offer in newavailableresults {
							self.appdel.CreateExpireNotification(expiringOffer: offer)
							self.appdel.CreateNewOfferNotification(newOffer: offer)
						}
						
					}
					
					
				}
				CheckForCompletedOffers() {
					
				}
			} else {
				print("Youself user was NIL.")
				attemptedLogOut = true
				self.performSegue(withIdentifier: "showSignUpVC", sender: self)
				self.showStandardAlertDialog(title: "Alert", msg: "You have exceeded the maximum number of requests per hour. You have performed a total of 270 requests in the last hour. Our general maximum limit is set at 200 requests per hour.")
			}
			//                    }
		}
	}
		
    override func viewDidLoad() {
        super.viewDidLoad()
        
		appdel = UIApplication.shared.delegate as? AppDelegate
		appdel.delegate = self
		appdel.pageDelegate = self.tabBarController
		print("Home VC started to load.")
		
		//First code to be executed when opening App
		
		//declare datasource & Delegates
		shelf.delegate = self
		shelf.dataSource = self
		global.delegates.append(self)
		
		self.tabBarController?.selectedIndex = 3
		self.tabBarController?.selectedIndex = 2
		
		//Debugging Fake Offers
//		let fakeoffers: [Offer] = GetFakeOffers()
//        global.AvaliableOffers = fakeoffers.filter({$0.isAccepted == false})
//        global.AcceptedOffers = fakeoffers.filter({$0.isAccepted == true})
        
        //naveen added
//        var fakeoffers: [Offer] = []
//        getOfferList { (Offers) in
//            print(Offers.count)
//            fakeoffers = Offers
//            global.AvaliableOffers = fakeoffers.filter({$0.isAccepted == false})
//            global.AcceptedOffers = fakeoffers.filter({$0.isAccepted == true})
//        }

		
//		let fakeusers: [User] = GetRandomTestUsers()
//        global.SocialData = GetAllUsers
        //naveen added
//        _ = GetAllUsers(completion: { (users) in
//            global.SocialData = users
//        })
        
        
        // Creating account with call to function (uncomment to for new data to appear in Firebase)
        //let accountCreated: Bool = CreateAccount(instagramUser: "czar_chomicki")
        
        // Gets offers by on userId, will need to test data in firebase to test this, but pointer connection works
        //let offers = GetOffers(userId: "test")
		
        view.layoutIfNeeded()
		
        print("Home VC has been loaded.")
    }
    

}
