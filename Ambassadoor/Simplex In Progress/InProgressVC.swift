//
//  InProgressVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 09/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class InProgressTVC: UITableViewCell, SyncTimerDelegate{
    func Tick() {
        
    }
    
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var postImgOne: UIImageView!
    @IBOutlet weak var postOne: UILabel!
    
    @IBOutlet weak var postImgTwo: UIImageView!
    @IBOutlet weak var postImgTwoHeight: NSLayoutConstraint!
    @IBOutlet weak var postTwo: UILabel!
    @IBOutlet weak var postTwoHeight: NSLayoutConstraint!
    
    @IBOutlet weak var postImgThree: UIImageView!
    @IBOutlet weak var postImgThreeHeight: NSLayoutConstraint!
    @IBOutlet weak var postThree: UILabel!
    @IBOutlet weak var postThreeHeight: NSLayoutConstraint!
    
    @IBOutlet weak var paymentReceiveAt: UILabel!
    @IBOutlet weak var progrssView: ShadowView!
    
    @IBOutlet weak var progressWidth: NSLayoutConstraint!
	@IBOutlet weak var progTemplate: ShadowView!
	
    var timer: Timer?
    var offer: Offer?{
        didSet{
			if let offerValue = offer {
				if self.timer != nil{
					timer!.invalidate()
					paymentReceiveAt.text = ""
				}
				if let picurl = offerValue.companyDetails?.logo {
					self.companyLogo.downloadAndSetImage(picurl)
				} else {
					self.companyLogo.UseDefaultImage()
				}
				self.amount.text = offerValue.isDefaultOffer ? "Get Verified" : NumberToPrice(Value: offerValue.money)
                self.name.text = offerValue.companyDetails != nil ? offerValue.companyDetails!.name : ""
				self.setTextandConstraints(offerValue: offerValue)
				
				if offerValue.variation == .inProgress {
					if let offerAcceptedDate = offerValue.acceptedDate{
						let expireDateAftAcpt = offerAcceptedDate.addingTimeInterval(TimeInterval(60 * 60 * 48 * offerValue.posts.count))
						let curDateStr = Date.getStringFromDate(date: Date())
						if let currentDate = Date.getDateFromString(date: curDateStr!){
							if currentDate.timeIntervalSince1970 < expireDateAftAcpt.timeIntervalSince1970{
								self.setInprogressValue(currentDate: currentDate, expireDateAftAcpt: expireDateAftAcpt, offerAcceptedDate: offerAcceptedDate)
								self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startCountDownForAccepted(sender:)), userInfo: nil, repeats: true)
								self.startCountDownForAccepted(sender: timer!)
							}else{
								progressWidth.constant = self.frame.size.width
								progrssView.updateConstraints()
								progrssView.layoutIfNeeded()
								progrssView.backgroundColor = UIColor.systemRed
								self.paymentReceiveAt.text = "You ran out of time to post."
							}
						}
					}
				}else if offerValue.variation == .willBePaid {
					
					self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startCountDownForTobepaid(sender:)), userInfo: nil, repeats: true)
					self.startCountDownForTobepaid(sender: timer!)
					
				}else if offerValue.variation == .hasBeenPaid {
					if offerValue.isDefaultOffer {
						paymentReceiveAt.text = "You have been verified."
						progrssView.backgroundColor = .systemOrange
					} else {
						paymentReceiveAt.text = "You have been paid for this offer."
						progrssView.backgroundColor = UIColor.systemGreen
					}
					progressWidth.constant = self.frame.size.width
					progrssView.updateConstraints()
					progrssView.layoutIfNeeded()
					
				}else if offerValue.variation == .allPostsDenied {
					
					paymentReceiveAt.text = "All posts were rejected by a verifier."
					progressWidth.constant = self.frame.size.width
					progrssView.updateConstraints()
					progrssView.layoutIfNeeded()
					progrssView.backgroundColor = UIColor.systemRed
					
				} else if offerValue.variation == .didNotPostInTime {
					
					paymentReceiveAt.text = "You didn't post in time."
					progressWidth.constant = self.frame.size.width
					progrssView.updateConstraints()
					progrssView.layoutIfNeeded()
					progrssView.backgroundColor = UIColor.systemRed
					
				}
			}
		}
	}
    
    @IBAction func startCountDownForAccepted(sender: Timer!) {
        
        
        let offerValue = self.offer!
		
		if offerValue.isDefaultOffer {
			paymentReceiveAt.text = "Waiting for you to post to Instagram."
			progressWidth.constant = (self.frame.size.width - 12)
			progrssView.backgroundColor = .systemBlue
			return
		}
        
		if offerValue.variation == .inProgress {
            
            if let offerAcceptedDate = offerValue.acceptedDate {
                
                //let dayCount = offerValue.posts.count * 2
				let expireDateAftAcpt = offerAcceptedDate.addingTimeInterval(TimeInterval(60*60*48*offerValue.posts.count))
                
                let curDateStr = Date.getStringFromDate(date: Date())
                
                let currentDate = Date.getDateFromString(date: curDateStr!)!
                
                self.setInprogressValue(currentDate: currentDate, expireDateAftAcpt: expireDateAftAcpt, offerAcceptedDate: offerAcceptedDate)
                
                
                let answer: String? = DateToLetterCountdown(date: expireDateAftAcpt)
                
							
				
                if let answer = answer{
                    
                    paymentReceiveAt.text = "\(answer) left to post all to Instagram."
                    
                }else{
                    paymentReceiveAt.text = "Time's up."
                    self.timer?.invalidate()
                }
                
            }
        }
		
	}
	
	func setProgressToVerification() {
	}
	
	func setInprogressValue(currentDate: Date, expireDateAftAcpt: Date, offerAcceptedDate: Date) {
		
		//Interval between Offer Acceted Date and Current Date
		let intervalBtnOffActDateToCurDate = (currentDate.timeIntervalSince1970 - offerAcceptedDate.timeIntervalSince1970)
		
		//Interval between Offer Acceted Date and expiring offer after Accepted Offer
		let intervalBtnOffActDateToOfferExpDate = (expireDateAftAcpt.timeIntervalSince1970 - offerAcceptedDate.timeIntervalSince1970)
		
		//            print("after=",intervalBtnOffActDateToOfferExpDate)
		//             print("before",intervalBtnOffActDateToCurDate)
		
		
		//Calculate Progress How long days gone after accepting the offer
		// progressWidth.constant = CGFloat(intervalBtnOffActDateToCurDate/intervalBtnOffActDateToOfferExpDate) * self.frame.size.width
		
//		print(1.0 - CGFloat(intervalBtnOffActDateToCurDate/intervalBtnOffActDateToOfferExpDate))
//		print(self.progTemplate.frame.size.width)
		progressWidth.constant = (self.frame.size.width - 12) * (1.0 - CGFloat(intervalBtnOffActDateToCurDate/intervalBtnOffActDateToOfferExpDate))
		
//		UIView.animate(withDuration: 1) {
//			self.progrssView.layoutIfNeeded()
//		}
		progrssView.updateConstraints()
		
		progrssView.backgroundColor = UIColor.systemBlue
		
		
		
	}
	
    @IBAction func startCountDownForTobepaid(sender: Timer){
		
        let offerValue = self.offer!

		if let offerAcceptedDate = offerValue.acceptedDate{
			
			let currentDate = Date()
			let expireDateAftPosted = offerAcceptedDate.afterDays(numberOfDays: 2)
			
			if currentDate.timeIntervalSince1970 < expireDateAftPosted.timeIntervalSince1970{
				let intBtnNowandPosted = (currentDate.timeIntervalSince1970 - offerAcceptedDate.timeIntervalSince1970)
				let intAftTwoDays = (expireDateAftPosted.timeIntervalSince1970 - offerAcceptedDate.timeIntervalSince1970)
				progressWidth.constant = CGFloat(intBtnNowandPosted/intAftTwoDays) * (self.frame.size.width - 12)
				
				progrssView.updateConstraints()
				progrssView.layoutIfNeeded()
				progrssView.backgroundColor = offerValue.isDefaultOffer ? .systemOrange : .systemGreen
				
			}else{
				paymentReceiveAt.text = "ERROR_406"
				progressWidth.constant = self.frame.size.width
				progrssView.updateConstraints()
				progrssView.layoutIfNeeded()
				progrssView.backgroundColor = UIColor.systemRed
			}
		}
        
        if offerValue.status == "verified"{
            
            if let offerPostedDate = offerValue.acceptedDate{
                
                let expireDateAftPosted = offerPostedDate.afterDays(numberOfDays: 2)
                
                let answer: String? = DateToLetterCountdownWithFormat(date: expireDateAftPosted, format: "hh:mm:ss")
                
                if  answer == "0:00"{
                    paymentReceiveAt.text = ""
                    self.timer?.invalidate()
                    
                }else{
					if offerValue.isDefaultOffer {
						paymentReceiveAt.text = "You will be verified in \(answer!)"
					} else {
						paymentReceiveAt.text = "Payment in \(answer!)"
					}
                }
                
            }
            
        }
        
    }
    
    func setTextandConstraints(offerValue: Offer) {
        if offerValue.posts.count < 3 {
			
            if offerValue.posts.count == 2 {
				
                postImgThreeHeight.constant = 0
                postThreeHeight.constant = 0
                
                postImgThree.updateConstraints()
                postImgThree.layoutIfNeeded()
                
                postThree.updateConstraints()
                postThree.layoutIfNeeded()

                postImgTwoHeight.constant = 24
                postTwoHeight.constant = 18

                postImgTwo.updateConstraints()
                postImgTwo.layoutIfNeeded()

                postTwo.updateConstraints()
                postTwo.layoutIfNeeded()
                
                postImgOne.image = UIImage.init(named: postStatus.returnImageStatus(status: offerValue.posts[0].status).1)
                postOne.text = " Post 1 (\(postStatus.returnImageStatus(status: offerValue.posts[0].status).0.rawValue))"
                
                postImgTwo.image = UIImage.init(named: postStatus.returnImageStatus(status: offerValue.posts[1].status).1)
                postTwo.text = " Post 2 (\(postStatus.returnImageStatus(status: offerValue.posts[1].status).0.rawValue))"
                
            }else if offerValue.posts.count == 1 {
                
                postImgThreeHeight.constant = 0
                postThreeHeight.constant = 0
                
                postImgTwoHeight.constant = 0
                postTwoHeight.constant = 0
                
//                .constant = 24
//                postThreeHeight.constant = 18
                
                postImgThree.updateConstraints()
                postImgThree.layoutIfNeeded()
                
                postThree.updateConstraints()
                postThree.layoutIfNeeded()
                
                postImgTwo.updateConstraints()
                postImgTwo.layoutIfNeeded()
                
                postTwo.updateConstraints()
                postTwo.layoutIfNeeded()
                
                
                
                postImgOne.image = UIImage.init(named: postStatus.returnImageStatus(status: offerValue.posts[0].status).1)
                postOne.text = " Post 1 (\(postStatus.returnImageStatus(status: offerValue.posts[0].status).0.rawValue))"
                
            }
        }else{
            
            postImgThreeHeight.constant = 24
            postThreeHeight.constant = 18

            postImgTwoHeight.constant = 24
            postTwoHeight.constant = 18

            postImgThree.updateConstraints()
            postImgThree.layoutIfNeeded()

            postThree.updateConstraints()
            postThree.layoutIfNeeded()

            postImgTwo.updateConstraints()
            postImgTwo.layoutIfNeeded()

            postTwo.updateConstraints()
            postTwo.layoutIfNeeded()
            
            postImgOne.image = UIImage.init(named: postStatus.returnImageStatus(status: offerValue.posts[0].status).1)
            postOne.text = " Post 1 (\(postStatus.returnImageStatus(status: offerValue.posts[0].status).0.rawValue))"
            
            postImgTwo.image = UIImage.init(named: postStatus.returnImageStatus(status: offerValue.posts[1].status).1)
            postTwo.text = " Post 2 (\(postStatus.returnImageStatus(status: offerValue.posts[1].status).0.rawValue))"
            
            postImgThree.image = UIImage.init(named: postStatus.returnImageStatus(status: offerValue.posts[2].status).1)
            postThree.text = " Post 3 (\(postStatus.returnImageStatus(status: offerValue.posts[2].status).0.rawValue))"
            
        }
        
    }
    
}

