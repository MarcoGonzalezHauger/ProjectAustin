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

class RejectedMessageCell: UITableViewCell {
	@IBOutlet weak var rejectMessage: UILabel!
	
	var offer: Offer?{
		didSet{
			if let offerValue = offer{
				
				var detectedCount = 0
				
				for post in offerValue.posts {
					if post.status == "rejected"{
						detectedCount += 1
					}
				}
				
				if detectedCount == offerValue.posts.count{
					
					if offerValue.posts.count == 1{
						
						self.rejectMessage.text = "An Ambassadoor Verifier found that your post was not acceptable. Press on the post to view why"
						
					}else{
						
						self.rejectMessage.text = "An Ambassadoor Verifier found that your posts were not acceptable. Press on one of the posts to view why."
						
					}
					
				}else{
					self.rejectMessage.text = "An Ambassadoor Verifier found that your posts were not acceptable. Press on one of the posts to view why."
				}
			}
		}
	}
}

class GoodWorkCell: UITableViewCell{
	
	@IBOutlet weak var goodWorkDes: UILabel!
	
	var offer: Offer?{
		didSet{
			if let offerValue = offer{
				
				var detectedCount = 0
				
				for post in offerValue.posts {
					if post.status == "posted"{
						detectedCount += 1
					}
				}
				
				if detectedCount == offerValue.posts.count{
					
					if offerValue.posts.count == 1 {
						goodWorkDes.text = "Good Work!\nYour post has been detected."
					}else{
						goodWorkDes.text = "Good Work!\nAll posts have been detected."
					}
					
				}else{
					
					goodWorkDes.text = "Good Work!\n\(detectedCount)/\(offerValue.posts.count) posts have been detected."
					
				}
			}
		}
	}
	
	var hasBeenPaidOffer: Offer?{
		didSet{
			if let offerValue = hasBeenPaidOffer{
				var detectedCount = 0
				
				for post in offerValue.posts {
					if post.status == "paid"{
						detectedCount += 1
					}
				}
				
				if detectedCount == offerValue.posts.count{
					if offerValue.posts.count == 1 {
						goodWorkDes.text = "Good Work!\nYour post has been detected."
					}else{
						goodWorkDes.text = "Good Work!\nAll posts have been detected."
					}
				}else{
					goodWorkDes.text = "Good Work!\n\(detectedCount)/\(offerValue.posts.count) posts have been detected."
				}
			}
		}
	}
	
}

class WillBePaidCell: UITableViewCell {
	@IBOutlet weak var amtText: UILabel!
	@IBOutlet weak var leftTimeText: UILabel!
	@IBOutlet weak var progressView: ShadowView!
	
	var timer: Timer?
	var updatedDate: Date?
    
    var offerVariation: OfferVariation?
	
	@IBOutlet weak var widthConstraint: NSLayoutConstraint!
	
