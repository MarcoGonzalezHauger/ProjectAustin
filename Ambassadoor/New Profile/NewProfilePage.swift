//
//  NewProfilePage.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/28/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewProfilePage: UIViewController, myselfRefreshDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EnterZipCode, NewSettingsDelegate {
	
	func GoIntoEditMode() {
		startEditing()
	}
	
	
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
		
		editProfileView.alpha = 0
		
    }
	
	func loadFromMyself() {
		loadInfluencerInfo(influencer: Myself, BasicInfluencer: Myself.basic)
	}
	
	@IBAction func transferToBank(_ sender: Any) {
        
        self.performSegue(withIdentifier: "toAccountInfoSegue", sender: self)
		
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
	
	@IBAction func settingsButtonPressed(_ sender: Any) {
		if isInEditMode {
			saveChanged()
		}
		performSegue(withIdentifier: "toSettings", sender: self)
	}
	
	@IBAction func signOutButtonPressed(_ sender: Any) {
		
	}
	
	func SignOutOfAmbassadoor3() {
		
	}
	
	var isInEditMode: Bool = false {
		didSet {
			if isInEditMode {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
					self.StartEditAnimation()
				}
			} else {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
					self.EndEditAnimation()
				}
			}
		}
	}
	
	var tempeditInfBasic: BasicInfluencer!
	
	
	@IBOutlet weak var editBoxTop: NSLayoutConstraint! //edit mode: 8, reg: -20
	@IBOutlet weak var topMargin: NSLayoutConstraint! //reg: 20, edit mode: 45.
	@IBOutlet weak var mainView: UIView!
	@IBOutlet weak var editProfileView: ShadowView!
	@IBOutlet var endEditButtons: [UIButton]!
	@IBOutlet weak var profileEditLabel: UILabel!
	
	@IBOutlet var editBorderViews: [ShadowView]!
	var interestViews: [ShadowView] = []
	
	func GetAllBorderViews() -> [ShadowView] {
		
		var allViews: [ShadowView]! = self.editBorderViews
		allViews.append(contentsOf: self.interestViews)
		
		return allViews
	}
	
	func StartEditAnimation() {
		topMargin.constant = 55
		editBoxTop.constant = 18
		
		for b in endEditButtons {
			b.isEnabled = true
		}
		
		
		for v in GetAllBorderViews() {
			v.borderWidth = 1.5
		}
		
		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
			self.editProfileView.alpha = 1
		}
		
		for v in self.GetAllBorderViews() {
			v.animateBorderColor(toColor: .systemBlue, duration: 0.5)
		}
	}
	
	func EndEditAnimation() {
		topMargin.constant = 20
		editBoxTop.constant = -20
		
		for b in endEditButtons {
			b.isEnabled = false
		}
		
		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
			self.editProfileView.alpha = 0
		}
		
		for v in self.GetAllBorderViews() {
			v.animateBorderColor(toColor: .clear, duration: 0.5)
		}
	}
	
	@IBAction func changedSaved(_ sender: Any) {
		saveChanged()
	}
	
	@IBAction func changesDiscarded(_ sender: Any) {
		cancelEditing()
	}
	
	
	func startEditing() {
		tempeditInfBasic = BasicInfluencer.init(dictionary: Myself.basic.toDictionary(), userId: "TEMPINF")
		isInEditMode = true
	}
	
	func cancelEditing() {
		tempeditInfBasic = nil
		loadInfluencerInfo(influencer: Myself, BasicInfluencer: Myself.basic)
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
	
	func doSegueForEdit(withIdentifier id: String) {
		UseTapticEngine()
		
		if !isInEditMode {
			startEditing()
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
				self.doSegue(id: id)
			}
		} else {
			doSegue(id: id)
		}
	}
	
	func pickGender() {
		let genderPick = UIAlertController(title: "Pick Gender", message: "", preferredStyle: UIAlertController.Style.actionSheet)
		
		let female = UIAlertAction(title: "Female", style: .default) { (action: UIAlertAction) in
			self.tempeditInfBasic.gender = "Female"
			self.refreshAfterOneEdit()
		}
		
		let male = UIAlertAction(title: "Male", style: .default) { (action: UIAlertAction) in
			self.tempeditInfBasic.gender = "Male"
			self.refreshAfterOneEdit()
		}
		
		let other = UIAlertAction(title: "Other...", style: .default) { (action: UIAlertAction) in
			let alert = UIAlertController(title: "Enter Your Gender", message: "", preferredStyle: .alert)

			alert.addTextField { (textField) in
				textField.placeholder = "Gender"
			}
			
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
				let text = alert!.textFields![0].text!
				if text != "" {
					self.tempeditInfBasic.gender = text
					self.refreshAfterOneEdit()
				}
			}))

			self.present(alert, animated: true, completion: nil)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		
		genderPick.addAction(female)
		genderPick.addAction(male)
		genderPick.addAction(other)
		genderPick.addAction(cancelAction)
		self.present(genderPick, animated: true, completion: nil)
	}
	
	func doSegue(id: String) {
		switch id {
		case "toGenderPicker":
			pickGender()
		default:
			performSegue(withIdentifier: id, sender: self)
		}
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		doSegueForEdit(withIdentifier: "toInterestPicker")
	}
	
	@IBAction func zipCodePressed(_ sender: Any) {
		doSegueForEdit(withIdentifier: "toZip")
	}
	
	@IBAction func genderPressed(_ sender: Any) {
		doSegueForEdit(withIdentifier: "toGenderPicker")
	}
	
	@IBAction func agePressed(_ sender: Any) {
		doSegueForEdit(withIdentifier: "toAgePicker")
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? ZipCodeVC {
			view.delegate = self
		}
		if let view = segue.destination as? NewSettingsVC {
			view.delegate = self
		}
	}
	
	
	func refreshAfterOneEdit() {
		loadInfluencerInfo(influencer: Myself, BasicInfluencer: tempeditInfBasic)
	}
	
	func loadInfluencerInfo(influencer i: Influencer, BasicInfluencer basic: BasicInfluencer) {
		
		backProfileImage.image = nil
		frontProfileImage.image = nil
		downloadImage(basic.resizedProfile) { (uiimage) in
			self.backProfileImage.image = uiimage
			self.frontProfileImage.image = uiimage
		}
		
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
		
		if basic.zipCode != zipCodeLabel.text {
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
			if cell.interest != Myself.basic.interests[indexPath.row] {
				cell.interest = Myself.basic.interests[indexPath.item]
			}
		} else {
			cell.interest = ""
		}
		if !interestViews.contains(cell.mainView) {
			interestViews.append(cell.mainView)
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
