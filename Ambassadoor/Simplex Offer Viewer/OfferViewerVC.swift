//
//  OfferViewerVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 16/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//	All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import UIKit
import Firebase

enum postRowHeight: CGFloat {
	case one = 100, two = 150, three = 200
	
	static func returnRowHeight(count: Int) -> postRowHeight{
		
		switch count {
		case 1:
			return .one
		case 2:
			return .two
		default:
			return .three
		}
		
	}
	
}

protocol postDidSelect {
    func sendPostObjects(index: Int, offervariation: OfferVariation, offer: Offer)
}
protocol reservedTimeEndDelegate {
    func DismissWhenReservedTimeEnd()
}


enum OfferVariation {
	case canBeAccepted, canNotBeAccepted, inProgress, didNotPostInTime, willBePaid, hasBeenPaid, allPostsDenied
}

enum NumberOfRows: Int {
	case canBeAcceptedRows = 5,canNotBeAcceptedRows = 3, inProgressRows = 4, allPostDenied = 2, defaultRows = 1
	
	static func returnHeight(count: OfferVariation) -> NumberOfRows{
		switch count {
		case .canBeAccepted:
			return .canBeAcceptedRows
		case .canNotBeAccepted:
			return .canNotBeAcceptedRows
		case .inProgress:
			return .canBeAcceptedRows
		case .willBePaid:
			return .inProgressRows
		case .hasBeenPaid:
			return .inProgressRows
		case .allPostsDenied:
			return .allPostDenied
		default:
			return .defaultRows
		}
	}
}

protocol AcceptButtonDelegate{
	func AcceptWasPressed()
}

protocol inProgressDelegate {
	func reloadNow()
}

class OfferViewerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, postDidSelect, reservedTimeEndDelegate, AcceptButtonDelegate, didAcceptDeleagte, CancelOffer {
	
	var delegate: inProgressDelegate?
	var thisParent: UIViewController?
	