	var offer: Offer?{
		didSet{
			if let offerValue = offer{
				
				if self.timer != nil{
					timer!.invalidate()
					leftTimeText.text = ""
				}
				
				self.setInfluencerAmount(offerValue: offerValue)
				
				if let updatedDate = offerValue.updatedDate{
					
					
					let date = updatedDate.afterDays(day: 2)
					
					self.updatedDate = date
					
					let curDateStr = Date.getStringFromDate(date: Date())
					if let currentDate = Date.getDateFromString(date: curDateStr!){
						
						if date.timeIntervalSince1970 > currentDate.timeIntervalSince1970{
							
							//Interval between Posted Date and Current Date
							let intervalBtnOffActDateToCurDate = (updatedDate.timeIntervalSince1970 - currentDate.timeIntervalSince1970)
							
							//Interval between Posted Date and Added 48 hours
							let intervalBtnOffActDateToOfferExpDate = (date.timeIntervalSince1970 - updatedDate.timeIntervalSince1970)
							
							//Calculate Progress How long days gone after changed offer status
							widthConstraint.constant = CGFloat(intervalBtnOffActDateToCurDate/intervalBtnOffActDateToOfferExpDate) * self.frame.size.width
							
							progressView.updateConstraints()
							progressView.layoutIfNeeded()
							
							progressView.backgroundColor = UIColor.systemGreen
							
							self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerForWillPaidCell(sender:)), userInfo: nil, repeats: true)
							
							self.timerForWillPaidCell(sender: timer!)
							
                        }else{
                            leftTimeText.text = "\(offerValue.title) has expired to be paid"
                            
                            progressView.updateConstraints()
                            progressView.layoutIfNeeded()
                            
                            widthConstraint.constant = self.frame.size.width
                            
                            progressView.backgroundColor = UIColor.systemRed
                        }
						
					}
					
				}
			}
		}
	}
	
	func setInfluencerAmount(offerValue: Offer) {
		
		var postedCount = 0
        var totalAmt = 0.0
		for post in offerValue.posts {
			if post.status == "posted"{
                totalAmt += post.PayAmount!
				postedCount += 1
			}
		}
        
        self.amtText.text = NumberToPrice(Value: totalAmt)
		
//		if let incresePay = offerValue.incresePay {
//
//			let pay = calculateCostForUser(offer: offerValue, user: Yourself, increasePayVariable: incresePay)
//			let totalAmt = (pay/Double(postedCount))
//			self.amtText.text = NumberToPrice(Value: totalAmt)
//
//		}else{
//
//			let pay = calculateCostForUser(offer: offerValue, user: Yourself)
//			let totalAmt = (pay/Double(postedCount))
//			self.amtText.text = NumberToPrice(Value: totalAmt)
//		}
		
	}
	
	
	func setPaidAmount(offerValue: Offer) {
		
		var postedCount = 0
		var totalAmt = 0.0
		for post in offerValue.posts {
			if post.status == "paid"{
                totalAmt += post.PayAmount!
				postedCount += 1
			}
		}
		self.amtText.text = NumberToPrice(Value: totalAmt)
//		if let incresePay = offerValue.incresePay {
//
//			let pay = calculateCostForUser(offer: offerValue, user: Yourself, increasePayVariable: incresePay)
//			let totalAmt = (pay/Double(postedCount))
//			self.amtText.text = NumberToPrice(Value: totalAmt)
//
//		}else{
//
//			let pay = calculateCostForUser(offer: offerValue, user: Yourself)
//			let totalAmt = (pay/Double(postedCount))
//			self.amtText.text = NumberToPrice(Value: totalAmt)
//		}
		
	}
	
	@objc func timerForWillPaidCell(sender: Timer){
		
        if self.offerVariation! == .willBePaid{
		
		let answer: String? = DateToLetterCountdownWithFormat(date: self.updatedDate!, format: "")
		
		if let answer = answer{
			
			leftTimeText.text = "You will be paid in \(answer)"
			
		}
        }else{
            
            let answer: String? = DateToLetterCountdownWithFormat(date: self.updatedDate!, format: "")
            
            if let answer = answer{
                
                leftTimeText.text = "You will be paid in \(answer)"
                
            }
            
        }
	}
	
	var hasBeenPaidOffer: Offer?{
		didSet{
			if let offerValue = hasBeenPaidOffer{
				self.setPaidAmount(offerValue: offerValue)
				
				leftTimeText.text = "You have been paid."
				widthConstraint.constant = self.frame.size.width
				
				progressView.updateConstraints()
				progressView.layoutIfNeeded()
				
				progressView.backgroundColor = UIColor.systemGreen
				
			}
		}
	}
	
}

protocol reservedTimeEndDelegate {
    func DismissWhenReservedTimeEnd()
}

class ReservedCell: UITableViewCell {
	
	@IBOutlet weak var timeText: UILabel!

	var reservedTimer: Timer?
	
	var timerSeconds: Double = 0.0
    
    var reservedCellDelegate: reservedTimeEndDelegate?
	
