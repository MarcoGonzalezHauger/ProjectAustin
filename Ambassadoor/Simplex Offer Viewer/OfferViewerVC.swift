//
//  OfferViewerVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 16/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive Property of Tesseract Freelance, LLC.
//

import UIKit

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

class OfferViewerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, postDidSelect, reservedTimeEndDelegate, AcceptButtonDelegate, didAcceptDeleagte {
	
	func didAccept() {
		acceptAction()
	}
	
	func AcceptWasPressed() {
		performSegue(withIdentifier: "toAcceptVerifier", sender: self)
	}

	
    func DismissWhenReservedTimeEnd() {
        self.dismiss(animated: true, completion: nil)
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
			return 5
		}else if offerVariation! == .inProgress {
			return 5
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
		return cell
	}
	
	func CreateCancelOfferButtonCell() -> UITableViewCell {
		var cell  = offerViewTable.dequeueReusableCell(withIdentifier: "abortOfferButton") as? AbortOffer
		if cell == nil {
			let nib = Bundle.main.loadNibNamed("AbortOffer", owner: self, options: nil)
			cell = (nib![0] as? AbortOffer)!
		}
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
			
			switch indexPath.row {
			case 0: return CreateReservedCell()
			case 1: return CreateOfferMoneyCell()
			case 2: return CreateCompanyInfoCell()
			case 3: return CreatePostInfoCell(prompt: "You would post the following to Instagram")
			default: return CreateAcceptButtonCell(indexPath: indexPath)
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
			switch indexPath.row {
			case 0: return 69.0
			case 1: return 222.0
			case 2: return 74.0
			case 3: return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
			default: return 74.0
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
		
		if self.offerCount < 2{
			
			if let incresePay = self.offer!.incresePay {
				let pay = calculateCostForUser(offer: self.offer!, user: Yourself, increasePayVariable: incresePay)
				updateIsAcceptedOffer(offer: self.offer!, money: pay)
			}else{
				let pay = calculateCostForUser(offer: self.offer!, user: Yourself)
				updateIsAcceptedOffer(offer: self.offer!, money: pay)
			}
			
			updateUserIdOfferPool(offer: self.offer!)
			
			self.dismiss(animated: true) {
				self.tabBarController?.selectedIndex = 3
			}
		
		}else{
			
			let alertController = UIAlertController.init(title: "Accept Failed", message: "You can only have a maximum of 2 active offers at a time.", preferredStyle: .alert)
			
			let action = UIAlertAction.init(title: "Ok", style: .default) { (action) in
				
			}
			alertController.addAction(action)
			
			self.present(alertController, animated: true, completion: nil)
			
		}
	}
	
    @IBAction func dismissAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
	@IBOutlet weak var offerViewTable: UITableView!
	
	var offerVariation: OfferVariation?
	
	var offer: Offer?
    
    var offerCount: Int = 0
    
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		(navigationController as! StandardNC).shouldDismissOnLastSlide = false
		offerViewTable.alwaysBounceVertical = false
		offerViewTable.contentInset = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
		
		if self.offerVariation == .canBeAccepted {
            
           let pay = calculateCostForUser(offer: self.offer!, user: Yourself, increasePayVariable: self.offer!.incresePay!)
            
            if pay <= self.offer!.cashPower!{
                
			self.offerViewTable.dataSource = self
			self.offerViewTable.delegate = self
			
			if !(self.offer!.reservedUsers!.keys.contains(Yourself.id)){
				
				let dateString = Date.getStringFromDate(date: Date().addMinutes(minute: 5))
				if let dateOne = Date.getDateFromString(date: dateString!){
					print("vvv=",Date.getStringFromDate(date: Date()) as Any)
					print("vvv1=",Date.getDateFromString(date: Date.getStringFromDate(date: Date())!) as Any)
					print(dateOne)
				}
				
                    let deductedAmount = pay + (self.offer!.commission! * self.offer!.cashPower!)
					let cash = (self.offer!.cashPower! - deductedAmount)
					self.offer!.cashPower = cash
					updateCashPower(cash: cash, offer: self.offer!)
                    
                    self.offer!.reservedUsers![Yourself.id] = ["isReserved":true as AnyObject,"isReservedUntil":dateString as AnyObject,"cashPower":deductedAmount as AnyObject]
                    updateReservedOfferStatus(offer: self.offer!)
					
			}
                
            getAcceptedOffers { (status, offers) in
                
                if status{
					self.offerCount = offers.filter{CheckIfOferIsActive(offer: $0)}.count
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
					self.offerVariation = offer.variation
					self.offerViewTable.dataSource = self
					self.offerViewTable.delegate = self
					DispatchQueue.main.async {
						self.offerViewTable.reloadData()
					}
					
				}
				
			}
			
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
			view.delegate = self
		}
	}
	
	
}
