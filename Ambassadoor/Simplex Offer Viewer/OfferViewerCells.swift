//
//  OfferViewerCells.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 5/8/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import UIKit


class RejectedMessageCell: UITableViewCell {
	@IBOutlet weak var rejectMessage: UILabel!
	@IBOutlet weak var rejectedHeading: UILabel!
	
	var offer: Offer?{
		didSet{
			if let offerValue = offer{
				
				if offerValue.isCancelledByUser {
					rejectedHeading.text = "Offer Cancelled"
					rejectMessage.text = "If this offer was somehow unfair or a scam, report it.\n\n"
				} else {
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
}

class GoodWorkCell: UITableViewCell{
	
	@IBOutlet weak var goodWorkDes: UILabel!
	
	var offer: Offer?{
		didSet{
			if let offerValue = offer{
				
				let detectedCount = offerValue.posts.filter{$0.status == "posted"}.count
				let paidCount = offerValue.posts.filter{$0.status == "paid" || $0.status == "verified"}.count
				
				if paidCount == 0 {
					if detectedCount == offerValue.posts.count{
						
						if offerValue.posts.count == 1 {
							goodWorkDes.text = "Good Work!\nYour post has been detected."
						}else{
							goodWorkDes.text = "Good Work!\nAll posts have been detected."
						}
						
					}else{
						goodWorkDes.text = "Good Work!\n\(detectedCount)/\(offerValue.posts.count) posts have been detected."
					}
				} else {
					if paidCount == offerValue.posts.count{
						
						if offerValue.posts.count == 1 {
							goodWorkDes.text = "Good Work!\nYour post has been approved."
						}else{
							goodWorkDes.text = "Good Work!\nAll posts have been approved."
						}
						
					}else{
						goodWorkDes.text = "Good Work!\n\(paidCount)/\(offerValue.posts.count) posts have been approved."
					}
				}
			}
		}
	}
	
	var hasBeenPaidOffer: Offer?{
		didSet {
			offer = hasBeenPaidOffer
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
				
				if let updatedDate = offerValue.acceptedDate{
					
					
					let date = updatedDate.addingTimeInterval(60*60*48)
					
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
							leftTimeText.text = "Paid"
							
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
		
		setPaidAmount(offerValue: offerValue)
		
	}
	
	
	func setPaidAmount(offerValue: Offer) {
		
		var totalAmt = 0.0
		for post in offerValue.posts {
			if post.status == "posted" || post.status == "verified" || post.status == "paid" {
				totalAmt += post.PayAmount!
			}
		}
		self.amtText.text = NumberToPrice(Value: totalAmt, enforceCents: true)
		
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
										RunLoop.current.add(self.reservedTimer!, forMode: RunLoop.Mode.common)
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
		
		guard let urself = Yourself else { return }
		
		if let isReservedObject = self.offer!.reservedUsers![urself.id] {
			
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

let acceptColorOne: UIColor = UIColor.init(named: "acceptColor1")!
let acceptColorTwo: UIColor = UIColor.init(named: "acceptColor2")!

class AcceptCell: UITableViewCell {
	
    
	@IBOutlet weak var acceptView: ShadowView!
	@IBOutlet weak var acceptButton: UIButton!
	var delegate: AcceptButtonDelegate?
	
	
	@IBAction func acceptButtonPressed(_ sender: Any) {
		delegate?.AcceptWasPressed()
	}
	func CreateAnimation() {
		self.acceptView.backgroundColor = acceptColorOne
		print("animation has been created for accept button")
		if !alreadyTeal {
			FadeToTeal()
			alreadyTeal = true
		}
	}
	
	func set21(mustBeTwentyOne: Bool) {
		acceptButton.setTitle(mustBeTwentyOne ? "ACCEPT (21+)" : "ACCEPT", for: .normal)
	}
	
	var alreadyTeal = false
	
	func FadeToBlue() {
		UIView.animate(withDuration: 2, delay: 0.0, options: [.allowUserInteraction], animations: { () -> Void in
			self.acceptView.backgroundColor = acceptColorOne
		}, completion: { (bl) in
			self.FadeToTeal()
		})
	}
	
	func FadeToTeal() {
		UIView.animate(withDuration: 2, delay: 0.0, options: [.allowUserInteraction], animations: { () -> Void in
			self.acceptView.backgroundColor = acceptColorTwo
		}, completion: { (bl) in
			self.FadeToBlue()
		})
	}
	
}

protocol CancelOffer {
	func cancelOffer()
}

class AbortOffer: UITableViewCell {
	
	var delegate: CancelOffer?
	
	@IBAction func cancelButtonPressed(_ sender: Any) {
		delegate?.cancelOffer()
	}
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
                    
                    let pay = calculateCostForUser(offer: offerValue, user: Yourself, increasePayVariable: offerValue.incresePay!)
                        
					self.moneyText.text = NumberToPrice(Value: pay)
                        
                    
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
		
		if self.offerVariation! == .canNotBeAccepted || self.offerVariation! == .canBeAccepted {
			
			let identifier = "postsInfo"
			var cell = postList.dequeueReusableCell(withIdentifier: identifier) as? PostInfoCell
			
			if cell == nil {
				let nib = Bundle.main.loadNibNamed("PostInfoCell", owner: self, options: nil)
				cell = nib![0] as? PostInfoCell
			}
			
			//let post = offer!.posts[indexPath.row]
			
			cell!.postSerial.text = "\(indexPath.row + 1)"
			cell!.postName.text = "Post \(indexPath.row + 1)"
			
			
			if indexPath.row == 0 {
				cell!.shadow.backgroundColor = UIColor.systemBlue
			}else if indexPath.row == 1{
				cell!.shadow.backgroundColor = UIColor.systemRed
			}else{
				cell!.shadow.backgroundColor = UIColor.systemYellow
			}
			return cell!
		} else {
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
			let px = 1 / UIScreen.main.scale
			let frame = CGRect(x: 0, y: 0, width: postList.frame.size.width, height: px)
			let line = UIView(frame: frame)
			self.postList.tableHeaderView = line
			line.backgroundColor = self.postList.separatorColor
			let subtractby: CGFloat = 1
			if let offerDetail = offer{
				if offerDetail.posts.count == 3 {
					widthLayout.constant = 150 - subtractby
					
					postList.updateConstraints()
					postList.layoutIfNeeded()
					
					
				}else if offerDetail.posts.count == 2{
					widthLayout.constant = 100 - subtractby
					postList.updateConstraints()
					postList.layoutIfNeeded()
				}else{
					widthLayout.constant = 50 - subtractby
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

