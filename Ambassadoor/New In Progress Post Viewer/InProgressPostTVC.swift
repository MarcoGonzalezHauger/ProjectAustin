//
//  InProgressPostTVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/5/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class InProgressPostTVC: UITableViewCell {

	var thisInProgressPost: InProgressPost!
	
    
    /// Update post orbView view contents
	func updateContents() {
		orbView.sort { (u1, u2) -> Bool in
			return u1.tag < u2.tag
		}
		for v in orbView {
//			v.backgroundColor = UIColor.init(red: CGFloat(Double(v.tag) / 12), green: 0, blue: 0, alpha: 1)
			v.layer.cornerRadius = [v.bounds.width, v.bounds.height].min()! / 2
		}
		if let bb = thisInProgressPost.BasicBusiness() {
			profilePicture.downloadAndSetImage(bb.logoUrl)
			nameLabel.text = bb.name
			moneyLabel.text = NumberToPrice(Value: thisInProgressPost.cashValue, enforceCents: true)
		}
		updateStatus()
		timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (tmr) in
			self.updateStatus()
		})
		RunLoop.current.add(timer, forMode: .common)
	}
	
	var timer: Timer!
	let radarView: UIView = UIView.init()
	
	func viewToFrame(_ view: UIView) -> CGRect {
		var newView: CGRect!
		newView = orbStack.convert(view.frame, to: self)
		
		return newView
	}
	
	@IBOutlet weak var orbStack: UIStackView!
	@IBOutlet weak var acceptedOrb: UIView!
	@IBOutlet weak var PostedOrb: UIView!
	@IBOutlet weak var verifiedOrb: UIView!
	@IBOutlet weak var paidOrb: UIView!
	
    
    /// Update status content based on post status
	func updateStatus() {
		switch thisInProgressPost.status {
		
		case "Accepted":
						
			makeViewColorUpTo(upToIndex: 0, filledColor: .systemGreen, otherColor: .systemGray)
			currentMission.text = "Time left to post (checks every hour)"
			timeLeftLabel.text = ""
			moneyView.backgroundColor = .systemGreen
			setTimeLeftToPost()
			setRadar(toRect: viewToFrame(acceptedOrb), color: .systemGreen)
			
		case "Posted":
			makeViewColorUpTo(upToIndex: 4, filledColor: .systemBlue, otherColor: .systemGray)
			currentMission.text = "If post is verified, you will be paid in"
			moneyView.backgroundColor = .systemGreen
			setPaidInLabel()
			setRadar(toRect: viewToFrame(PostedOrb), color: .systemBlue)
			
		case "Verified":
			makeViewColorUpTo(upToIndex: 8, filledColor: .systemGreen, otherColor: .systemGray)
			currentMission.text = "You will be paid in"
			moneyView.backgroundColor = .systemGreen
			setPaidInLabel()
			setRadar(toRect: viewToFrame(verifiedOrb), color: .systemGreen)
			
		case "Paid":
			makeViewColorUpTo(upToIndex: 12, filledColor: .systemYellow, otherColor: .systemGray)
			currentMission.text = "Withdraw in the Profile tab."
			timeLeftLabel.text = "You have been Paid"
			moneyView.backgroundColor = .systemGreen
			removeRadar()
			
		case "Rejected":
			makeViewColorUpTo(upToIndex: 8, filledColor: .systemRed, otherColor: .systemGray)
			currentMission.text = "Click to see why."
			timeLeftLabel.text = "Post Rejected"
			moneyView.backgroundColor = .systemRed
			removeRadar()
			
		case "Cancelled":
			makeViewColorUpTo(upToIndex: 12, filledColor: .systemRed, otherColor: .systemGray)
			currentMission.text = "You cancelled this post."
			timeLeftLabel.text = "Cancelled"
			moneyView.backgroundColor = .systemRed
			removeRadar()
			
		case "Expired":
			makeViewColorUpTo(upToIndex: 4, filledColor: .systemRed, otherColor: .systemGray)
			currentMission.text = "You didn't post in time."
			timeLeftLabel.text = "Post Expired"
			moneyView.backgroundColor = .systemRed
			removeRadar()
			
		default:
			print("IMPOSSIBLE STATUS : \(thisInProgressPost.status)")
		}
	}
	
    
    /// Update paid post content
	func setPaidInLabel() {
		//if let stamp = thisInProgressPost.instagramPost?.timestamp {
        if let stamp = thisInProgressPost.datePosted {
			let calendar = Calendar.current
			let postBy = calendar.date(byAdding: .hour, value: 48, to: stamp)!
            
            if Date() > postBy {
                currentMission.text = "There has been a server error."
                timeLeftLabel.text = "You will be paid as soon as possible"
            }else{
                setTimeLeft(to: postBy)
            }
			
			
		} else {
			currentMission.text = "Failed"
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
	func setRadar(toRect: CGRect, color: UIColor) {
		if !isDoingAnimations {
			self.addSubview(radarView)
			self.bringSubviewToFront(radarView)
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
	
	var isDoingAnimations = false
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
		for i in 0...upToIndex {
			orbView[i].backgroundColor = filledColor
		}
		if upToIndex < orbView.count - 1 {
			for i in (upToIndex + 1)...(orbView.count - 1) {
				orbView[i].backgroundColor = otherColor
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
	
	@IBOutlet weak var profilePicture: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var moneyLabel: UILabel!
	
	@IBOutlet weak var currentMission: UILabel!
	@IBOutlet weak var timeLeftLabel: UILabel!
	@IBOutlet weak var moneyView: ShadowView!
	
	@IBOutlet var orbView: [UIView]! //Big Ones: 0, 4, 8, 12 – This list is just all the circle views that light up.
	
}
