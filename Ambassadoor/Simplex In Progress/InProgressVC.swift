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
    
    var timer: Timer?
    var offer: Offer?{
        didSet{
            
            
            if let offerValue = offer{
                
                if self.timer != nil{
                   timer!.invalidate()
                    paymentReceiveAt.text = ""
                }
                
                if let picurl = offerValue.company?.logo {
                    self.companyLogo.downloadAndSetImage(picurl)
                } else {
                    self.companyLogo.UseDefaultImage()
                }
                
                self.amount.text = NumberToPrice(Value: offerValue.money)
                
//                if let incresePay = offerValue.incresePay {
//
//                    let pay = calculateCostForUser(offer: offerValue, user: Yourself, increasePayVariable: incresePay)
//
//                    self.amount.text = NumberToPrice(Value: pay)
//
//                }else{
//
//                    let pay = calculateCostForUser(offer: offerValue, user: Yourself)
//                    self.amount.text = NumberToPrice(Value: pay)
//                }
                
                self.name.text = offerValue.company!.name
                self.setTextandConstraints(offerValue: offerValue)
                
                //if offerValue.status == "accepted"{
                if OfferVariation.getOfferVariation(status: offerValue.status) == .inProgress {
                    
                    if let offerAcceptedDate = offerValue.updatedDate{
                        
                        print("abc1=",offerAcceptedDate)
                        //let dayCount = offerValue.posts.count * 2
                        let expireDateAftAcpt = offerAcceptedDate.afterDays(day: 2)
                        
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
						
                        //Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startCountDownForTobepaid(sender:)), userInfo: nil, repeats: true)
                        
                    }
                //}else if offerValue.status == "posted" {
                }else if OfferVariation.getOfferVariation(status: offerValue.status) == .willBeApproved{
                    if let offerAcceptedDate = offerValue.updatedDate{
                        
                        let expireDateAftPosted = offerAcceptedDate.afterDays(day: 2)
                        
                        let curDateStr = Date.getStringFromDate(date: Date())
                        
                        if let currentDate = Date.getDateFromString(date: curDateStr!){
                            
                            if currentDate.timeIntervalSince1970 < expireDateAftPosted.timeIntervalSince1970{
                         
                            let intBtnNowandPosted = (currentDate.timeIntervalSince1970 - offerAcceptedDate.timeIntervalSince1970)
                            
                            let intAftTwoDays = (expireDateAftPosted.timeIntervalSince1970 - offerAcceptedDate.timeIntervalSince1970)
                            
                                
                                progressWidth.constant = CGFloat(intBtnNowandPosted/intAftTwoDays) * self.frame.size.width

                                progrssView.updateConstraints()
                                progrssView.layoutIfNeeded()
                                
                                progrssView.backgroundColor = UIColor.systemGreen
                                
                                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startCountDownForTobeapproved(sender:)), userInfo: nil, repeats: true)

                                self.startCountDownForTobeapproved(sender: timer!)
                                
                            }else{
                                //paymentReceiveAt.text = "\(offerValue.title) has expired to be paid"
                                paymentReceiveAt.text = ""
                                progressWidth.constant = self.frame.size.width

                                progrssView.updateConstraints()
                                progrssView.layoutIfNeeded()
                                
                                progrssView.backgroundColor = UIColor.systemRed
                            }
                            
                        }
                        
                    }
                    
                }else if OfferVariation.getOfferVariation(status: offerValue.status) == .willBePaid{
                    
                    if let offerAcceptedDate = offerValue.updatedDate{
                        
                        let expireDateAftPosted = offerAcceptedDate.afterDays(day: 2)
                        
                        let curDateStr = Date.getStringFromDate(date: Date())
                        
                        if let currentDate = Date.getDateFromString(date: curDateStr!){
                            
                            if currentDate.timeIntervalSince1970 < expireDateAftPosted.timeIntervalSince1970{
                         
                            let intBtnNowandPosted = (currentDate.timeIntervalSince1970 - offerAcceptedDate.timeIntervalSince1970)
                            
                            let intAftTwoDays = (expireDateAftPosted.timeIntervalSince1970 - offerAcceptedDate.timeIntervalSince1970)
                            
                                
                                progressWidth.constant = CGFloat(intBtnNowandPosted/intAftTwoDays) * self.frame.size.width

                                progrssView.updateConstraints()
                                progrssView.layoutIfNeeded()
                                
                                progrssView.backgroundColor = UIColor.systemGreen
                                
                                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startCountDownForTobepaid(sender:)), userInfo: nil, repeats: true)

                                self.startCountDownForTobepaid(sender: timer!)
                                
                            }else{
                                //paymentReceiveAt.text = "\(offerValue.title) has expired to be paid"
                                paymentReceiveAt.text = ""
                                progressWidth.constant = self.frame.size.width

                                progrssView.updateConstraints()
                                progrssView.layoutIfNeeded()
                                
                                progrssView.backgroundColor = UIColor.systemRed
                            }
                            
                        }
                        
                    }
                    
                }else if OfferVariation.getOfferVariation(status: offerValue.status) == .hasBeenPaid{
                    
                    paymentReceiveAt.text = ""
                    progressWidth.constant = self.frame.size.width

                    progrssView.updateConstraints()
                    progrssView.layoutIfNeeded()
                    
                    progrssView.backgroundColor = UIColor.systemGreen
                    
                }else if OfferVariation.getOfferVariation(status: offerValue.status) == .allPostsDenied{
                    
                    paymentReceiveAt.text = ""
                    progressWidth.constant = self.frame.size.width

                    progrssView.updateConstraints()
                    progrssView.layoutIfNeeded()
                    
                    progrssView.backgroundColor = UIColor.systemRed
                    
                }
            }
        }
    }
    
    @IBAction func startCountDownForAccepted(sender: Timer) {
        
        
        let offerValue = self.offer!
        
        if offerValue.status == "accepted"{
            
            if let offerAcceptedDate = offerValue.updatedDate{
                
                //let dayCount = offerValue.posts.count * 2
                let expireDateAftAcpt = offerAcceptedDate.afterDays(day: 2)
                
                let curDateStr = Date.getStringFromDate(date: Date())
                
                let currentDate = Date.getDateFromString(date: curDateStr!)!
                
                self.setInprogressValue(currentDate: currentDate, expireDateAftAcpt: expireDateAftAcpt, offerAcceptedDate: offerAcceptedDate)
                
                
                let answer: String? = DateToLetterCountdown(date: expireDateAftAcpt)
                
                if let answer = answer{
                    
                    paymentReceiveAt.text = "\(answer) hours left to post all to Instagram"
                    
                }else{
                    paymentReceiveAt.text = ""
                    self.timer?.invalidate()
                }
                
            }
        }
        
    }
    
    func setInprogressValue(currentDate: Date, expireDateAftAcpt: Date, offerAcceptedDate: Date) {
        
        //Interval between Offer Acceted Date and Current Date
        let intervalBtnOffActDateToCurDate = (currentDate.timeIntervalSince1970 - offerAcceptedDate.timeIntervalSince1970)
        
        //Interval between Offer Acceted Date and expiring offer after Accepted Offer
        let intervalBtnOffActDateToOfferExpDate = (expireDateAftAcpt.timeIntervalSince1970 - offerAcceptedDate.timeIntervalSince1970)
                                    
            print("after=",intervalBtnOffActDateToOfferExpDate)
             print("before",intervalBtnOffActDateToCurDate)
             
             
            //Calculate Progress How long days gone after accepting the offer
            // progressWidth.constant = CGFloat(intervalBtnOffActDateToCurDate/intervalBtnOffActDateToOfferExpDate) * self.frame.size.width
                
            print(CGFloat(intervalBtnOffActDateToOfferExpDate/intervalBtnOffActDateToCurDate))
                print(self.frame.size.width)
            progressWidth.constant = (CGFloat(intervalBtnOffActDateToOfferExpDate/intervalBtnOffActDateToCurDate) * self.frame.size.width) - self.frame.size.width

             progrssView.updateConstraints()
             progrssView.layoutIfNeeded()
             
             progrssView.backgroundColor = UIColor.systemBlue
             
             
        
    }
    
    @IBAction func startCountDownForTobepaid(sender: Timer){
        
        let offerValue = self.offer!
        
        if offerValue.status == "verified"{
            
            if let offerPostedDate = offerValue.updatedDate{
                
                let expireDateAftPosted = offerPostedDate.afterDays(day: 2)
                
                let answer: String? = DateToLetterCountdownWithFormat(date: expireDateAftPosted, format: "hh:mm:ss")
                
                if  answer == "0:00"{
                    paymentReceiveAt.text = ""
                    self.timer?.invalidate()
                    
                }else{
                    paymentReceiveAt.text = "Payment in \(answer!)"
                }
                
            }
            
        }
        
    }
    
    @IBAction func startCountDownForTobeapproved(sender: Timer){
        
        let offerValue = self.offer!
        
        if offerValue.status == "posted"{
            
            if let offerPostedDate = offerValue.updatedDate{
                
                let expireDateAftPosted = offerPostedDate.afterDays(day: 2)
                
                let answer: String? = DateToLetterCountdownWithFormat(date: expireDateAftPosted, format: "hh:mm:ss")
                
                if  answer == "0:00"{
                    paymentReceiveAt.text = ""
                    self.timer?.invalidate()
                    
                }else{
                    paymentReceiveAt.text = "Post will be verified in \(answer!)"
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



class InProgressVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allInprogressOffer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "inprogresscell"
        let cell = inProgressTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! InProgressTVC
        cell.offer = allInprogressOffer[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let offer = allInprogressOffer[indexPath.row]
        self.performSegue(withIdentifier: "FromInprogressToOV", sender: offer)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return rowHeight.returnRowHeight(count: allInprogressOffer[indexPath.row].posts.count).rawValue
    }
    
    @IBOutlet weak var inProgressTable: UITableView!
    
    var allInprogressOffer = [Offer]()
    
    var offervariation: OfferVariation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		inProgressTable.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.tabBarController?.tabBar.items![3].badgeValue = nil
        if global.allInprogressOffer.count == 0{
        getAcceptedOffers { (status, offers) in
            
            if status{
                self.allInprogressOffer.removeAll()
                self.allInprogressOffer.append(contentsOf: offers)
                global.allInprogressOffer = offers
                DispatchQueue.main.async {
                    self.inProgressTable.reloadData()
                }
            }
            
        }
        }else{
            self.allInprogressOffer.removeAll()
            self.allInprogressOffer = global.allInprogressOffer
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
        
            destination.offerVariation = .inProgress
            destination.offer = sender as? Offer
         }
        
    }
    

}
