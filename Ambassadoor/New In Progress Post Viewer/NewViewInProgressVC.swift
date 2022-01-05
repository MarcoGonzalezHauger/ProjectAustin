//
//  NewViewInProgressVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/10/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewViewInProgressVC: UIViewController, myselfRefreshDelegate {
    
    /// Refresh post details if any changes updated in firebase
    func myselfRefreshed() {
		print("did refresh")
        for ip in Myself.inProgressPosts {
            if ip.inProgressPostId == thisInProgressPost.inProgressPostId {
                thisInProgressPost = ip
				print("did update contents")
                updateContents()
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //business view
    @IBOutlet weak var businessView: ShadowView!
    @IBOutlet weak var businessProfile: UIImageView!
    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var businessLogoImage: ShadowView!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var moneyView: ShadowView!
    
    //Orb View / Time left view.
    @IBOutlet weak var orbView: ShadowView!
    @IBOutlet var orbs: [UIView]!
    @IBOutlet weak var orbStack: UIStackView!
    @IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
	@IBOutlet weak var acceptedOrb: UIView!
	@IBOutlet weak var postedOrb: UIView!
	@IBOutlet weak var verifiedOrb: UIView!
	@IBOutlet weak var paidOrb: UIView!
	let radarView: UIView = UIView()
    var isDoingAnimations = false
	var timer: Timer!
    
    //status view
    @IBOutlet weak var statusView: ShadowView!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var statusDescriptionLabel: UILabel!
    
    //didn't post in time.
    @IBOutlet weak var didntPostInTimeView: ShadowView!
    
    //Main Instructions.
    @IBOutlet weak var mainInstructionsView: ShadowView!
    
    //instructions from business
    @IBOutlet weak var businessInstructionsView: ShadowView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    //Caption requirements
    @IBOutlet weak var captionRequirementsView: ShadowView!
    @IBOutlet weak var captionLabel: UILabel!
    
    //You have been paid view.
    @IBOutlet weak var youHaveBeenPaidView: ShadowView!
    @IBOutlet weak var paidAmountLabel: UILabel!
	@IBOutlet weak var transferLabel: UILabel!
	
    //cancel post view.
    @IBOutlet weak var cancelPostView: ShadowView!
    @IBOutlet weak var cancelPostButton: UIButton!
    
	//Redeem Gift Card Button
	@IBOutlet weak var redeemGC: ShadowView!
	
	var thisInProgressPost: InProgressPost!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //scrollView.alwaysBounceVertical = false
        orbs.sort{$0.tag < $1.tag}
        myselfRefreshListeners.append(self)
        updateContents()
    }
    
    
    /// Dismiss current view controller
    /// - Parameter sender: UIButton referrance
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    /// Cancel post and update changes to firebase
    /// - Parameter sender: UIButton referrance
    @IBAction func postCancelled(_ sender: Any) {
		
		let alert = UIAlertController(title: "Cancel Post – This action cannot be undone.", message: "", preferredStyle: .actionSheet)
		
			
		
		let action = UIAlertAction.init(title: "Cancel Post", style: .destructive) { (_) in
			self.thisInProgressPost.cancelPost()
            for i in 0...(Myself.inProgressPosts.count - 1) {
                if Myself.inProgressPosts[i].inProgressPostId == self.thisInProgressPost.inProgressPostId {
                    self.cancelPostButton.isEnabled = false
                    Myself.inProgressPosts[i] = self.thisInProgressPost
                    let filtersPool = offerPool.filter { offer in
                        return offer.poolId == self.thisInProgressPost.PoolOfferId
                    }
                    if let offer = filtersPool.first{
                        print("cP =",self.thisInProgressPost.cashValue)
                        offer.cashPower += self.thisInProgressPost.cashValue
                        print("cP =",offer.cashPower)
                        offer.UpdateToFirebase { error in
                        }
                    }
                    Myself.UpdateToFirebase(alsoUpdateToPublic: false, completed: nil)
                }
            }
            /*
			for i in 0...(Myself.inProgressPosts.count - 1) {
				if Myself.inProgressPosts[i].inProgressPostId == self.thisInProgressPost.inProgressPostId {
					self.cancelPostButton.isEnabled = false
					Myself.inProgressPosts[i] = self.thisInProgressPost
					Myself.UpdateToFirebase(alsoUpdateToPublic: false, completed: nil)
				}
			}
             */
		}
		
		alert.addAction(action)
		
		let cancelAction = UIAlertAction.init(title: "Do Not Cancel", style: .cancel, handler: nil)
		
		alert.addAction(cancelAction)
		
		self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func createCaption(_ sender: Any) {
        
    }
    
    
    /// Filter post business id and segue to business view page
    /// - Parameter sender: UIButton referrance
    @IBAction func ViewBusiness(_ sender: Any) {
        
        print(thisInProgressPost.businessId)
        
        let basicBusinessInfo = globalBasicBusinesses.filter { (basicbusiness) -> Bool in
            return basicbusiness.businessId == thisInProgressPost.businessId
        }
        
        print("vvv=",basicBusinessInfo.first?.name as Any)
        
        if let basicData = basicBusinessInfo.first{
           self.performSegue(withIdentifier: "FromInprogressToBV", sender: basicData)
        }
    }
    
    
    /// Update status view contents
    func updateContents() {
        
        
        //STATUS: Accepted, Cancelled, Expired, Posted, Verified, Rejected, Paid.
        
        //View Name							//Statuses that will show this view							//code to check status.
        statusView.isHidden = !["Posted", "Verified", "Rejected","Cancelled"].contains(thisInProgressPost.status)
        didntPostInTimeView.isHidden = !["Expired"].contains(thisInProgressPost.status)
        mainInstructionsView.isHidden = !["Accepted"].contains(thisInProgressPost.status)
        businessInstructionsView.isHidden = !["Accepted"].contains(thisInProgressPost.status)
        captionRequirementsView.isHidden = !["Accepted"].contains(thisInProgressPost.status)
        youHaveBeenPaidView.isHidden = 	!["Paid"].contains(thisInProgressPost.status)
        cancelPostView.isHidden = !["Accepted", "Posted", "Verified"].contains(thisInProgressPost.status)
        
		if thisInProgressPost.checkFlag("xo case study") {
			moneyLabel.text = "$20 Gift Card"
		} else {
			moneyLabel.text = NumberToPrice(Value: thisInProgressPost.cashValue)
		}
		
        updateForStatus(status: thisInProgressPost.status)
        updateOrbStatus()
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (tmr) in
			self.updateOrbStatus()
		})
		RunLoop.current.add(timer, forMode: .common)
        updateBusinessDetails()
    }
    
    
    /// Update business details
    func updateBusinessDetails() {
        if let basic = thisInProgressPost.BasicBusiness() {
            self.businessProfile.downloadAndSetImage(basic.logoUrl)
            self.businessName.text = basic.name
        }
        
    }
	
	@IBOutlet weak var redeemButton: UIButton!
	
    
    /// Redeem action
    /// - Parameter sender: UIButton referrance
	@IBAction func redeemNow(_ sender: Any) {
		if thisInProgressPost.checkFlag("redeemed") {
			self.showStandardAlertDialog(title: "Already Redeemed", msg: "Gift card will soon be sent to " + Myself.email, handler: nil)
		} else {
			//redeeem now...
			
			performSegue(withIdentifier: "toRedeem", sender: self)
			
		}
	}
	
    
    /// Update redeem and post status views
    /// - Parameter status: post status
    func updateForStatus(status: String) {
		
		if thisInProgressPost.checkFlag("redeemed") {
			redeemGC.isHidden = false
			redeemButton.setTitle("Redeemed!", for: .normal)
			redeemGC.backgroundColor = .systemGreen
			
		} else {
			redeemGC.isHidden = !thisInProgressPost.checkFlag("xo case study")  || status != "Paid"
		}
		
		
		
        switch status {
            
        case "Accepted":
            //Main Instructions View: Nothing because isHideen was already done.
            
            //Caption Requirement
            captionLabel.text = thisInProgressPost.draftPost.getCaptionRequirementsViewable()
            
            //Business Instructions
            instructionsLabel.text = thisInProgressPost.draftPost.instructions
            
            
        case "Posted":
            
            //statusView as posted.
            statusTitleLabel.text = "Post was Detected"
            statusImage.image = UIImage.init(named: "postDetected")!
            statusImage.tintColor = .systemBlue
            statusDescriptionLabel.text = "Your Instagram post was detected.\nIt will now be reviewed."
            
            //cancel button already visible.
            
        case "Verified":
            
            //status view, cancel post
            statusTitleLabel.text = "Post was Verified"
            statusImage.image = UIImage.init(named: "postVerified2")!
            statusImage.tintColor = .systemGreen
            statusDescriptionLabel.text = "Your post was verified!"
            
        case "Paid":
			if thisInProgressPost.checkFlag("xo case study") {
				paidAmountLabel.text = "$20 Gift Card"
				transferLabel.text = "Redeem Now"
			} else {
				paidAmountLabel.text = "\(NumberToPrice(Value: thisInProgressPost.cashValue))"
			}
            
        case "Rejected":
            
            //status view.
            statusTitleLabel.text = "Post was Rejected"
            statusImage.image = UIImage.init(named: "postRejected2")!
            statusImage.tintColor = .systemRed
            statusDescriptionLabel.text = "Your post was rejected.\nREASON: " + thisInProgressPost.denyReason
            
        case "Cancelled":
            
            //status view.
            statusTitleLabel.text = "Post was Cancelled"
            statusImage.image = UIImage.init(named: "postCancelled")!
            statusImage.tintColor = .systemRed
            statusDescriptionLabel.text = "You cancelled this post\n\(thisInProgressPost.dateCancelled.toString(dateFormat: "HH:mm a MM/dd/yyyy"))"
            
            
        case "Expired":
            break //Didntpost in time already visible.
            
            
            
        default:
            fatalError("IMPOSSIBLE STATUS : \(status)")
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FromInprogressToBV"{
            let view = segue.destination as! ViewBusinessVC
            view.fromSearch = false
            view.basicBusinessDetails = (sender as! BasicBusiness)
            //view.delegate = self
        }
    }
    
}

