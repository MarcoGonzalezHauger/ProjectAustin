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
	
    // if open offer via notification get offer Detail using offer ID
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
	
    // if
	func OfferAccepted(offer: Offer) {
		isQue = true
		if let ip : IndexPath = currentviewoffer {
//            self.appdel.CreateOfferAcceptNotification(accepteddOffer: global.AvaliableOffers[ip.row])
			global.AvaliableOffers[ip.row].isAccepted = true
            global.AvaliableOffers[ip.row].status = "accepted"
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
    // Amount refunded to Business User account
	func OfferRejected(sender: Any) {
		if let ip : IndexPath = shelf.indexPath(for: sender as! UITableViewCell) {
			
			if global.AvaliableOffers[ip.row].offer_ID == "XXXDefault" {
				let alert = UIAlertController(title: "Verification Offer", message: "You can not reject this offer because it is the verification offer.", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.present(alert, animated: true)
				return
			}
			
            let prntRef  = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(global.AvaliableOffers[ip.row].offer_ID)
            prntRef.updateChildValues(["isAccepted":false])
            prntRef.updateChildValues(["status":"rejected"])
            
            global.AvaliableOffers[ip.row].isAccepted = false
            global.AvaliableOffers[ip.row].status = "rejected"
            
            if global.AvaliableOffers[ip.row].expiredate > Date().addMinutes(minute: 60) {
                let expireDate = Date.getStringFromDate(date: Date().addMinutes(minute: 60))!

                prntRef.updateChildValues(["expiredate":expireDate])
                global.AvaliableOffers[ip.row].expiredate = Date().addMinutes(minute: 60)
                
                global.RejectedOffers.append(global.AvaliableOffers[ip.row])
                global.AvaliableOffers.remove(at: ip.row)
                shelf.deleteRows(at: [ip], with: .left)
            }else{
                prntRef.updateChildValues(["isExpired":true])
                
                // amount refund Business User
                self.getDepositDetails(companyUserID: global.AvaliableOffers[ip.row].ownerUserID) { (deposit, status, error) in
                    
                    let depositedAmount = global.AvaliableOffers[ip.row].money
                    
                    let cardDetails = ["last4":"0000","expireMonth":"00","expireYear":"0000","country":"US"] as [String : Any]
                    
                    
                    let transactionDict = ["id":Yourself.id,"userName":Yourself.username,"status":"success","offerName":global.AvaliableOffers[ip.row].title,"type":"refund","currencyIsoCode":"USD","amount":String(depositedAmount),"createdAt":Date.getCurrentDate(),"updatedAt":Date.getCurrentDate(),"transactionType":"refund","cardDetails":cardDetails] as [String : Any]

                    
                        if status == "success" {
                        
                        let transactionObj = TransactionDetails.init(dictionary: transactionDict)
                        
                        let tranObj = serializeTransactionDetails(transaction: transactionObj)
                        
                        let currentBalance = deposit!.currentBalance! + depositedAmount
                        let totalDepositAmount = deposit!.totalDepositAmount!
                        deposit?.totalDepositAmount = totalDepositAmount
                        deposit?.currentBalance = currentBalance
                        deposit?.lastDepositedAmount = depositedAmount
                        deposit?.lastTransactionHistory = transactionObj
                        var depositHistory = [Any]()
                        
                        
                        depositHistory.append(contentsOf: (deposit!.depositHistory!))
                        depositHistory.append(tranObj)
                        
                        deposit?.depositHistory = depositHistory
                            
                        sendDepositAmount(deposit: deposit!, companyUserID: global.AvaliableOffers[ip.row].ownerUserID)
                        
                    }
                    else{
                                                
                    }
                    
                    global.RejectedOffers.append(global.AvaliableOffers[ip.row])
                    global.AvaliableOffers.remove(at: ip.row)
                    self.shelf.deleteRows(at: [ip], with: .left)
                    
                }
            }
            // **********
            
//			global.RejectedOffers.append(global.AvaliableOffers[ip.row])
//			global.AvaliableOffers.remove(at: ip.row)
//			shelf.deleteRows(at: [ip], with: .left)
		}
	}
    
    // get deposit detail from Business user
    func getDepositDetails(companyUserID: String,completion: @escaping(Deposit?,String,Error?) -> Void) {
        
        let ref = Database.database().reference().child("BusinessDeposit").child(companyUserID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let totalValues = snapshot.value as? NSDictionary{
                
                let deposit = Deposit.init(dictionary: totalValues as! [String : Any])
                completion(deposit, "success", nil)
            }else{
                completion(nil, "new", nil)
            }
        }) { (error) in
               completion(nil, "failure", error)
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
	
    // Offer Details view from list
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
//                if let picUrl  = newviewoffer.company.logo {
//                    UIImageView().downloadAndSetImage(picUrl, isCircle: false)
//                } else {
//
//                }
                
			}
		} else if segue.identifier == "toFakeSplash" {
			if let destination = segue.destination as? FakeSplash {
				self.delegate = destination
			}
		} else {
			print("Segue to sign up is being prepared.")
		}
	}
	
	//The Table view in which users are given offers
	@IBOutlet weak var shelf: UITableView!
	
    //MARK: Tableview data source and delegates
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = shelf.dequeueReusableCell(withIdentifier: "HomeOfferCell")  as! OfferCell
        cell.delegate = self
        cell.ThisOffer = global.AvaliableOffers[indexPath.row]
        return cell
    }
	
	@IBAction func goToInProgressOffers(_ sender: Any) {
		Pager.goToPage(index: 2, sender: self)
	}
	
	@IBAction func goToRejectedoffers(_ sender: Any) {
		Pager.goToPage(index: 0, sender: self)
	}
	
    
    var ref: DatabaseReference!
	
	var delegate: DismissNow?
	
	override func viewDidAppear(_ animated: Bool) {
		
		//TEMPORARY MEASURE TO ALLOW FOR FASTER DEBUGGING.
//		API.INSTAGRAM_ACCESS_TOKEN = "1605029612.fa083c3.815705ce93ab4ce89f21ee2aabdd7071"
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
        
        // First time open app we can fetch user details
        if  Yourself == nil {
			print("Yourself is nil.")
            if UserDefaults.standard.object(forKey: "token") != nil  {
				self.performSegue(withIdentifier: "toFakeSplash", sender: self)
				API.INSTAGRAM_ACCESS_TOKEN = UserDefaults.standard.object(forKey: "token") as! String
				let ref = Database.database().reference().child("users").child(UserDefaults.standard.object(forKey: "userid") as! String).child("id")
				print("USER ID: \(UserDefaults.standard.object(forKey: "userid") as! String)")
				ref.observeSingleEvent(of: .value) { (snapshot) in
					self.delegate?.dismissNow()
					if snapshot.exists() == false {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "showSignUpVC", sender: self)
                        }
					} else {
						self.GetUser {
							if let zip = Yourself.zipCode {
								
								//Download Zip Code Information To Cache.
								
								GetTownName(zipCode: zip) { _,_ in }
								GetAllZipCodesInRadius(zipCode: zip, radiusInMiles: socialPageMileRadius, completed: nil)
							}
						}
						
					}
				}
            } else {
                // not exist
                performSegue(withIdentifier: "showSignUpVC", sender: self)
            }
		}
	}
	
	
	func GetUser(hasCompleted: @escaping () -> ()) {
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
					hasCompleted()
				}
				
				var youroffers: [Offer] = []
				getOfferList { (Offers) in
                    
					youroffers = Offers
//                                global.AvaliableOffers = youroffers.filter({$0.isAccepted == false})
//                                global.AcceptedOffers = youroffers.filter({$0.isAccepted == true})
					global.AvaliableOffers = youroffers.filter({$0.status == "available"})
					global.AvaliableOffers = GetSortedOffers(offer: global.AvaliableOffers)
                    //Ambver update
					global.AcceptedOffers = youroffers.filter({$0.status == "accepted" || $0.status == "denied"})
                    global.OffersHistory = youroffers.filter({$0.status == "paid"})
					global.AcceptedOffers = GetSortedOffers(offer: global.AcceptedOffers)
					global.RejectedOffers = youroffers.filter({$0.status == "rejected"})
										
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
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showSignUpVC", sender: self)
                }
                
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
        
        // Creating account with call to function (uncomment to for new data to appear in Firebase)
        //let accountCreated: Bool = CreateAccount(instagramUser: "czar_chomicki")
        
        // Gets offers by on userId, will need to test data in firebase to test this, but pointer connection works
        //let offers = GetOffers(userId: "test")
		
        view.layoutIfNeeded()
		
    }
    

}
