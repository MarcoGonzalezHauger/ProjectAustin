//
//  NewProfilePage.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/28/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit


class NewProfilePage: UIViewController, myselfRefreshDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EnterZipCode, NewSettingsDelegate, InterestPickerDelegate, CustomDatePickerDelegate {
    
    /// CustomDatePickerDelegate delegate method.
    /// - Parameter date: get picked date
    func pickedDate(date: Date) {
        self.tempeditInfBasic.birthday = date
        self.refreshAfterOneEdit()
    }
    
    
    /// Check if edit mode. set interest and reload collection. InterestPickerDelegate delegate method.
    /// - Parameter interests:get selected interests
	func newInterests(interests: [String]) {
		if isInEditMode {
			tempeditInfBasic.interests = interests
			interestCollectionView.reloadData()
		}
	}
	
    
    /// Go to edit mode.
	func GoIntoEditMode() {
		startEditing()
	}
	
    /// EnterZipCode delegate method
    /// - Parameter zipCode: get entered zipcode.
	func ZipCodeEntered(zipCode: String?) {
		if let zipCode = zipCode {
			if isInEditMode {
				tempeditInfBasic.zipCode = zipCode
				refreshAfterOneEdit()
			}
		}
	}
	
    
    /// Refresh user details and set profile tabbar image
	func myselfRefreshed() { //from MyselfRefreshDelegate
		if !isInEditMode {
			loadFromMyself()
            setTabBarProfilePicture()
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
    
    let datePickerView:UIDatePicker = UIDatePicker()
	
	
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.delegate = self
    }
    
    
    /// Set custom image to profile tabbar
    func setTabBarProfilePicture() {
        let logo = Myself.basic.resizedProfile
        downloadImage(logo) { (image) in
            let size = CGSize.init(width: 30, height: 30)
            
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            image?.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if var image = newImage {
                DispatchQueue.main.async {
                    print(image.scale)
                    image = makeImageCircular(image: image)
                    print(image.scale)
                    self.tabBarController?.viewControllers?[0].tabBarItem.image = nil
                    self.tabBarController?.viewControllers?[0].tabBarItem.selectedImage = nil
                    self.tabBarController?.viewControllers?[0].tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
                    self.tabBarController?.viewControllers?[0].tabBarItem.selectedImage = image.withRenderingMode(.alwaysOriginal)
                }
                
            }
        }
    }
        
//    func setDatePicker(dateChooserAlert: UIAlertController) {
//            datePickerView.frame = CGRect.init(x: 0, y: 10, width: dateChooserAlert.view.frame.size.width, height: 300)
//            var components = DateComponents()
//            components.year = -18
//            let maxDate = Calendar.current.date(byAdding: components, to: Date())
//            datePickerView.maximumDate = maxDate
//            datePickerView.datePickerMode = UIDatePicker.Mode.date
//    //        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
//    }
    
//    func dobPicker(){
//        let dateChooserAlert = UIAlertController(title: "Choose Date.", message: nil, preferredStyle: .actionSheet)
//        self.setDatePicker(dateChooserAlert: dateChooserAlert)
//        dateChooserAlert.view.addSubview(datePickerView)
//        dateChooserAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
//            self.convertDateToAge(date: self.datePickerView.date)
//        }))
//        dateChooserAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
//        }))
//        let height: NSLayoutConstraint = NSLayoutConstraint(item: dateChooserAlert.view as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.1, constant: 400)
//        dateChooserAlert.view.addConstraint(height)
//        self.present(dateChooserAlert, animated: true, completion: nil)
//    }
    
    func convertDateToAge(date: Date) {
//        let age = Calendar.current.dateComponents([.year], from: date, to: Date())
//        self.ageLabel.text = "\(age.year ?? 0)"
        self.tempeditInfBasic.birthday = date
        self.refreshAfterOneEdit()
    }
	
    
    /// Load influencer details
	func loadFromMyself() {
		loadInfluencerInfo(influencer: Myself, BasicInfluencer: Myself.basic)
	}
	
    
    /// Check if a user has a valid amount to withdraw. Segue to bank account page
    /// - Parameter sender: UIButton referrance
	@IBAction func transferToBank(_ sender: Any) {
		
		if shouldRedeem() {
			performSegue(withIdentifier: "toRedeem", sender: self)
			return
		}
        
        let feeAmount = GetFeeForNewInfluencer(Myself)
        let withdrawAmount = Myself.finance.balance - Double(feeAmount)
        print("fee=\(feeAmount)")
        print(withdrawAmount)
        
        if withdrawAmount < 0 {
			
			self.showStandardAlertDialog(title: "Not enough to Withdraw", msg: "You must earn at least \(NumberToPrice(Value: GetFeeForNewInfluencer(Myself), enforceCents: true)) to withdraw due to Stripe transaction fees.")
            return
        }else{
            self.performSegue(withIdentifier: "toAccountInfoSegue", sender: self)
        }
	}
	
	var isOnCopied = false
	
    
    /// Copy referral code
    /// - Parameter sender: UIButton referrance
	@IBAction func copyRefferal(_ sender: Any) {
		if !isOnCopied {
			referralCodeLabel.layer.masksToBounds = true
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
	
    
    /// save changes if isInEditMode is ture. segue to setting page
    /// - Parameter sender: UIButton referrance
	@IBAction func settingsButtonPressed(_ sender: Any) {
		if isInEditMode {
			saveChanged()
		}
		performSegue(withIdentifier: "toSettings", sender: self)
	}
	
    
    /// Logout action
    /// - Parameter sender: UIButton referrance
	@IBAction func signOutButtonPressed(_ sender: Any) {
		logOut()
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
	
    
    /// Save changes action
    /// - Parameter sender: UIButton referrance
	@IBAction func changedSaved(_ sender: Any) {
		saveChanged()
	}
	
    
    /// Changes discard action
    /// - Parameter sender: UIButton referrance
	@IBAction func changesDiscarded(_ sender: Any) {
		cancelEditing()
	}
	
    
    /// Initialize start editing
	func startEditing() {
		tempeditInfBasic = BasicInfluencer.init(dictionary: Myself.basic.toDictionary(), userId: "TEMPINF")
		isInEditMode = true
	}
    
    /// Cancel editing
	func cancelEditing() {
		tempeditInfBasic = nil
		loadInfluencerInfo(influencer: Myself, BasicInfluencer: Myself.basic)
		isInEditMode = false
	}
	
    
    /// Save changes and update to firebase
	func saveChanged() {
		Myself.basic.zipCode = tempeditInfBasic.zipCode
		Myself.basic.gender	= tempeditInfBasic.gender
		Myself.basic.birthday = tempeditInfBasic.birthday
		Myself.basic.interests = tempeditInfBasic.interests
		isInEditMode = false
		Myself.UpdateToFirebase(alsoUpdateToPublic: true, completed: nil)
		cancelEditing()
	}
	
    
    /// Get edit segue and start editing
    /// - Parameter id: identifier string
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
    
    /// Show gender picker
	func pickGender() {
		ShowGenderPicker(self) { (newGender) in
			self.tempeditInfBasic.gender = newGender
			self.refreshAfterOneEdit()
		}
	}
	
    
    /// segue to action sheet controller based on id
    /// - Parameter id: picker id
	func doSegue(id: String) {
		switch id {
		case "toGenderPicker":
			pickGender()
        case "fromProfileToPicker":
            //dobPicker()
            performSegue(withIdentifier: id, sender: self)
		default:
			performSegue(withIdentifier: id, sender: self)
		}
	}
// MARK: UICollection view delegate and datasource
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		doSegueForEdit(withIdentifier: "toInterestPicker")
	}
	
    
    /// Segue to edit zip code
    /// - Parameter sender: UIButton referrance
	@IBAction func zipCodePressed(_ sender: Any) {
		doSegueForEdit(withIdentifier: "toZip")
	}
    /// Segue to pick gender
    /// - Parameter sender: UIButton referrance
	@IBAction func genderPressed(_ sender: Any) {
		doSegueForEdit(withIdentifier: "toGenderPicker")
	}
	
    
    /// Segue to age picker
    /// - Parameter sender: UIButton referrance
	@IBAction func agePressed(_ sender: Any) {
		doSegueForEdit(withIdentifier: "fromProfileToPicker")
        //doSegueForEdit(withIdentifier: "toAgePicker")
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? ZipCodeVC {
			if isInEditMode {
				view.zipToPass = tempeditInfBasic.zipCode
			} else {
				view.zipToPass = Myself.basic.zipCode
			}
			view.delegate = self
		}
		if segue.identifier == "toSettings" {
			if let nc = segue.destination as? UINavigationController {
				if let view = nc.topViewController as? NewSettingsVC {
					view.delegate = self
				}
		 }
		}
		if let view = segue.destination as? InterestPickerPopupVC {
			if isInEditMode {
				view.currentInterests = tempeditInfBasic.interests
			}
			view.delegate = self
		}
        
        if let view = segue.destination as? CustomDatePickerVC {
            view.pickerDelegate = self
            view.selectedDate = tempeditInfBasic.birthday
        }
	}
	
    
    /// check if redeem user
    /// - Returns: true or false
	func shouldRedeem() -> Bool {
		let xoPosts = Myself.inProgressPosts.filter{$0.checkFlag("xo case study")}
		if xoPosts.count > 0 {
			let xoPost = xoPosts.first!
			if xoPost.status == "Paid" && !xoPost.checkFlag("redeemed") {
				return true
			}
		}
		return false
		
	}
	
	func refreshAfterOneEdit() {
		loadInfluencerInfo(influencer: Myself, BasicInfluencer: tempeditInfBasic)
	}
    
    /// Refresh Influencer Information
    /// - Parameters:
    ///   - i: Send Influencer which user information  has to refresh
    ///   - basic: Send BasicInfluencer object to refresh basic information
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
		engagmentRateLabel.text = "\(basic.engagementRateInt)%"
		
		referralCodeLabel.text = "\(basic.referralCode)"
		
		if shouldRedeem() {
			balanceLabel.text = "$20 Gift Card"
			transferButton.setTitle("Redeem", for: .normal)
		} else {
			balanceLabel.text = NumberToPrice(Value: i.finance.balance)
			if i.finance.balance == 0 {
				transferView.isHidden = true
			} else {
				transferView.isHidden = false
			}
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
		
		var interests = Myself.basic.interests
		
		if isInEditMode {
			interests = tempeditInfBasic.interests
		}
		
		if indexPath.item < interests.count {
			if cell.interest != interests[indexPath.row] {
				cell.interest = interests[indexPath.item]
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
    
    
    /// Logout action
    /// - Parameter sender: UIButton referrance
    @IBAction func logoutAction(sender: UIButton){
        logOut()
    }
    
    

}

extension NewProfilePage: UITabBarControllerDelegate, UITabBarDelegate{
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool{
        return true
    }
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        
    }
    
}
