//
//  NewViewInProgressVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/10/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewViewInProgressVC: UIViewController {

	@IBOutlet weak var scrollView: UIScrollView!
	
	//business view
	@IBOutlet weak var businessView: ShadowView!
	@IBOutlet weak var businessLogoImage: ShadowView!
	@IBOutlet weak var businessName: UILabel!
	@IBOutlet weak var moneyLabel: UILabel!
	@IBOutlet weak var moneyView: ShadowView!
	
	//Orb View / Time left view.
	@IBOutlet weak var orbView: ShadowView!
	@IBOutlet var orbs: [UIView]!
	@IBOutlet weak var orbStack: UIStackView!
	@IBOutlet weak var missionLabel: UILabel!
	@IBOutlet weak var timeLeftLabel: UILabel!
	let radarView: UIView = UIView()
	var isDoingAnimations = false
	
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
	
	//cancel post view.
	@IBOutlet weak var cancelPostView: ShadowView!
	@IBOutlet weak var cancelPostButton: UIButton!
	
	var thisInProgressPost: InProgressPost!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		scrollView.alwaysBounceVertical = false
		orbs.sort{$0.tag > $1.tag}
		updateConents()
    }
	
	@IBAction func closeButtonPressed(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func postCancelled(_ sender: Any) {
		
	}
	
	@IBAction func createCaption(_ sender: Any) {
		
	}
	
	@IBAction func ViewBusiness(_ sender: Any) {
		
	}
	
	func updateOrbView() {
		
	}
	
	func updateConents() {
		
		
		//STATUS: Accepted, Cancelled, Expired, Posted, Verified, Rejected, Paid.
		
		//View Name							//Statuses that will show this view							//code to check status.
		statusView.isHidden = 				!["Posted", "Verified", "Rejected", "Cancelled"]			.contains(thisInProgressPost.status)
		didntPostInTimeView.isHidden = 		!["Expired"]												.contains(thisInProgressPost.status)
		mainInstructionsView.isHidden = 	!["Accepted"]												.contains(thisInProgressPost.status)
		businessInstructionsView.isHidden = !["Accepted"]												.contains(thisInProgressPost.status)
		captionRequirementsView.isHidden = 	!["Accepted"]												.contains(thisInProgressPost.status)
		youHaveBeenPaidView.isHidden = 		!["Paid"]													.contains(thisInProgressPost.status)
		cancelPostView.isHidden = 			!["Accepted", "Posted", "Verified"]							.contains(thisInProgressPost.status)
		
		updateOrbStatus()
	}
	
}

extension NewViewInProgressVC {
	
	func viewToFrame(_ view: UIView) -> CGRect {
		var newView: CGRect!
		newView = orbStack.convert(view.frame, to: self.view)
		
		return newView
	}
	
	func updateOrbStatus() {
		switch thisInProgressPost.status {
		
		case "Accepted":
						
			makeViewColorUpTo(upToIndex: 0, filledColor: .systemGreen, otherColor: .systemGray)
			timeLeftLabel.text = "Time left to post"
			timeLeftLabel.text = ""
			moneyView.backgroundColor = .systemGreen
			setTimeLeftToPost()
			setRadar(toRect: viewToFrame(orbs[0]), color: .systemGreen)
			
		case "Posted":
			makeViewColorUpTo(upToIndex: 4, filledColor: .systemBlue, otherColor: .systemGray)
			missionLabel.text = "If post is verified, you will be paid in"
			moneyView.backgroundColor = .systemGreen
			setPaidInLabel()
			setRadar(toRect: viewToFrame(orbs[4]), color: .systemBlue)
			
		case "Verified":
			makeViewColorUpTo(upToIndex: 8, filledColor: .systemGreen, otherColor: .systemGray)
			missionLabel.text = "You will be paid in"
			moneyView.backgroundColor = .systemGreen
			setPaidInLabel()
			setRadar(toRect: viewToFrame(orbs[8]), color: .systemGreen)
			
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
			print("IMPOSSIBLE STATUS : \(thisInProgressPost.status)")
		}
	}
	
	func setPaidInLabel() {
		if let stamp = thisInProgressPost.instagramPost?.timestamp {
			let calendar = Calendar.current
			let postBy = calendar.date(byAdding: .hour, value: 48, to: stamp)!
			
			setTimeLeft(to: postBy)
		} else {
			timeLeftLabel.text = "Post was deleted."
		}
	}
	
	func setTimeLeftToPost() {
		let calendar = Calendar.current
		let postBy = calendar.date(byAdding: .hour, value: 48, to: thisInProgressPost.dateAccepted)!
		
		setTimeLeft(to: postBy)
	}
	
	func setRadar(toRect: CGRect, color: UIColor) {
		if !isDoingAnimations {
			view.addSubview(radarView)
			view.bringSubviewToFront(radarView)
		}
		radarView.frame = toRect
		radarView.backgroundColor = color
		radarView.layer.cornerRadius = [radarView.bounds.width, radarView.bounds.height].min()! / 2
		radarView.isHidden = false
		if !isDoingAnimations {
			isDoingAnimations = true
			doRadarAnimation()
		}
	}
	
	
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

	func removeRadar() {
		radarView.isHidden = true
	}
	
	func setTimeLeft(to: Date) {
		let calendar = Calendar.current
		let diff = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: to)
		let realHours = ((diff.day ?? 0) * 24) + (diff.hour ?? 0)
		timeLeftLabel.text = "\(realHours):\(makeSure2Long(value: diff.minute)):\(makeSure2Long(value: diff.second))"
	}
	
	func makeViewColorUpTo(upToIndex: Int, filledColor: UIColor, otherColor: UIColor) {
		for i in 0...upToIndex {
			orbs[i].backgroundColor = filledColor
		}
		if upToIndex < orbs.count - 1 {
			for i in (upToIndex + 1)...(orbs.count - 1) {
				orbs[i].backgroundColor = otherColor
			}
		}
	}
	
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