enum rowHeight: CGFloat {
    case one = 140, two = 168, three = 196
    
    static func returnRowHeight(count: Int) -> rowHeight{
        
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

enum postStatus: String {
    case NotPosted = "Not Posted",Posted = "Posted",Verified = "Verified", Rejected = "Rejected", Paid = "Paid"
    
    static func returnImageStatus(status: String)->(postStatus, String, UIColor){
        switch status {
        case "accepted":
        return(.NotPosted, "notPosted", GetForeColor())
        case "posted":
            return(.Posted, "isPosted", .systemGreen)
        case "verified":
            return(.Verified, "postVerified", .systemBlue)
        case "rejected":
            return(.Rejected, "postRejected", .systemRed)
        case "paid":
        return(.Paid, "payment verified", .systemBlue)
        default:
            return(.NotPosted, "notPosted", GetForeColor())
        }
    }
}

func CheckIfOferIsActive(offer: Offer) -> Bool {
	return offer.variation == .inProgress || offer.variation == .willBePaid
}

class InProgressVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
	@IBOutlet weak var noneView: UIView!
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return allInprogressOffer.count + (shouldHaveHeader() ? 1 : 0)
    }
	
	func shouldHaveHeader() -> Bool {
		if currentItems != allInprogressOffer.count {
			if allInprogressOffer.count - currentItems > 0 {
				if currentItems > 0 {
					return true
				}
			}
		}
		return false
	}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let offer = GetOfferForIndex(index: indexPath.row) {
			let cell = inProgressTable.dequeueReusableCell(withIdentifier: "inprogresscell", for: indexPath) as! InProgressTVC
			cell.offer = offer
			cell.startCountDownForAccepted(sender: nil)
			return cell
		} else {
			return inProgressTable.dequeueReusableCell(withIdentifier: "prevOffer", for: indexPath)
		}
    }
    
	func GetOfferForIndex(index: Int) -> Offer? {
		if shouldHaveHeader() {
			if index < currentItems {
				return allInprogressOffer[index]
			} else if index == currentItems {
				return nil
			} else {
				return allInprogressOffer[index - 1]
			}
		} else {
			return allInprogressOffer[index]
		}
	}
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
		guard let offer = GetOfferForIndex(index: indexPath.row) else {
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}
        self.performSegue(withIdentifier: "FromInprogressToOV", sender: offer)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		if let thisOffer = GetOfferForIndex(index: indexPath.row) {
			return rowHeight.returnRowHeight(count: thisOffer.posts.count).rawValue
		} else {
			return 45
		}
    }
    
    @IBOutlet weak var inProgressTable: UITableView!
    
	var allInprogressOffer = [Offer]() {
		didSet {
			noneView.isHidden = allInprogressOffer.count != 0
		}
	}
    
    var offervariation: OfferVariation?
    
	@IBAction func goToOffers(_ sender: Any) {
		self.tabBarController?.selectedIndex = 2
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		inProgressTable.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
	
	var currentItems = 0
	
    override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
//		UIApplication.shared.applicationIconBadgeNumber = 0
//		self.tabBarController?.tabBar.items![3].badgeValue = nil
		if global.allInprogressOffer.count == 0 {
			getAcceptedOffers { (status, offers) in
				if status{
					
					self.currentItems = offers.filter{CheckIfOferIsActive(offer: $0)}.count
					
					self.allInprogressOffer = offers
					global.allInprogressOffer = offers
					DispatchQueue.main.async {
						self.inProgressTable.reloadData()
					}
				}
				
			}
		}else{
			self.allInprogressOffer = global.allInprogressOffer
			self.currentItems = global.allInprogressOffer.filter{CheckIfOferIsActive(offer: $0)}.count
			DispatchQueue.main.async {
				self.inProgressTable.reloadData()
			}
		}
	}
    
	    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "FromInprogressToOV" {
        //guard let newviewoffer = viewoffer else { return }
        let destination = (segue.destination as! StandardNC).topViewController as! OfferViewerVC
			destination.offer = sender as? Offer
         }
        
    }
    

}
