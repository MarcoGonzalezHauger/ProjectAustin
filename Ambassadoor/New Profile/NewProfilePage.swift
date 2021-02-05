//
//  NewProfilePage.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/28/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewProfilePage: UIViewController, myselfRefreshDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EnterZipCode {
	
	func ZipCodeEntered(zipCode: String?) {
		if let zipCode = zipCode {
			if isInEditMode {
				tempeditInfBasic.zipCode = zipCode
				refreshAfterOneEdit()
			}
		}
	}
	
	func myselfRefreshed() { //from MyselfRefreshDelegate
		if !isInEditMode {
			loadFromMyself()
		}
	}
	
	@IBOutlet weak var referralCodeView: ShadowView!
	@IBOutlet var editingViews: [ShadowView]!
	@IBOutlet var uniformShadowViews: [ShadowView]!
	@IBOutlet weak var backProfileImage: UIImageView!
	@IBOutlet weak var frontProfileImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var executiveBadge: UIImageView!
	@IBOutlet weak var verifiedBadge: UIImageView!
	@IBOutlet weak var averageLikesLabel: UILabel!
	@IBOutlet weak var followerCountLabel: UILabel!
	@IBOutlet weak var engagmentRateLabel: UILabel!
	@IBOutlet weak var blurView: UIVisualEffectView!
	
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
	
	@IBOutlet weak var editButton: UIButton! //isInEditMode: CANCEL BUTTON
	@IBOutlet weak var signOutButton: UIButton! //isInEditMode: SAVE CHANGES BUTTON
	@IBOutlet weak var signOutView: ShadowView!
	
	@IBOutlet weak var topMargin: NSLayoutConstraint!
	
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
		loadInfluencerInfo(influencer: Myself, BasicInfluencer: Myself.basic)
	}
	
	@IBAction func transferToBank(_ sender: Any) {
		
	}
	
	var isOnCopied = false
	
	@IBAction func copyRefferal(_ sender: Any) {
		if isInEditMode {
			MakeShake(viewToShake: referralCodeView, coefficient: 0.2)
		} else {
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
	}
	
	@IBAction func editButtonPressed(_ sender: Any) {
		if isInEditMode {
			cancelEditing()
		} else {
			startEditing()
		}
	}
	
	@IBAction func signOutButtonPressed(_ sender: Any) {
		if isInEditMode {
			saveChanged()
		} else {
			SignOutOfAmbassadoor3()
		}
	}
	
	func SignOutOfAmbassadoor3() {
		
	}
	
	var isInEditMode: Bool = false {
		didSet {
			if isInEditMode {
				StartEditAnimation()
				loadInfluencerInfo(influencer: Myself, BasicInfluencer: tempeditInfBasic)
			} else {
				EndEditAnimation()
				loadInfluencerInfo(influencer: Myself, BasicInfluencer: Myself.basic)
			}
		}
	}
	
	var tempeditInfBasic: BasicInfluencer!
	
	func StartEditAnimation() {
		UIView.animate(withDuration: 0.5) { [self] in
			self.backProfileImage.alpha = 0
			//self.blurView.alpha = 0
			for v in self.editingViews {
				v.backgroundColor = UIColor.init(named: "newSubtleBackground")!
			}
			self.signOutView.backgroundColor = .systemBlue
		}
		editButton.setTitle("Cancel", for: .normal)
		signOutButton.setTitle("Save Changes", for: .normal)
		signOutButton.setTitleColor(.white, for: .normal)
	}
	
	func EndEditAnimation() {
		UIView.animate(withDuration: 0.5) {
			self.backProfileImage.alpha = 1
			//self.blurView.alpha = 1
			for v in self.editingViews {
				v.backgroundColor = UIColor.init(named: "newCellColor")!
			}
			self.signOutView.backgroundColor = UIColor.init(named: "newCellColor")!
		}
		editButton.setTitle("Edit", for: .normal)
		signOutButton.setTitle("Sign Out", for: .normal)
		signOutButton.setTitleColor(.systemRed, for: .normal)
	}
	
	func startEditing() {
		tempeditInfBasic = Myself.basic
		isInEditMode = true
	}
	
	func cancelEditing() {
		tempeditInfBasic = nil
		isInEditMode = false
	}
	
	func saveChanged() {
		Myself.basic.zipCode = tempeditInfBasic.zipCode
		Myself.basic.gender	= tempeditInfBasic.gender
		Myself.basic.birthday = tempeditInfBasic.birthday
		Myself.basic.interests = tempeditInfBasic.interests
		isInEditMode = false
		Myself.UpdateToFirebase(alsoUpdateToPublic: true, completed: nil)
		cancelEditing()
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		UseTapticEngine()
		if isInEditMode {
			//display the interest picker
		}
	}
	
	@IBAction func zipCodePressed(_ sender: Any) {
		if isInEditMode {
			UseTapticEngine()
			performSegue(withIdentifier: "toZip", sender: self)
		}
	}
	
	@IBAction func genderPressed(_ sender: Any) {
		if isInEditMode {
			UseTapticEngine()
			//age picker
		}
	}
	
	@IBAction func agePressed(_ sender: Any) {
		if isInEditMode {
			UseTapticEngine()
			//age picker.
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? ZipCodeVC {
			view.delegate = self
		}
	}
	
	
	func refreshAfterOneEdit() {
		loadInfluencerInfo(influencer: Myself, BasicInfluencer: tempeditInfBasic)
	}
	
	func loadInfluencerInfo(influencer i: Influencer, BasicInfluencer basic: BasicInfluencer) {
		backProfileImage.downloadAndSetImage(basic.profilePicURL)
		frontProfileImage.downloadAndSetImage(basic.profilePicURL)
		nameLabel.text = basic.name
		executiveBadge.isHidden = !basic.checkFlag("isAmbassadoorExecutive")
		verifiedBadge.isHidden = !basic.checkFlag("isVerified")
		averageLikesLabel.text = NumberToStringWithCommas(number: basic.averageLikes)
		followerCountLabel.text = NumberToStringWithCommas(number: basic.followerCount)
		engagmentRateLabel.text = "\(basic.engagmentRateInt)%"
		
		referralCodeLabel.text = "\(basic.referralCode)"
		balanceLabel.text = NumberToPrice(Value: i.finance.balance)
		if i.finance.balance == 0 {
			transferView.isHidden = true
		} else {
			transferView.isHidden = false
		}
		
		zipCodeLabel.text = basic.zipCode
		self.townNameLabel.isHidden = true
		GetTownName(zipCode: basic.zipCode) { (zipCodeData, zipCode) in
			DispatchQueue.main.async {
				if let zipCodeData = zipCodeData {
					self.townNameLabel.isHidden = false
					self.townNameLabel.text = zipCodeData.CityAndStateName
				} else {
					self.townNameLabel.isHidden = true
				}
			}
		}
		
		genderLabel.text = basic.gender
		ageLabel.text = "\(basic.age)"
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
