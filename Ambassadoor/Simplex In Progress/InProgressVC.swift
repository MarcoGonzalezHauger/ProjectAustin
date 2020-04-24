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
                    self.companyLogo.image = defaultImage
                }
                
                if let incresePay = offerValue.incresePay {
                    
                    let pay = calculateCostForUser(offer: offerValue, user: Yourself, increasePayVariable: incresePay)
                    
                    self.amount.text = NumberToPrice(Value: pay)
                    
                }else{
                    
                    let pay = calculateCostForUser(offer: offerValue, user: Yourself)
                    self.amount.text = NumberToPrice(Value: pay)
                }
                
                self.name.text = offerValue.company!.name
                self.setTextandConstraints(offerValue: offerValue)
                
                if offerValue.status == "accepted"{
                    if let offerAcceptedDate = offerValue.updatedDate{
                        
                        let dayCount = offerValue.posts.count * 2
                        let expireDateAftAcpt = offerAcceptedDate.afterDays(day: dayCount)
                        
                        //Interval between Offer Acceted Date and Current Date
                        let intervalBtnOffActDateToCurDate = (Date().timeIntervalSince1970 - offerAcceptedDate.timeIntervalSince1970)
                        
                        //Interval between Offer Acceted Date and expiring offer after Accepted Offer
                        let intervalBtnOffActDateToOfferExpDate = (expireDateAftAcpt.timeIntervalSince1970 - offerAcceptedDate.timeIntervalSince1970)
                        
                        print("after=",intervalBtnOffActDateToOfferExpDate)
                        print("before",intervalBtnOffActDateToCurDate)
                        
                        
                       //Calculate Progress How long days gone after accepting the offer
                        progressWidth.constant = CGFloat(intervalBtnOffActDateToCurDate/intervalBtnOffActDateToOfferExpDate) * self.frame.size.width

                        progrssView.updateConstraints()
                        progrssView.layoutIfNeeded()
                        
                        progrssView.backgroundColor = UIColor.systemBlue
                        
                        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startCountDownForAccepted(sender:)), userInfo: nil, repeats: true)
                        
                        //Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startCountDownForTobepaid(sender:)), userInfo: nil, repeats: true)
                        
                    }
                }else if offerValue.status == "posted" {
                    
                    if let offerAcceptedDate = offerValue.updatedDate{
                        
                        let expireDateAftPosted = offerAcceptedDate.afterDays(day: 2)
                        
                        let intBtnNowandPosted = (expireDateAftPosted.timeIntervalSince1970 - Date().timeIntervalSince1970)
                        
                        let intAftTwoDays = (expireDateAftPosted.timeIntervalSince1970 - offerAcceptedDate.timeIntervalSince1970)
                        
                        progressWidth.constant = CGFloat(intBtnNowandPosted/intAftTwoDays) * self.frame.size.width

                        progrssView.updateConstraints()
                        progrssView.layoutIfNeeded()
                        
                        progrssView.backgroundColor = UIColor.systemGreen
                        
                        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.startCountDownForTobepaid(sender:)), userInfo: nil, repeats: true)
                        
                    }
                    
                }
                
                
                
            }
        }
    }
    
    @IBAction func startCountDownForAccepted(sender: Timer) {
        
        
        let offerValue = self.offer!
        
        if offerValue.status == "accepted"{
            
            if let offerAcceptedDate = offerValue.updatedDate{
                
                let dayCount = offerValue.posts.count * 2
                let expireDateAftAcpt = offerAcceptedDate.afterDays(day: dayCount)
                
                let answer: String? = DateToLetterCountdown(date: expireDateAftAcpt)
                
                if let answer = answer{
                    
                    paymentReceiveAt.text = "\(answer) hours left to post all to Instagram"
                    
                }
                
            }
        }
        
    }
    
    @IBAction func startCountDownForTobepaid(sender: Timer){
        
        let offerValue = self.offer!
        
        if offerValue.status == "accepted"{
            
            if let offerPostedDate = offerValue.updatedDate{
                
                let expireDateAftPosted = offerPostedDate.afterDays(day: 2)
                
                let answer: String? = DateToLetterCountdownWithFormat(date: expireDateAftPosted, format: "hh:mm:ss")
                
                if let answer = answer{
                    
                    paymentReceiveAt.text = "Payment in \(answer)"
                    
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
    case one = 144, two = 172, three = 200
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return rowHeight.returnRowHeight(count: allInprogressOffer[indexPath.row].posts.count).rawValue
    }
    
    @IBOutlet weak var inProgressTable: UITableView!
    
    var allInprogressOffer = [Offer]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.tabBarController?.tabBar.items![3].badgeValue = nil
        getAcceptedOffers { (status, offers) in
            
            if status{
                self.allInprogressOffer.removeAll()
                self.allInprogressOffer.append(contentsOf: offers)
                DispatchQueue.main.async {
                    self.inProgressTable.reloadData()
                }
            }
            
        }
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
