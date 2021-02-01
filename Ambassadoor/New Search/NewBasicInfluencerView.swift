//
//  NewBasicInfluencerView.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/29/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import UIKit

class NewBasicInfluencerView: UIViewController, publicDataRefreshDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FollowerButtonDelegete {
	
	func isFollowingChanged(sender: AnyObject, newValue: Bool) {
		didJustFollow = true
		if newValue {
			thisInfluencer.Follow(as: Myself)
		} else {
			thisInfluencer.Unfollow(as: Myself)
		}
	}
	
	
	func publicDataRefreshed(userOrBusinessId: String) {
		if userOrBusinessId == thisInfluencer.userId {
			for i in globalBasicInfluencers {
				if i.userId == thisInfluencer.userId {
					thisInfluencer = i
					loadBasicInfluencerInfo()
					break
				}
			}
		}
	}
	
	
	@IBOutlet weak var backProfileImage: UIImageView!
	@IBOutlet weak var frontProfileImage: UIImageView!
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var executiveBadge: UIImageView!
	@IBOutlet weak var verifiedBadge: UIImageView!
	
	@IBOutlet weak var averageLikesLabel: UILabel!
	@IBOutlet weak var followerCountLabel: UILabel!
	@IBOutlet weak var engagmentRateLabel: UILabel!
	
	@IBOutlet weak var interestCollectionView: UICollectionView!
	
	@IBOutlet weak var scrollView: UIScrollView!
	
	@IBOutlet weak var followButton: FollowButtonRegular!
	
	@IBOutlet weak var instagrad: UIImageView!
	
	@IBOutlet weak var youVsThemAverageLikesLabel: UILabel!
	@IBOutlet weak var youVsThemAverageLikesView: ShadowView!
	@IBOutlet weak var youVsThemFollowersLabel: UILabel!
	@IBOutlet weak var youVsThemFollowersView: ShadowView!
	@IBOutlet weak var youVsThemEngagementRateLabel: UILabel!
	@IBOutlet weak var youVsThemEngagementRateView: ShadowView!
	
	@IBOutlet weak var youVsThemLabel: UILabel!
	@IBOutlet weak var youVsThemView: ShadowView!
	
	
	
	func CompressNumberWithPlus(number: Double) -> String {
		return (number > 0 ? "+" : "") + CompressNumber(number: number)
	}
	
	func LoadYouVsThem() {
		let likesDiff = Myself.basic.averageLikes - thisInfluencer.averageLikes
		let followersDiff = Myself.basic.followerCount - thisInfluencer.followerCount
		let engagementRate = Myself.basic.engagmentRate - thisInfluencer.engagmentRate
		
		let likesString = CompressNumberWithPlus(number: likesDiff)
		let followerString = CompressNumberWithPlus(number: followersDiff)
		let engagementString = engagmentRateInDetail(engagmentRate: engagementRate, enforceSign: true)
		
		youVsThemAverageLikesLabel.text = likesString
		youVsThemFollowersLabel.text = followerString
		youVsThemEngagementRateLabel.text = engagementString
		
		youVsThemAverageLikesView.borderColor = GetColorForNumber(number: likesDiff)
		youVsThemFollowersView.borderColor = GetColorForNumber(number: followersDiff)
		youVsThemEngagementRateView.borderColor = GetColorForNumber(number: Double(engagementRate))
	}
	
	func viewYouVsThemItem() {
		UseTapticEngine()
		performSegue(withIdentifier: "viewYouVsThemItem", sender: self)
	}
	
