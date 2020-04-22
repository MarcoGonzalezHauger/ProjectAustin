//
//  OfferViewerVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 16/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

enum postRowHeight: CGFloat {
    case one = 133, two = 228, three = 323
    
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
                                
                            }
                            
                        }
                        
                    }
        }
        }
    }
    
    func setInfluencerAmount(offerValue: Offer) {
        
        var postedCount = 0

        for post in offerValue.posts {
            if post.status == "posted"{
               postedCount += 1
            }
        }
        
        if let incresePay = offerValue.incresePay {
            
            let pay = calculateCostForUser(offer: offerValue, user: Yourself, increasePayVariable: incresePay)
            let totalAmt = (pay/Double(postedCount))
            self.amtText.text = NumberToPrice(Value: totalAmt)
            
        }else{
            
            let pay = calculateCostForUser(offer: offerValue, user: Yourself)
            let totalAmt = (pay/Double(postedCount))
            self.amtText.text = NumberToPrice(Value: totalAmt)
        }
        
    }
    
    
    func setPaidAmount(offerValue: Offer) {
        
        var postedCount = 0

        for post in offerValue.posts {
            if post.status == "paid"{
               postedCount += 1
            }
        }
        
        if let incresePay = offerValue.incresePay {
            
            let pay = calculateCostForUser(offer: offerValue, user: Yourself, increasePayVariable: incresePay)
            let totalAmt = (pay/Double(postedCount))
            self.amtText.text = NumberToPrice(Value: totalAmt)
            
        }else{
            
            let pay = calculateCostForUser(offer: offerValue, user: Yourself)
            let totalAmt = (pay/Double(postedCount))
            self.amtText.text = NumberToPrice(Value: totalAmt)
        }
        
    }
    
    @objc func timerForWillPaidCell(sender: Timer){
    

        let answer: String? = DateToLetterCountdownWithFormat(date: self.updatedDate!, format: "")

        if let answer = answer{

        leftTimeText.text = "You will be paid in \(answer)"

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
    var timer: Timer?
    
    var timerSeconds: Double = 0.0
    
    var offer: Offer?{
        didSet{
            if let offerValue = offer{
                
                if self.timer != nil{
                   timer!.invalidate()
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
                                
                                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerForReservedCell(sender:)), userInfo: nil, repeats: true)
                                
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
            
        let answer: String? = DateToLetterCountdownWithFormat(date1: curDate!,date2: date, format: "")
        
        if let answer = answer{
            
            timeText.text = answer
            
        }
        
    }
            
        }else{
            self.timer?.invalidate()
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
    
    var offer: Offer?{
        didSet{
            if let offerValue = offer{
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

class WarnUser: UITableViewCell {
    @IBOutlet weak var alertMessage: UILabel!
    
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
                    self.cmpImage.image = defaultImage
                }
                
                self.cmpName.text = company.name
            }
        }
    }
    
}

class PostInfoCell: UITableViewCell {
    @IBOutlet weak var postSerial: UILabel!
    @IBOutlet weak var postName: UILabel!
    @IBOutlet weak var postDesImg: UIImageView!
    @IBOutlet weak var postDes: UILabel!
    @IBOutlet weak var shadow: ShadowView!
    

}

class PostDetailCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offer!.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "postsInfo"
        var cell = postList.dequeueReusableCell(withIdentifier: identifier) as? PostInfoCell
        
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("PostInfoCell", owner: self, options: nil)
            cell = nib![0] as? PostInfoCell
        }
        
        let post = offer!.posts[indexPath.row]
        
        if indexPath.row == 0 {
            
            cell!.shadow.backgroundColor = UIColor.systemBlue
            let postIdentify = postStatus.returnImageStatus(status: post.status)
            cell!.postSerial.text = "1"
            cell!.postName.text = "Post 1"
            cell!.postDes.text = "Post 1" + "(\(postIdentify.0.rawValue))"
            cell!.postDesImg.image = UIImage.init(named: postIdentify.1)
            
        }else if indexPath.row == 1{
            
            cell!.shadow.backgroundColor = UIColor.systemRed
            let postIdentify = postStatus.returnImageStatus(status: post.status)
            cell!.postSerial.text = "2"
            cell!.postName.text = "Post 2"
            cell!.postDes.text = "Post 2" + "(\(postIdentify.0.rawValue))"
            cell!.postDesImg.image = UIImage.init(named: postIdentify.1)
            
        }else{
            
            cell!.shadow.backgroundColor = UIColor.systemYellow
            let postIdentify = postStatus.returnImageStatus(status: post.status)
            cell!.postSerial.text = "3"
            cell!.postName.text = "Post 3"
            cell!.postDes.text = "Post 3" + "(\(postIdentify.0.rawValue))"
            cell!.postDesImg.image = UIImage.init(named: postIdentify.1)
            
        }
        return cell!
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
    
    @IBOutlet weak var postList: UITableView!
    @IBOutlet weak var widthLayout: NSLayoutConstraint!
    
    var offer: Offer?{
        didSet{
            if let offerDetail = offer{
                if offerDetail.posts.count == 3 {
                    widthLayout.constant = 285.0
                    
                    postList.updateConstraints()
                    postList.layoutIfNeeded()
                    
                    
                }else if offerDetail.posts.count == 2{
                    widthLayout.constant = 190
                    postList.updateConstraints()
                    postList.layoutIfNeeded()
                }else{
                    widthLayout.constant = 90
                    postList.updateConstraints()
                    postList.layoutIfNeeded()
                }
                self.postList.reloadData()
                
            }
        }
    }
    
    
    override func awakeFromNib() {
        self.postList.register(UINib.init(nibName: "PostInfoCell", bundle: nil), forCellReuseIdentifier: "postcell")
    }
}