extension NewViewInProgressVC {
    
    
    /// Convert radar view frame to parent UIView
    /// - Parameter view: radar view frame
    /// - Returns: new frame
    func viewToFrame(_ view: UIView) -> CGRect {
        var newView: CGRect!
		newView = orbView.superview!.convert(view.frame, to: self.view)
        
        return newView
    }
    
    
    /// Update post status contents and radar views
    func updateOrbStatus() {
        switch thisInProgressPost.status {
            
        case "Accepted":
            
            makeViewColorUpTo(upToIndex: 0, filledColor: .systemGreen, otherColor: .systemGray)
            missionLabel.text = "Time left to post"
            moneyView.backgroundColor = .systemGreen
            setTimeLeftToPost()
			setRadar(toRect: acceptedOrb, color: .systemGreen)
            
        case "Posted":
            makeViewColorUpTo(upToIndex: 4, filledColor: .systemBlue, otherColor: .systemGray)
            missionLabel.text = "If post is verified, you will be paid in"
            moneyView.backgroundColor = .systemGreen
            setPaidInLabel()
            setRadar(toRect: postedOrb, color: .systemBlue)
            
        case "Verified":
            makeViewColorUpTo(upToIndex: 8, filledColor: .systemGreen, otherColor: .systemGray)
            missionLabel.text = "You will be paid in"
            moneyView.backgroundColor = .systemGreen
            setPaidInLabel()
            setRadar(toRect: verifiedOrb, color: .systemGreen)
            
        case "Paid":
            makeViewColorUpTo(upToIndex: 12, filledColor: .systemYellow, otherColor: .systemGray)
            missionLabel.text = "Withdraw in the Profile tab."
            timeLeftLabel.text = "You have been Paid"
            moneyView.backgroundColor = .systemGreen
            removeRadar()
            
        case "Rejected":
            makeViewColorUpTo(upToIndex: 8, filledColor: .systemRed, otherColor: .systemGray)
            missionLabel.text = "Click to see why."
            timeLeftLabel.text = "Post Rejected"
            moneyView.backgroundColor = .systemRed
            removeRadar()
            
        case "Cancelled":
            makeViewColorUpTo(upToIndex: 12, filledColor: .systemRed, otherColor: .systemGray)
            missionLabel.text = "You cancelled this post."
            timeLeftLabel.text = "Cancelled"
            moneyView.backgroundColor = .systemRed
            removeRadar()
            
        case "Expired":
            makeViewColorUpTo(upToIndex: 4, filledColor: .systemRed, otherColor: .systemGray)
            missionLabel.text = "You didn't post in time."
            timeLeftLabel.text = "Post Expired"
            moneyView.backgroundColor = .systemRed
            removeRadar()
            
        default:
            fatalError("IMPOSSIBLE STATUS : \(thisInProgressPost.status)")
        }
    }
    