	func cancelOffer() {
		let alert = UIAlertController(title: "Are you sure?", message: "Cancelling this offer cannot be undone. You will not be paid.", preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
		
		alert.addAction(UIAlertAction(title: "I'm Sure", style: .destructive, handler: { (ui) in
			self.cancelOfferAction()
		}))
		
		self.present(alert, animated: true)
	}
	
	func cancelOfferAction() {
		//Alg by MARCO!
		//Cancelling an offer must:
		//1. make sure this offer is currently not cancelled...
		//2. change the offer status to: AllRejected. All posts to rejected. The message recieved: "User has cancelled the offer"
		//3. shouldn't dismiss the offer, should just update it.
		//4. Update the OfferPool value with the cashPower = cashPower + (GetFeeForOffer(???) or something like this.)
		
		guard let OfferID = offer?.offer_ID else {return}
		let ref = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(OfferID)
		
		ref.observeSingleEvent(of: .value) { (snapshot) in
			if let offerDict = snapshot.value as? [String: AnyObject] {
				if isDeseralizable(dictionary: offerDict, type: .offer).count == 0 {
					var currentOffer: Offer?
					do {
						currentOffer = try Offer.init(dictionary: offerDict)
					} catch let error {
						print(error)
					}
					if let currentOffer = currentOffer {
						if currentOffer.posts.filter({ (post1) -> Bool in
							return post1.status == "verified" || post1.denyMessage == "You cancelled the offer."
						}).count == 0 {
							//Step 1 is now complete.
							//Step 2: The only thing that needs to be updated is the posts.
							let posts = currentOffer.posts
							currentOffer.posts.removeAll()
							var newPosts = [[String: Any]]()
							for p in posts {
								var newPost = p
								newPost.status = "rejected"
								newPost.denyMessage = "You cancelled the offer."
								newPosts.append(API.serializePost(post: newPost))
								currentOffer.posts.append(newPost)
							}
							for p in newPosts {
								print(p)
							}
							ref.updateChildValues(["posts": newPosts]) { (err, dataref) in
								if err != nil {
									showAlert(selfVC: self, caption: "Error accessing the database", title: "Cancel Failed", okayButton: "OK")
								} else {
									//step 2 passed, the offer was changed in the database. now, change it in the app:
									self.offer = currentOffer
									self.offerViewTable.reloadData()
									
									//Let's in progress know to update now. (If it's in progress)
									self.delegate?.reloadNow()
									
									//okay, finally make the cashPower in the original offer go UP!
									let offerPoolRef = Database.database().reference().child("OfferPool").child(currentOffer.ownerUserID).child(OfferID)
									offerPoolRef.observeSingleEvent(of: .value) { (snapshot) in
										if let offerDict = snapshot.value as? [String: AnyObject] {
											if isDeseralizable(dictionary: offerDict, type: .offer).count == 0 {
												var offerPoolOffer: Offer?
												do {
													offerPoolOffer = try Offer.init(dictionary: offerDict)
												} catch let error {
													print(error)
												}
												if let offerPoolOffer = offerPoolOffer {
													var newCashPower = offerPoolOffer.cashPower ?? 0
													newCashPower += currentOffer.money
													offerPoolRef.updateChildValues(["cashPower": newCashPower]) { (err, dataref) in
														print("The cancellation of this offer has been completed.")
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
		}
	}
	
	func didAccept() {
		acceptAction()
	}
	
    func AcceptWasPressed() {
        
        if let offerValue = offer{
            
            if AnalyzeUser(user: Yourself, offerValue: offerValue).count == 0 {
                performSegue(withIdentifier: "toAcceptVerifier", sender: self)
            }else{
                
                self.showStandardAlertDialog(title: "Your account is suspicious", msg: "You may not accept offers at this time.") { (alert) in
                    
                }
                
            }
        }
    }

	
    func DismissWhenReservedTimeEnd() {
		self.dismiss(animated: true) {
			self.navigationController?.dismiss(animated: true, completion: nil)
		}
    }
    
	@IBAction func reportClicked(_ sender: Any) {
		
	}
	
    //MARK: Post Did Select
    
    func sendPostObjects(index: Int, offervariation: OfferVariation, offer: Offer) {
        if offervariation == .canNotBeAccepted || offervariation == .canBeAccepted{
            self.performSegue(withIdentifier: "FromVOtoVC", sender: index)
        }else{
            self.performSegue(withIdentifier: "FromVOtoVP", sender: index)
        }
    }
    
	//MARK: UITableview Delegates
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if offerVariation! == .canNotBeAccepted {
			return 3
		}else if offerVariation! == .canBeAccepted {
			return offer!.isDefaultOffer ? 4 : 5
		}else if offerVariation! == .inProgress {
			return offer!.isDefaultOffer ? 4 : 5
		}else if self.offerVariation! == .didNotPostInTime {
			return 3
		}else if self.offerVariation! == .willBePaid {
			return 4
		}else if self.offerVariation! == .hasBeenPaid {
			return 4
		}else if self.offerVariation! == .allPostsDenied {
			return 2
		}else{
			return 1
		}
	}
	
	func CreateWarnCell(message: String, messageIsCantAccept: Bool = false) -> UITableViewCell {
		var cell  = offerViewTable.dequeueReusableCell(withIdentifier: "warnUser") as? WarnUser
		if cell == nil {
			let nib = Bundle.main.loadNibNamed("WarnUser", owner: self, options: nil)
			cell = nib![0] as? WarnUser
		}
		cell!.alertMessage.text = message
		cell!.displayWhyCantAcceptOnClick = messageIsCantAccept
		cell!.VCToDisplayOn = self
		return cell!
	}
	
	func CreatePostInfoCell(prompt: String) -> UITableViewCell {
		var cell  = offerViewTable.dequeueReusableCell(withIdentifier: "postsInfo") as? PostDetailCell
		if cell == nil {
			let nib = Bundle.main.loadNibNamed("PostDetailCell", owner: self, options: nil)
			cell = nib![0] as? PostDetailCell
		}
		cell!.prompt.text = prompt
		cell!.postDidSelectDelegate = self
		cell!.offerVariation = offerVariation!
		cell!.offer = offer!
		return cell!
	}

	func CreateCompanyInfoCell() -> UITableViewCell {
		var cell  = offerViewTable.dequeueReusableCell(withIdentifier: "companyInfo") as? CompanyInfo
		if cell == nil {
			let nib = Bundle.main.loadNibNamed("CompanyInfo", owner: self, options: nil)
			cell = nib![0] as? CompanyInfo
		}
		cell!.companyDetails = offer!.companyDetails
		return cell!
	}
	
	func CreateNextStepCell() -> UITableViewCell {
		var cell  = offerViewTable.dequeueReusableCell(withIdentifier: "nextStepInfo") as? NextStepCell
		if cell == nil {
			let nib = Bundle.main.loadNibNamed("NextStepCell", owner: self, options: nil)
			cell = (nib![0] as? NextStepCell)!
		}
		
		cell!.offer = offer!
		return cell!
	}
	
	func CreateReservedCell() -> UITableViewCell {
		var cell  = offerViewTable.dequeueReusableCell(withIdentifier: "offerReserved") as? ReservedCell
		if cell == nil {
			let nib = Bundle.main.loadNibNamed("ReservedCell", owner: self, options: nil)
			cell = (nib![0] as? ReservedCell)!
		}
		cell!.reservedCellDelegate = self
		cell!.offer = self.offer!
		return cell!
	}
	
	func CreateOfferMoneyCell() -> UITableViewCell {
		if offer!.isDefaultOffer {
			return offerViewTable.dequeueReusableCell(withIdentifier: "verifyInfo")!
		}
		var cell  = offerViewTable.dequeueReusableCell(withIdentifier: "moneyInfo") as? OfferMoneyTVC
		if cell == nil {
			let nib = Bundle.main.loadNibNamed("OfferMoneyTVC", owner: self, options: nil)
			cell = (nib![0] as? OfferMoneyTVC)!
		}
		cell!.offerVariation = self.offerVariation
		cell!.offer = offer!
		return cell!
	}
	
	func CreateAcceptButtonCell(indexPath: IndexPath) -> UITableViewCell {
		let cell = offerViewTable.dequeueReusableCell(withIdentifier: "acceptButton", for: indexPath) as! AcceptCell
		cell.delegate = self
		cell.acceptView.backgroundColor = acceptColorOne
		cell.CreateAnimation()
		cell.set21(mustBeTwentyOne: offer?.mustBe21 ?? true)
		return cell
	}
	
	func CreateCancelOfferButtonCell() -> UITableViewCell {
		var cell  = offerViewTable.dequeueReusableCell(withIdentifier: "abortOfferButton") as? AbortOffer
		if cell == nil {
			let nib = Bundle.main.loadNibNamed("AbortOffer", owner: self, options: nil)
			cell = (nib![0] as? AbortOffer)!
		}
		cell!.delegate = self
		return cell!
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if offerVariation! == .canNotBeAccepted{
			
			switch indexPath.row {
			case 0: return CreateWarnCell(message: "You cannot accept this offer.", messageIsCantAccept: true)
			case 1: return CreatePostInfoCell(prompt: "Posts in this offer")
			default: return CreateCompanyInfoCell()
			}
			
		}else if offerVariation! == .canBeAccepted {
			if offer!.isDefaultOffer {
				switch indexPath.row {
				case 0: return CreateOfferMoneyCell()
				case 1: return CreateCompanyInfoCell()
				case 2: return CreatePostInfoCell(prompt: "You would post the following to Instagram")
				default: return CreateAcceptButtonCell(indexPath: indexPath)
				}
			} else {
				switch indexPath.row {
				case 0: return CreateReservedCell()
				case 1: return CreateOfferMoneyCell()
				case 2: return CreateCompanyInfoCell()
				case 3: return CreatePostInfoCell(prompt: "You would post the following to Instagram")
				default: return CreateAcceptButtonCell(indexPath: indexPath)
				}
			}
		}else if offerVariation! == .inProgress {
			
			switch indexPath.row {
			case 0: return CreateNextStepCell()
			case 1: return CreateOfferMoneyCell()
			case 2: return CreateCompanyInfoCell()
			case 3: return CreatePostInfoCell(prompt: "Post the following to Instagram")
			default: return CreateCancelOfferButtonCell()
			}
			
		}else if self.offerVariation! == .didNotPostInTime {
			
			switch indexPath.row {
				case 0: return CreateWarnCell(message: "You did not post to Instagram in time. The offer has expired.")
				case 1: return CreateCompanyInfoCell()
				default: return CreatePostInfoCell(prompt: "What should have been posted")
			}
			
		}else if self.offerVariation! == .willBePaid {
			if indexPath.row == 0{
				let identifier = "goodWorkInfo"
				let cell = offerViewTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! GoodWorkCell
				cell.offer = self.offer!
				return cell
			}else if indexPath.row == 1{
				let identifier = "youWillBePaid"
				let cell = offerViewTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! WillBePaidCell
                cell.offerVariation = self.offerVariation!
				cell.offer = self.offer
				return cell
			}else if indexPath.row == 2{
				return CreateCompanyInfoCell()
			}else{
				return CreatePostInfoCell(prompt: "What you have posted")
			}
		}else if self.offerVariation! == .hasBeenPaid {
			if indexPath.row == 0{
				let identifier = "goodWorkInfo"
				let cell = offerViewTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! GoodWorkCell
				cell.hasBeenPaidOffer = self.offer!
				return cell
			}else if indexPath.row == 1{
				let identifier = "youWillBePaid"
				let cell = offerViewTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! WillBePaidCell
				cell.hasBeenPaidOffer = self.offer
				return cell
			}else if indexPath.row == 2{
				return CreateCompanyInfoCell()
			}else{
				return CreatePostInfoCell(prompt: "What you have posted")
			}
		}else if self.offerVariation! == .allPostsDenied {
			if indexPath.row == 0{
				let identifier = "allPostsDenied"
				let cell = offerViewTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RejectedMessageCell
				cell.offer = self.offer!
				return cell
			}else{
				return CreatePostInfoCell(prompt: "Press on post to see why")
			}
		}else{
			let identifier = "allPostsDenied"
			let cell = offerViewTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RejectedMessageCell
			return cell
		}
	}
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if self.offerVariation! == .didNotPostInTime{
          if indexPath.row == 1{
            
            self.performSegue(withIdentifier: "FromOVtoVB", sender: self.offer!.companyDetails)
            
         }
        }else if self.offerVariation! != .allPostsDenied {
            if indexPath.row == 2{
             self.performSegue(withIdentifier: "FromOVtoVB", sender: self.offer!.companyDetails)
            }
        }
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		if offerVariation! == .canNotBeAccepted {
			switch indexPath.row {
			case 0: return 69.0
			case 1: return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
			default: return 74.0
			}
		} else if offerVariation! == .canBeAccepted {
			if offer!.isDefaultOffer {
				switch indexPath.row {
				case 0: return 222.0
				case 1: return 74.0
				case 2: return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
				default: return 74.0
				}
			} else {
				switch indexPath.row {
				case 0: return 69.0
				case 1: return 222.0
				case 2: return 74.0
				case 3: return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
				default: return 74.0
				}
			}
		} else if offerVariation! == .inProgress {
			switch indexPath.row {
			case 0: return 119.5
			case 1: return 222.0
			case 2: return 74.0
			case 3: return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
			default: return 74.0
			}
		} else if self.offerVariation! == .didNotPostInTime {
			switch indexPath.row {
			case 0: return 69.0
			case 1: return 74.0
			default: return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
			}
		} else if self.offerVariation! == .willBePaid {
			switch indexPath.row {
			case 0: return 69.0
			case 1: return 80.0
			case 2: return 74.0
			default: return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
			}
		} else if self.offerVariation! == .hasBeenPaid {
			switch indexPath.row {
			case 0: return 69.0
			case 1: return 80.0
			case 2: return 74.0
			default: return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
			}
		} else {
			switch indexPath.row {
			case 0: return 222.0
			default: return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
			}
		}
	}
	
    
	func acceptAction() {
//		print("accept action was triggered.")
		if self.offer!.isDefaultOffer {
			updateIsAcceptedOffer(offer: self.offer!, money: 0)
			updateUserIdOfferPool(offer: self.offer!)
			self.dismiss(animated: true) {
				self.tabBarController?.selectedIndex = 3
			}
			return
		}
		
		if self.offerCount < 2  {
//			print("Offer Count < 2")
			if let incresePay = self.offer!.incresePay {
//				print("increasPay DOES exist")
				let pay = calculateCostForUser(offer: self.offer!, user: Yourself, increasePayVariable: incresePay)
				updateIsAcceptedOffer(offer: self.offer!, money: pay)
			}else{
//				print("increasePay Doesn't exist.")
				let pay = calculateCostForUser(offer: self.offer!, user: Yourself)
				updateIsAcceptedOffer(offer: self.offer!, money: pay)
			}

//			print("try to dismiss")
			updateUserIdOfferPool(offer: self.offer!)
			
			self.dismiss(animated: true) {
//				print("change bar indexpath")
				self.thisParent?.tabBarController?.selectedIndex = 3
			}
		
		}else{
			
			let alertController = UIAlertController.init(title: "Accept Failed", message: "You can only have a maximum of 2 active offers at a time.", preferredStyle: .alert)
			
			let action = UIAlertAction.init(title: "OK", style: .default) { (action) in
				
			}
			alertController.addAction(action)
			
			self.present(alertController, animated: true, completion: nil)
			
		}
	}
	
    @IBAction func dismissAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
	@IBOutlet weak var offerViewTable: UITableView!
	
	var offerVariation: OfferVariation? {
		get {
			return offer?.variation
		}
	}
	
	var offer: Offer?
    
    var offerCount: Int = 0
    
	
	@IBOutlet weak var reportButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		reportButton.isHidden = offer!.isDefaultOffer
		
		(navigationController as! StandardNC).shouldDismissOnLastSlide = false
		offerViewTable.alwaysBounceVertical = false
		offerViewTable.contentInset = UIEdgeInsets(top: 2, left: 0, bottom: 10, right: 0)
		
		if self.offerVariation == .canBeAccepted {
			if offer!.enoughCashForInfluencer {
				self.offerViewTable.dataSource = self
				self.offerViewTable.delegate = self
				if !(self.offer!.reservedUsers!.keys.contains(Yourself.id)){
					if !offer!.isDefaultOffer {
						let dateString = Date.getStringFromDate(date: Date().addMinutes(minute: 5))
						if let dateOne = Date.getDateFromString(date: dateString!){
							print("vvv=",Date.getStringFromDate(date: Date()) as Any)
							print("vvv1=",Date.getDateFromString(date: Date.getStringFromDate(date: Date())!) as Any)
							print(dateOne)
						}
						let pay = calculateCostForUser(offer: self.offer!, user: Yourself, increasePayVariable: self.offer!.incresePay!)
						let deductedAmount = pay + (self.offer!.commission! * self.offer!.cashPower!)
						let cash = (self.offer!.cashPower! - deductedAmount)
						self.offer!.cashPower = cash
						updateCashPower(cash: cash, offer: self.offer!)
						
						self.offer!.reservedUsers![Yourself.id] = ["isReserved":true as AnyObject,"isReservedUntil":dateString as AnyObject,"cashPower":deductedAmount as AnyObject]
						updateReservedOfferStatus(offer: self.offer!)
					}
				}
				getAcceptedOffers { (status, offers) in
					
					if status{
						self.offerCount = offers.filter{CheckIfOferIsActive(offer: $0) && $0.isDefaultOffer == false}.count
					}
					DispatchQueue.main.async {
						self.offerViewTable.reloadData()
					}
					
				}
			}else{
				self.dismiss(animated: true, completion: nil)
			}
			
		}else if self.offerVariation == .canNotBeAccepted {
			
			self.offerViewTable.dataSource = self
			self.offerViewTable.delegate = self
			self.offerViewTable.reloadData()
			
		}else if self.offerVariation == .inProgress{
			
			getAcceptedSimplexOffer(offer: self.offer!) { (status, offer) in
				
				if status{
					self.offer = offer
					self.offerViewTable.dataSource = self
					self.offerViewTable.delegate = self
					DispatchQueue.main.async {
						self.offerViewTable.reloadData()
					}
					
				}
				
			}
			
		} else {
			self.offerViewTable.dataSource = self
			self.offerViewTable.delegate = self
		}
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "FromVOtoVC"{
            let colorView = segue.destination as! ViewPostColorfulVC
            colorView.index = (sender as! Int)
            colorView.offer = (self.offer!)
        }else if segue.identifier == "FromVOtoVP"{
            let colorView = segue.destination as! ViewPostDetailedVC
            colorView.index = (sender as! Int)
            colorView.offer = (self.offer!)
        }else if segue.identifier == "FromOVtoVB"{
            let view = segue.destination as! ViewBusinessVC
            view.fromSearch = false
            view.businessDatail = (sender as! CompanyDetails)
		}else if segue.identifier == "toReportFromOV" {
			let view = segue.destination as! ReporterFeature
			view.TargetOffer = offer
		}else if segue.identifier == "toAcceptVerifier" {
			let view = segue.destination as! acceptVerifierVC
			view.set21(is21andOver: offer?.mustBe21 ?? true)
			view.delegate = self
		}
	}
	
	
}