enum OfferVariation {
    case canBeAccepted, canNotBeAccepted, inProgress, didNotPostInTime, willBePaid, hasBeenPaid, allPostsDenied
    
    static func getOfferVariation(status: String) -> OfferVariation{
        switch status {
        case "accepted":
            return .inProgress
        case "expired":
            return .didNotPostInTime
        case "posted":
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

class OfferViewerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
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
        cell!.alertMessage.text = "You cannot accept this offer"
        return cell!
            
        }else if indexPath.row == 1{
            
        let identifier = "postsInfo"
        var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? PostDetailCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("PostDetailCell", owner: self, options: nil)
            cell = nib![0] as? PostDetailCell
        }
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
        cell!.offer = self.offer!
        return cell!
                
        }else if indexPath.row == 1{
        
        let identifier = "moneyInfo"
        var cell  = offerViewTable.dequeueReusableCell(withIdentifier: identifier) as? OfferMoneyTVC
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("OfferMoneyTVC", owner: self, options: nil)
            cell = (nib![0] as? OfferMoneyTVC)!
        }
        
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
            cell!.offer = offer!
            return cell!
        }else{
            let identifier = "acceptButton"
            let cell = offerViewTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! AcceptCell
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
            cell!.offer = offer!
            return cell!
                
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
            cell!.offer = offer!
            return cell!
            }
        }else{
            let identifier = "allPostsDenied"
            let cell = offerViewTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RejectedMessageCell
            return cell
        }
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
        }else if self.offerVariation! == .willBePaid {
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
    
    @IBOutlet weak var offerViewTable: UITableView!
    
    var offerVariation: OfferVariation?
    
    var offer: Offer?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.offerVariation == .canBeAccepted {
            
            self.offerViewTable.dataSource = self
            self.offerViewTable.delegate = self
            
            if !(self.offer!.reservedUsers!.keys.contains(Yourself.id)){
                
                let dateString = Date.getStringFromDate(date: Date().addMinutes(minute: 5))
                if let dateOne = Date.getDateFromString(date: dateString!){
                    print("vvv=",Date.getStringFromDate(date: Date()) as Any)
                    print("vvv1=",Date.getDateFromString(date: Date.getStringFromDate(date: Date())!) as Any)
                    print(dateOne)
                }
                
//                let dateString = Date.getStringFromIso8601Date(date: Date().addMinutes(minute: 5))
//                let dateOne = Date.getDateFromISO8601WOString(ISO8601String: dateString)
//
//                let cd = Date.getStringFromIso8601Date(date: Date())
//                    print("vvv=",Date.getStringFromIso8601Date(date: Date()))
//
//                    print("vvv1=",Date.getDateFromISO8601WOString(ISO8601String: cd))
//                    print(dateOne)
                
                self.offer!.reservedUsers![Yourself.id] = ["isReserved":true as AnyObject,"isReservedUntil":dateString as AnyObject]
                updateReservedOfferStatus(offer: self.offer!)
                
                if let incresePay = self.offer!.incresePay {
                    
                    let pay = calculateCostForUser(offer: self.offer!, user: Yourself, increasePayVariable: incresePay)
                    let cash = (self.offer!.cashPower! - pay - (self.offer!.commission! * self.offer!.cashPower!))
                    self.offer!.cashPower = cash
                    updateCashPower(cash: cash, offer: self.offer!)
                    
                }else{
                    
                    let pay = calculateCostForUser(offer: self.offer!, user: Yourself)
                    let cash = (self.offer!.cashPower! - pay - (self.offer!.commission! * self.offer!.cashPower!))
                    self.offer!.cashPower = cash
                    updateCashPower(cash: cash, offer: self.offer!)
                }
                
            }
            
//            if self.offer?.isReserved == false{
//                self.offer!.isReserved = true
//                self.offer!.isReservedUntil = Date.getStringFromDate(date: Date().addMinutes(minute: 5))
//                updateReservedOfferStatus(offer: self.offer!)
//            }
            self.offerViewTable.reloadData()
            
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