    func setPaidInLabel() {
        if let stamp = thisInProgressPost.datePosted {
            //if let stamp = thisInProgressPost.instagramPost?.timestamp {
            let calendar = Calendar.current
            let postBy = calendar.date(byAdding: .hour, value: 48, to: stamp)!
            if Date() > postBy {
                missionLabel.text = "There has been a server error."
                timeLeftLabel.text = "You will be paid as soon as possible"
            }else{
                setTimeLeft(to: postBy)
            }
            //setTimeLeft(to: postBy)
        } else {
			missionLabel.text = "Failed"
            timeLeftLabel.text = "Post was deleted."
        }
    }
    
    
    /// show time left to post
    func setTimeLeftToPost() {
        let calendar = Calendar.current
        let postBy = calendar.date(byAdding: .hour, value: 48, to: thisInProgressPost.dateAccepted)!
        
        setTimeLeft(to: postBy)
    }
    
    
    /// set radar view contents
    /// - Parameters:
    ///   - toRect: new frame
    ///   - color: radar view back ground color
    func setRadar(toRect: UIView, color: UIColor) {
        
		radarView.frame = toRect.bounds
        toRect.addSubview(radarView)
        radarView.backgroundColor = color
        radarView.layer.cornerRadius = [radarView.bounds.width, radarView.bounds.height].min()! / 2
        radarView.isHidden = false
        if !isDoingAnimations {
            isDoingAnimations = true
            doRadarAnimation()
        }
    }
    
    
    /// Radar view animation
    func doRadarAnimation() {
        let animation = CAKeyframeAnimation.init(keyPath: "transform.scale")
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = 2
        animation.values = [1,3]
        radarView.layer.add(animation, forKey: "scaleup")
        self.radarView.alpha = 0.6
        UIView.animate(withDuration: 2) {
            self.radarView.alpha = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.05) {
            self.doRadarAnimation()
        }
    }
    
    
    /// remove radar view
    func removeRadar() {
        radarView.isHidden = true
    }
    
    
    /// Time left to settle post
    /// - Parameter to: until date
    func setTimeLeft(to: Date) {
        let calendar = Calendar.current
        let diff = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: to)
        let realHours = ((diff.day ?? 0) * 24) + (diff.hour ?? 0)
        timeLeftLabel.text = "\(realHours):\(makeSure2Long(value: diff.minute)):\(makeSure2Long(value: diff.second))"
    }
    
    /// Change color based post status
    /// - Parameters:
    ///   - upToIndex: change colors to views up to particular index
    ///   - filledColor: filled color
    ///   - otherColor: other color
    func makeViewColorUpTo(upToIndex: Int, filledColor: UIColor, otherColor: UIColor) {
        //print(orbs.count)
		for i in 0...upToIndex {
            orbs[i].backgroundColor = filledColor
			//print("Coloring orb \(i) FILLED")
        }
        if upToIndex < orbs.count - 1 {
            for i in (upToIndex + 1)...(orbs.count - 1) {
                orbs[i].backgroundColor = otherColor
				//print("Coloring orb \(i) GRAY")
            }
        }
    }
    
    
    /// Round up date to meaningful
    /// - Parameter value: minutes or seconds
    /// - Returns: string
    func makeSure2Long(value: Int?) -> String {
        if let val = value {
            var str = String(val)
            if str.count == 1 {
                str = "0" + str
            }
            return str
        } else {
            return "00"
        }
    }
}