	@IBAction func dismiss(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	var didJustFollow = false
	
	var thisInfluencer: BasicInfluencer!
	
	
	@IBAction func openInstagramPage(_ sender: Any) {
		UseTapticEngine()
		let user = thisInfluencer.username
		
		let instaURL = URL(string: "instagram://user?username=\(user)")!
		let sharedApps = UIApplication.shared
		if sharedApps.canOpenURL(instaURL) {
			sharedApps.open(instaURL)
		} else {
			sharedApps.open(URL(string: "https://instagram.com/\(user)")!)
		}
	}
	
	func displayInfluencerId(userId: String) {
		for i in globalBasicInfluencers {
			if i.userId == userId {
				thisInfluencer = i
				break
			}
		}
	}
	
	@IBAction func averageLikesPressed(_ sender: Any) {
		stat1 = Myself.basic.averageLikes
		stat2 = thisInfluencer.averageLikes
		headingName = "Average Likes"
		viewYouVsThemItem()
	}
	
	@IBAction func followersPressed(_ sender: Any) {
		stat1 = Myself.basic.followerCount
		stat2 = thisInfluencer.followerCount
		headingName = "Followers"
		viewYouVsThemItem()
	}
	
	@IBAction func EngagementRatePressed(_ sender: Any) {
		stat1 = Myself.basic.engagmentRate
		stat2 = thisInfluencer.engagmentRate
		headingName = "Engagement Rate"
		viewYouVsThemItem()
	}
	
	var stat1: Double = 0
	var stat2: Double = 0
	var diff: Double {
		get {
			return stat1 - stat2
		}
	}
	var headingName: String = ""
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? YouVsThemViewerVC {
			view.stat1 = stat1
			view.stat2 = stat2
			view.difference = diff
			view.heading = headingName
		}
	}
	
	override func viewDidLoad() {
		scrollView.alwaysBounceVertical = false
		interestCollectionView.backgroundColor = .clear
		instagrad.layer.cornerRadius = 10
		
		let xib = UINib.init(nibName: "InterestCVC", bundle: Bundle.main)
		interestCollectionView.register(xib, forCellWithReuseIdentifier: "InterestCell")
		
		publicDataListeners.append(self)
		interestCollectionView.delegate = self
		interestCollectionView.dataSource = self
		
		followButton.isBusiness = false
		followButton.delegate = self
		
		loadBasicInfluencerInfo()
	}
	
	func loadBasicInfluencerInfo() {
		
		let thisIsMe = thisInfluencer.userId == Myself.userId
		
		backProfileImage.downloadAndSetImage(thisInfluencer.profilePicURL)
		frontProfileImage.downloadAndSetImage(thisInfluencer.profilePicURL)
		nameLabel.text = thisInfluencer.name
		executiveBadge.isHidden = !thisInfluencer.checkFlag("isAmbassadoorExecutive")
		verifiedBadge.isHidden = !thisInfluencer.checkFlag("isVerified")
		averageLikesLabel.text = NumberToStringWithCommas(number: thisInfluencer.averageLikes)
		followerCountLabel.text = NumberToStringWithCommas(number: thisInfluencer.followerCount)
		engagmentRateLabel.text = "\(thisInfluencer.engagmentRateInt)%"
		
		if !didJustFollow {
			followButton.isFollowing = thisInfluencer.followedBy.contains(Myself.userId)
		}
		
		interestCollectionView.reloadData()
		
		
		youVsThemLabel.isHidden = thisIsMe
		youVsThemView.isHidden = thisIsMe
		followButton.isHidden = thisIsMe
		if thisIsMe {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
				SetLabelText(label: self.nameLabel, text: "You", animated: true)
			}
		} else {
			LoadYouVsThem()
		}
	}
	
	var maxInterests = 10
	var rows = 2
	var spacingBetweenCells: CGFloat = 6
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return thisInfluencer.interests.count
	}
	
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestCell", for: indexPath) as! InterestCVC
		if indexPath.item < thisInfluencer.interests.count {
			cell.interest = thisInfluencer.interests[indexPath.item]
		} else {
			cell.interest = ""
		}
		cell.mainView.cornerRadius = globalCornerRadius
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let width = collectionView.bounds.width - (spacingBetweenCells * CGFloat(((maxInterests / rows) - 1)))
		let widthPer: CGFloat = CGFloat(width / CGFloat(maxInterests / rows))
		return CGSize(width: widthPer, height: widthPer)
		
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return spacingBetweenCells
	}

	func collectionView(_ collectionView: UICollectionView, layout
		collectionViewLayout: UICollectionViewLayout,
						minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return spacingBetweenCells
	}
	
}


