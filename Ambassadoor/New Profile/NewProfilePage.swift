//
//  NewProfilePage.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/28/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewProfilePage: UIViewController, myselfRefreshDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	
	func myselfRefreshed() { //from MyselfRefreshDelegate
		loadFromMyself()
	}
	
	@IBOutlet var uniformShadowViews: [ShadowView]!
	@IBOutlet weak var backProfileImage: UIImageView!
	@IBOutlet weak var frontProfileImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var executiveBadge: UIImageView!
	@IBOutlet weak var verifiedBadge: UIImageView!
	@IBOutlet weak var averageLikesLabel: UILabel!
	@IBOutlet weak var followerCountLabel: UILabel!
	@IBOutlet weak var engagmentRateLabel: UILabel!
	
	@IBOutlet weak var referralCodeLabel: UILabel!
	@IBOutlet weak var balanceLabel: UILabel!
	@IBOutlet weak var transferView: ShadowView!
	@IBOutlet weak var transferButton: UIButton!
	
	@IBOutlet weak var zipCodeLabel: UILabel!
	@IBOutlet weak var townNameLabel: UILabel!
	
	@IBOutlet weak var genderLabel: UILabel!
	@IBOutlet weak var ageLabel: UILabel!
	
	@IBOutlet weak var interestCollectionView: UICollectionView!
	
	@IBOutlet weak var scrollView: UIScrollView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		let xib = UINib.init(nibName: "InterestCVC", bundle: Bundle.main)
		interestCollectionView.register(xib, forCellWithReuseIdentifier: "InterestCell")
		
		interestCollectionView.backgroundColor = .clear
		for sv in uniformShadowViews {
			sv.cornerRadius = globalCornerRadius
		}
		loadFromMyself()
		myselfRefreshListeners.append(self)
		interestCollectionView.delegate = self
		interestCollectionView.dataSource = self
		
		scrollView.alwaysBounceVertical = false
    }
	
	func loadFromMyself() {
		loadInfluencerInfo(influencer: Myself)
	}
	
	@IBAction func transferToBank(_ sender: Any) {
		
	}
	
	var isOnCopied = false
	
	@IBAction func copyRefferal(_ sender: Any) {
		if !isOnCopied {
			print("Copying referral code.")
			UseTapticEngine()
			let pasteboard = UIPasteboard.general
			pasteboard.string = Myself.basic.referralCode
			SetLabelText(label: referralCodeLabel, text: "Copied", animated: true)
			isOnCopied = true
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
				SetLabelText(label: self.referralCodeLabel, text: Myself.basic.referralCode, animated: true)
				self.isOnCopied = false
			}
		}
	}
	
	func loadInfluencerInfo(influencer i: Influencer) {
		backProfileImage.downloadAndSetImage(i.basic.profilePicURL)
		frontProfileImage.downloadAndSetImage(i.basic.profilePicURL)
		nameLabel.text = i.basic.name
		executiveBadge.isHidden = !i.basic.checkFlag("isAmbassadoorExecutive")
		verifiedBadge.isHidden = !i.basic.checkFlag("isVerified")
		averageLikesLabel.text = NumberToStringWithCommas(number: i.basic.averageLikes)
		followerCountLabel.text = NumberToStringWithCommas(number: i.basic.followerCount)
		engagmentRateLabel.text = "\(i.basic.engagmentRateInt)%"
		
		referralCodeLabel.text = "\(i.basic.referralCode)"
		balanceLabel.text = NumberToPrice(Value: i.finance.balance)
		if i.finance.balance == 0 {
			transferView.isHidden = true
		} else {
			transferView.isHidden = false
		}
		
		zipCodeLabel.text = i.basic.zipCode
		self.townNameLabel.isHidden = true
		GetTownName(zipCode: i.basic.zipCode) { (zipCodeData, zipCode) in
			DispatchQueue.main.async {
				if let zipCodeData = zipCodeData {
					self.townNameLabel.isHidden = false
					self.townNameLabel.text = zipCodeData.CityAndStateName
				} else {
					self.townNameLabel.isHidden = true
				}
			}
		}
		
		genderLabel.text = i.basic.gender
		
		ageLabel.text = "\(i.basic.age)"
		
		interestCollectionView.reloadData()
		
	}
	
	
	
	var maxInterests = 10
	var rows = 2
	var spacingBetweenCells: CGFloat = 12
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return maxInterests
	}
	
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestCell", for: indexPath) as! InterestCVC
		if indexPath.item < Myself.basic.interests.count {
			cell.interest = Myself.basic.interests[indexPath.item]
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