	var offer: Offer?{
		didSet{
			if let offerValue = offer{
				
				if reservedTimer != nil{
					reservedTimer!.invalidate()
					timeText.text = ""
				}
				
				if let reservedOffers = offerValue.reservedUsers{
					
					if let reservedId = reservedOffers[Yourself.id]{
						
						if let offerReservedDate = reservedId["isReservedUntil"] as? String{
							
							/*
							let dateString = Date.getStringFromIso8601Date(date: Date().addMinutes(minute: 5))
							let dateOne = Date.getDateFromISO8601WOString(ISO8601String: dateString)
							*/
							
							if let date = Date.getDateFromString(date: offerReservedDate){
								
								//if let date = Date.getDateFromISO8601WOString(ISO8601String: offerReservedDate){
								
								//let curDateStr = Date.getStringFromIso8601Date(date: Date())
								let curDateStr = Date.getStringFromDate(date: Date())
								
								//if let curDate = Date.getDateFromISO8601WOString(ISO8601String: curDateStr){
								
								if let curDate = Date.getDateFromString(date: curDateStr!){
									
									if date.timeIntervalSince1970 > curDate.timeIntervalSince1970{
										
										self.timerSeconds = date.timeIntervalSince1970 - curDate.timeIntervalSince1970
										
										DispatchQueue.main.asyncAfter(deadline: .now() + self.timerSeconds) {
											self.updateReservedTime()
										}
										
										
										reservedTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.timerForReservedCell(sender:)), userInfo: nil, repeats: true)
										//RunLoop.current.add(self.reservedTimer!, forMode: RunLoop.Mode.common)
										self.timerForReservedCell(sender: reservedTimer!)
										
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	@objc func timerForReservedCell(sender: Timer){
		
		/*
		let dateString = Date.getStringFromIso8601Date(date: Date().addMinutes(minute: 5))
		let dateOne = Date.getDateFromISO8601WOString(ISO8601String: dateString)
		*/
		
		if let isReservedObject = self.offer!.reservedUsers![Yourself.id] {
			
			let isReservedUntil = isReservedObject["isReservedUntil"] as! String
			
			//if let date = Date.getDateFromISO8601WOString(ISO8601String: isReservedUntil){
			if let date = Date.getDateFromString(date: isReservedUntil){
				
				//let curDate = Date.getDateFromISO8601WOString(ISO8601String: Date.getStringFromIso8601Date(date: Date()))
				let curDate = Date.getDateFromString(date: Date.getStringFromDate(date: Date())!)

				//this is to make the red flashing with only one minute left.
				let calendar = Calendar.current
				let dateCom = calendar.dateComponents([.hour,.minute,.second], from: curDate!, to: date)
				
				if dateCom.minute! == 0 {
					timeText.textColor = dateCom.second! % 2 == 0 ? .systemRed : GetForeColor()
				}
				
				let answer: String? = DateToLetterCountdownWithFormat(date1: curDate!, date2: date, format: "")
				
				if let answer = answer{
					
					if answer == "0:00"{
						//self.updateReservedTime()
						reservedTimer!.invalidate()
						self.reservedCellDelegate?.DismissWhenReservedTimeEnd()
					} else {
						timeText.text = answer
					}
					
				}
				
			}
			
		}else{
			reservedTimer?.invalidate()
		}
		
	}
	
	func updateReservedTime() {
		
		if let incresePay = self.offer!.incresePay {
			
			let pay = calculateCostForUser(offer: self.offer!, user: Yourself, increasePayVariable: incresePay)
			let cash = (self.offer!.cashPower! + pay + (self.offer!.commission! * self.offer!.cashPower!))
			updateCashPower(cash: cash, offer: self.offer!)
			
		}else{
			
			let pay = calculateCostForUser(offer: self.offer!, user: Yourself)
			let cash = (self.offer!.cashPower! + pay + (self.offer!.commission! * self.offer!.cashPower!))
			updateCashPower(cash: cash, offer: self.offer!)
		}
		removeReservedOfferStatus(offer: self.offer!)
		self.offer!.reservedUsers?.removeValue(forKey: Yourself.id)
		
	}
	
}

class AcceptCell: UITableViewCell {
    
	@IBOutlet weak var acceptView: ShadowView!
	@IBOutlet weak var acceptButton: UIButton!
	var delegate: AcceptButtonDelegate?
	@IBAction func acceptButtonPressed(_ sender: Any) {
		delegate?.AcceptWasPressed()
	}
	func CreateAnimation() {
		self.acceptView.backgroundColor = .systemBlue
		print("animation has been created for accept button")
		if !alreadyTeal {
			FadeToTeal()
			alreadyTeal = true
		}
	}
	
	var alreadyTeal = false
	
	func FadeToBlue() {
		UIView.animate(withDuration: 2, delay: 0.0, options: [.allowUserInteraction], animations: { () -> Void in
			self.acceptView.backgroundColor = .systemBlue
		}, completion: { (bl) in
			self.FadeToTeal()
		})
	}
	
	func FadeToTeal() {
		UIView.animate(withDuration: 2, delay: 0.0, options: [.allowUserInteraction], animations: { () -> Void in
			self.acceptView.backgroundColor = .systemTeal
		}, completion: { (bl) in
			self.FadeToBlue()
		})
	}
	
}

class AbortOffer: UITableViewCell {
	
}

class NextStepCell: UITableViewCell {
	@IBOutlet weak var nextStepInstructions: UILabel!
	
	var offer: Offer?{
		didSet{
			if let offerValue = offer{
				
				if offerValue.posts.count == 3 {
					if offerValue.posts[0].status == "accepted"{
						
						self.nextStepInstructions.text = "View the instructions on 'Post 1' and post an image to Instagram following them"
						
					}else if offerValue.posts[1].status == "accepted"{
						
						self.nextStepInstructions.text = "View the instructions on 'Post 2' and post an image to Instagram following them"
						
					}else if offerValue.posts[2].status == "accepted"{
						
						self.nextStepInstructions.text = "View the instructions on 'Post 2' and post an image to Instagram following them"
						
					}
				}else if offerValue.posts.count == 2 {
					if offerValue.posts[0].status == "accepted"{
						
						self.nextStepInstructions.text = "View the instructions on 'Post 1' and post an image to Instagram following them"
						
					}else if offerValue.posts[1].status == "accepted"{
						
						self.nextStepInstructions.text = "View the instructions on 'Post 2' and post an image to Instagram following them"
						
					}
				}else if offerValue.posts.count == 1 {
					if offerValue.posts[0].status == "accepted"{
						
						self.nextStepInstructions.text = "View the instructions on 'Post 1' and post an image to Instagram following them"
						
					}
				}
				
			}
		}
	}
	
}

class OfferMoneyTVC: UITableViewCell {
	@IBOutlet weak var moneyText: UILabel!
    var offerVariation: OfferVariation?
	
	var offer: Offer?{
		didSet{
			if let offerValue = offer{
                
                if self.offerVariation! == .inProgress{
                    
                    self.moneyText.text = NumberToPrice(Value: offerValue.money)
                    
                }else{
                    if let incresePay = offerValue.incresePay {
                        
                        let pay = calculateCostForUser(offer: offerValue, user: Yourself, increasePayVariable: incresePay)
                        
                        self.moneyText.text = NumberToPrice(Value: pay)
                        
                    }else{
                        
                        let pay = calculateCostForUser(offer: offerValue, user: Yourself)
                        self.moneyText.text = NumberToPrice(Value: pay)
                    }
                }
                
			}
		}
	}
}

class WarnUser: UITableViewCell {
	@IBOutlet weak var alertMessage: UILabel!
	var displayWhyCantAcceptOnClick = false
	var VCToDisplayOn: UIViewController?
	@IBAction func wasClicked(_ sender: Any) {
		if displayWhyCantAcceptOnClick {
			let alert = UIAlertController(title: "Why You Can't Accept", message: "Your interests, location, etc. doesn't match the business's selected needs.", preferredStyle: .alert)
			
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			
			
			VCToDisplayOn?.present(alert, animated: true)
		}
	}
}

class CompanyInfo: UITableViewCell {
	
	@IBOutlet weak var cmpImage: UIImageView!
	@IBOutlet weak var cmpName: UILabel!
	
	var companyDetails: CompanyDetails?{
		didSet{
			if let company = companyDetails{
				if let profile = company.logo{
					self.cmpImage.downloadAndSetImage(profile)
				}else{
					self.cmpImage.UseDefaultImage()
				}
				
				self.cmpName.text = company.name
			}
		}
	}
	
}

class PostInfoCell: UITableViewCell {
	@IBOutlet weak var postSerial: UILabel!
	@IBOutlet weak var postName: UILabel!
//	@IBOutlet weak var postDesImg: UIImageView!
//	@IBOutlet weak var postDes: UILabel!
	@IBOutlet weak var shadow: ShadowView!
}

class PostDetailInfoCell: UITableViewCell {
    @IBOutlet weak var postDesImg: UIImageView!
    @IBOutlet weak var postDes: UILabel!
}

class PostDetailCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return offer!.posts.count
	}
	@IBOutlet weak var prompt: UILabel!
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.offerVariation! == .canNotBeAccepted || self.offerVariation! == .canBeAccepted{
        
		let identifier = "postsInfo"
		var cell = postList.dequeueReusableCell(withIdentifier: identifier) as? PostInfoCell
		
		if cell == nil {
			let nib = Bundle.main.loadNibNamed("PostInfoCell", owner: self, options: nil)
			cell = nib![0] as? PostInfoCell
		}
		
		//let post = offer!.posts[indexPath.row]
		
		if indexPath.row == 0 {
			
			cell!.shadow.backgroundColor = UIColor.systemBlue
//			let postIdentify = postStatus.returnImageStatus(status: post.status)
			cell!.postSerial.text = "1"
			cell!.postName.text = "Post 1"
//			cell!.postDes.text = "Post 1" + "(\(postIdentify.0.rawValue))"
//			cell!.postDesImg.image = UIImage.init(named: postIdentify.1)
			
		}else if indexPath.row == 1{
			
			cell!.shadow.backgroundColor = UIColor.systemRed
//			let postIdentify = postStatus.returnImageStatus(status: post.status)
			cell!.postSerial.text = "2"
			cell!.postName.text = "Post 2"
//			cell!.postDes.text = "Post 2" + "(\(postIdentify.0.rawValue))"
//			cell!.postDesImg.image = UIImage.init(named: postIdentify.1)
			
		}else{
			
			cell!.shadow.backgroundColor = UIColor.systemYellow
//			let postIdentify = postStatus.returnImageStatus(status: post.status)
			cell!.postSerial.text = "3"
			cell!.postName.text = "Post 3"
//			cell!.postDes.text = "Post 3" + "(\(postIdentify.0.rawValue))"
//			cell!.postDesImg.image = UIImage.init(named: postIdentify.1)
			
		}
		return cell!
        }else{
            let identifier = "postsDetailInfo"
            var cell = postList.dequeueReusableCell(withIdentifier: identifier) as? PostDetailInfoCell
            
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("PostDetailInfoCell", owner: self, options: nil)
                cell = nib![0] as? PostDetailInfoCell
            }
            let post = offer!.posts[indexPath.row]
            if indexPath.row == 0 {
                        
            let postIdentify = postStatus.returnImageStatus(status: post.status)
            cell!.postDes.text = "Post 1 (\(postIdentify.0.rawValue))"
            cell!.postDesImg.image = UIImage.init(named: postIdentify.1)

            }else if indexPath.row == 1{

            let postIdentify = postStatus.returnImageStatus(status: post.status)

            cell!.postDes.text = "Post 2 (\(postIdentify.0.rawValue))"
            cell!.postDesImg.image = UIImage.init(named: postIdentify.1)

            }else{

            let postIdentify = postStatus.returnImageStatus(status: post.status)

            cell!.postDes.text = "Post 3 (\(postIdentify.0.rawValue))"
            cell!.postDesImg.image = UIImage.init(named: postIdentify.1)

            }
            return cell!
        }
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 50.0
	}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
                    
        self.postDidSelectDelegate?.sendPostObjects(index: indexPath.row, offervariation: offerVariation!, offer: self.offer!)
		tableView.deselectRow(at: indexPath, animated: true)
        
    }
	
	@IBOutlet weak var postList: UITableView!
	@IBOutlet weak var widthLayout: NSLayoutConstraint!
    
    var postDidSelectDelegate: postDidSelect?
    
    var offerVariation: OfferVariation?{
        didSet{
            
        }
    }
	
	var offer: Offer?{
		didSet{
			if let offerDetail = offer{
				if offerDetail.posts.count == 3 {
					widthLayout.constant = 150.0
					
					postList.updateConstraints()
					postList.layoutIfNeeded()
					
					
				}else if offerDetail.posts.count == 2{
					widthLayout.constant = 100
					postList.updateConstraints()
					postList.layoutIfNeeded()
				}else{
					widthLayout.constant = 50
					postList.updateConstraints()
					postList.layoutIfNeeded()
				}
				self.postList.reloadData()
				
			}
		}
	}
	
	
	override func awakeFromNib() {
		self.postList.register(UINib.init(nibName: "PostInfoCell", bundle: nil), forCellReuseIdentifier: "postcell")
        self.postList.register(UINib.init(nibName: "PostDetailInfoCell", bundle: nil), forCellReuseIdentifier: "postsDetailInfo")
	}
}

enum OfferVariation {
	case canBeAccepted, canNotBeAccepted, inProgress, didNotPostInTime, willBePaid, willBeApproved , hasBeenPaid, allPostsDenied
	
	static func getOfferVariation(status: String) -> OfferVariation{
		switch status {
		case "accepted":
			return .inProgress
		case "expired":
			return .didNotPostInTime
		case "posted":
			return .willBeApproved
        case "verified":
            return .willBePaid
		case "paid":
			return .hasBeenPaid
		case "rejected":
			return .allPostsDenied
		default:
			return .canBeAccepted
		}
	}
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
        case .willBeApproved:
            return .inProgressRows
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

class OfferViewerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, postDidSelect, reservedTimeEndDelegate, AcceptButtonDelegate {
	
	func AcceptWasPressed() {
		acceptAction()
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
		return NumberOfRows.returnHeight(count: offerVariation!).rawValue
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if offerVariation! == .canNotBeAccepted{
			
			if indexPath.row == 0{
				
				let identifier = "warnUser"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? WarnUser
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("WarnUser", owner: self, options: nil)
					cell = nib![0] as? WarnUser
				}
				cell!.alertMessage.text = "You cannot accept this offer."
				cell!.displayWhyCantAcceptOnClick = true
				cell!.VCToDisplayOn = self
				return cell!
				
			}else if indexPath.row == 1{
				
				let identifier = "postsInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? PostDetailCell
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("PostDetailCell", owner: self, options: nil)
					cell = nib![0] as? PostDetailCell
				}
				cell!.prompt.text = "Posts in this offer"
                cell!.postDidSelectDelegate = self
                cell!.offerVariation = offerVariation!
				cell!.offer = offer!
				return cell!
			}else{
				let identifier = "companyInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? CompanyInfo
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("CompanyInfo", owner: self, options: nil)
					cell = nib![0] as? CompanyInfo
				}
				cell!.companyDetails = offer!.companyDetails
				return cell!
			}
		}else if offerVariation! == .canBeAccepted {
			
			if indexPath.row == 0{
				
				let identifier = "offerReserved"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? ReservedCell
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("ReservedCell", owner: self, options: nil)
					cell = (nib![0] as? ReservedCell)!
				}
                cell!.reservedCellDelegate = self
				cell!.offer = self.offer!
				return cell!
				
			}else if indexPath.row == 1{
				
				let identifier = "moneyInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? OfferMoneyTVC
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("OfferMoneyTVC", owner: self, options: nil)
					cell = (nib![0] as? OfferMoneyTVC)!
				}
				cell!.offerVariation = self.offerVariation
				cell!.offer = offer!
				return cell!
				
			}else if indexPath.row == 2{
				let identifier = "companyInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? CompanyInfo
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("CompanyInfo", owner: self, options: nil)
					cell = nib![0] as? CompanyInfo
				}
				cell!.companyDetails = offer!.companyDetails
				return cell!
			}else if indexPath.row == 3{
				let identifier = "postsInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? PostDetailCell
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("PostDetailCell", owner: self, options: nil)
					cell = nib![0] as? PostDetailCell
				}
				cell!.prompt.text = "You would post the following to Instagram"
                cell!.postDidSelectDelegate = self
                cell!.offerVariation = offerVariation!
				cell!.offer = offer!
				return cell!
			}else{
				print("creating accept button")
				let identifier = "acceptButton"
				let cell = offerViewTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! AcceptCell
				cell.delegate = self
				cell.acceptView.backgroundColor = .systemBlue
				cell.CreateAnimation()
				return cell
			}
			
		}else if offerVariation! == .inProgress {
			
			if indexPath.row == 0 {
				let identifier = "nextStepInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? NextStepCell
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("NextStepCell", owner: self, options: nil)
					cell = (nib![0] as? NextStepCell)!
				}
				
				cell!.offer = offer!
				return cell!
			}else if indexPath.row == 1{
				
				let identifier = "moneyInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? OfferMoneyTVC
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("OfferMoneyTVC", owner: self, options: nil)
					cell = (nib![0] as? OfferMoneyTVC)!
				}
                cell!.offerVariation = self.offerVariation
				cell!.offer = offer!
				return cell!
				
			}else if indexPath.row == 2{
				let identifier = "companyInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? CompanyInfo
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("CompanyInfo", owner: self, options: nil)
					cell = nib![0] as? CompanyInfo
				}
				cell!.companyDetails = offer!.companyDetails
				return cell!
			}else if indexPath.row == 3{
				let identifier = "postsInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? PostDetailCell
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("PostDetailCell", owner: self, options: nil)
					cell = nib![0] as? PostDetailCell
				}
				cell!.prompt.text = "Post the following to Instagram"
                cell!.postDidSelectDelegate = self
                cell!.offerVariation = offerVariation!
				cell!.offer = offer!
				return cell!
			}else{
				let identifier = "abortOfferButton"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? AbortOffer
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("AbortOffer", owner: self, options: nil)
					cell = (nib![0] as? AbortOffer)!
				}
				return cell!
			}
		}else if self.offerVariation! == .didNotPostInTime {
			
			if indexPath.row == 0{
				
				let identifier = "warnUser"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? WarnUser
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("WarnUser", owner: self, options: nil)
					cell = nib![0] as? WarnUser
				}
				cell!.alertMessage.text = "You did not post to Instagram in time. Your offer hase been aborted."
				return cell!
				
			}else if indexPath.row == 1{
				let identifier = "companyInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? CompanyInfo
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("CompanyInfo", owner: self, options: nil)
					cell = nib![0] as? CompanyInfo
				}
				cell!.companyDetails = offer!.companyDetails
				return cell!
			}else{
				let identifier = "postsInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? PostDetailCell
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("PostDetailCell", owner: self, options: nil)
					cell = nib![0] as? PostDetailCell
				}
				cell!.prompt.text = "What should have been posted"
                cell!.postDidSelectDelegate = self
                cell!.offerVariation = offerVariation!
				cell!.offer = offer!
				return cell!
				
			}
			
		}else if self.offerVariation! == .willBePaid || self.offerVariation! == .willBeApproved {
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
				let identifier = "companyInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? CompanyInfo
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("CompanyInfo", owner: self, options: nil)
					cell = nib![0] as? CompanyInfo
				}
				cell!.companyDetails = offer!.companyDetails
				return cell!
			}else{
				let identifier = "postsInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? PostDetailCell
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("PostDetailCell", owner: self, options: nil)
					cell = nib![0] as? PostDetailCell
				}
				cell!.prompt.text = "What you have posted"
                cell!.postDidSelectDelegate = self
                cell!.offerVariation = offerVariation!
				cell!.offer = offer!
				return cell!
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
				let identifier = "companyInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? CompanyInfo
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("CompanyInfo", owner: self, options: nil)
					cell = nib![0] as? CompanyInfo
				}
				cell!.companyDetails = offer!.companyDetails
				return cell!
			}else{
				let identifier = "postsInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? PostDetailCell
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("PostDetailCell", owner: self, options: nil)
					cell = nib![0] as? PostDetailCell
				}
				cell!.prompt.text = "What you have posted"
                cell!.postDidSelectDelegate = self
                cell!.offerVariation = offerVariation!
				cell!.offer = offer!
				return cell!
			}
		}else if self.offerVariation! == .allPostsDenied {
			if indexPath.row == 0{
				//allPostsDenied
				let identifier = "allPostsDenied"
				let cell = offerViewTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RejectedMessageCell
				cell.offer = self.offer!
				return cell
			}else{
				let identifier = "postsInfo"
				var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? PostDetailCell
				if cell == nil {
					let nib = Bundle.main.loadNibNamed("PostDetailCell", owner: self, options: nil)
					cell = nib![0] as? PostDetailCell
				}
				cell!.prompt.text = "Press on post to see why"
                cell!.postDidSelectDelegate = self
                cell!.offerVariation = offerVariation!
				cell!.offer = offer!
				return cell!
			}
		}else{
			let identifier = "allPostsDenied"
			let cell = offerViewTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RejectedMessageCell
			return cell
		}
	}
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //tableView.deselectRow(at: indexPath, animated: true)
        if self.offerVariation! == .didNotPostInTime{
          if indexPath.row == 1{
            
            self.performSegue(withIdentifier: "FromOVtoVB", sender: self.offer!.companyDetails)
            
         }
        }else if self.offerVariation! != .allPostsDenied {
            if indexPath.row == 2{
             self.performSegue(withIdentifier: "FromOVtoVB", sender: self.offer!.companyDetails)
            }
        }
		//tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		if offerVariation! == .canNotBeAccepted{
			if indexPath.row == 0{
				
				return 69.0
				
			}else if indexPath.row == 1{
				
				return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
				
			}else{
				return 74.0
			}
		}else if offerVariation! == .canBeAccepted{
			if indexPath.row == 0{
				return 69.0
			}else if indexPath.row == 1{
				return 222.0
			}else if indexPath.row == 2{
				return 74.0
			}else if indexPath.row == 3{
				return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
			}else{
				return 74.0
			}
		}else if offerVariation! == .inProgress{
			if indexPath.row == 0{
				return 119.5
			}else if indexPath.row == 1{
				return 222.0
			}else if indexPath.row == 2{
				return 74.0
			}else if indexPath.row == 3{
				return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
			}else{
				return 74.0
			}
		}else if self.offerVariation! == .didNotPostInTime {
			if indexPath.row == 0{
				return 69.0
			}else if indexPath.row == 1{
				return 74.0
			}else{
				return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
			}
		}else if self.offerVariation! == .willBePaid || self.offerVariation! == .willBeApproved {
			if indexPath.row == 0{
				return 69.0
			}else if indexPath.row == 1{
				return 80.0
			}else if indexPath.row == 2{
				return 74.0
			}else{
				return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
			}
		}else if self.offerVariation! == .hasBeenPaid {
			if indexPath.row == 0{
				return 69.0
			}else if indexPath.row == 1{
				return 80.0
			}else if indexPath.row == 2{
				return 74.0
			}else{
				return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
			}
		}else if self.offerVariation! == .allPostsDenied{
			if indexPath.row == 0{
				return 220.0
			}else {
				return postRowHeight.returnRowHeight(count: offer!.posts.count).rawValue
			}
		}else{
			return 0
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
        
        self.dismiss(animated: true, completion: nil)
        }else{
            
            let alertController = UIAlertController.init(title: "Accept Failed", message: "You must finish you offers before accepting a new one", preferredStyle: .alert)
            
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
                    self.offerCount = offers.count
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
					self.offerVariation = OfferVariation.getOfferVariation(status: self.offer!.status)
					
					//                    if self.offerVariation! != .willBePaid && self.offerVariation! != .hasBeenPaid && self.offerVariation! != .allPostsDenied {
					//
					//                            var anyPostDetected = false
					//                            var anyPostPaid = false
					//                            var anyPostrejected = false
					//
					//                            for post in self.offer!.posts {
					//
					//                                if post.status == "posted"{
					//                                   anyPostDetected = !anyPostDetected
					//                                }
					//
					//                                if post.status == "paid"{
					//                                   anyPostPaid = !anyPostPaid
					//                                }
					//                                if post.status == "reject"{
					//                                   anyPostrejected = !anyPostrejected
					//                                }
					//                            }
					//
					//                            if anyPostPaid{
					//                               self.offerVariation = .hasBeenPaid
					//                            }else if anyPostDetected{
					//                                self.offerVariation = .willBePaid
					//                            }else if anyPostrejected{
					//                                self.offerVariation = .allPostsDenied
					//                            }
					//
					//
					//                    }
					
					self.offerViewTable.dataSource = self
					self.offerViewTable.delegate = self
					DispatchQueue.main.async {
						self.offerViewTable.reloadData()
					}
					
				}
				
			}
			
		}
		
		// Do any additional setup after loading the view.
	}
	
	
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destination.
	// Pass the selected object to the new view controller.
        
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
		}
	}
	
	
}
