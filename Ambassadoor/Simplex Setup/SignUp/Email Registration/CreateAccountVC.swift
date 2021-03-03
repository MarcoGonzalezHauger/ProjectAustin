//
//  CreateAccountVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/7/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import UserNotifications
import NotificationCenter

enum CreateAccountProblem {
	case noConnection //The iPhone doens't have connection to the internet.
	case emailTaken //If the users's email has been taken from the time they chose it to the time they created their account
	case instaTaken //If the users's INSTAGRAM hasbeen taken from the time they chose it to the time they created their account.T
    case noBasicInfo // User doesn't enter the basic information
}

class CreateStep: UITableViewCell {
	@IBOutlet weak var checkImage: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descLabel: UILabel!
	@IBOutlet weak var centerGuide: NSLayoutConstraint!
	func SetSubtitle(string: String) {
		descLabel.text = string
		centerGuide.constant = string == "" ? 0 : -9
	}
}

class CreateAccountVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NewAccountListener {
	
	var delegate: AutoDimiss?
	var wasFailed = false
    
    
	@IBOutlet weak var testingLabel: UILabel!
	@IBOutlet weak var testingSwitch: UISwitch!
	@IBAction func switchToggles(_ sender: Any) {
		NewAccount.isForTesting = testingSwitch.isOn
	}
	
	
	@IBOutlet weak var CreateButtonView: ShadowView!
	@IBOutlet weak var CreateButton: UIButton!
    
    
	
	func CreateAccount() {
		//[RAM] Complete this function with creation of account
		
//		//if failed:
//		AccountCreationFailed(problem: .emailTaken)
//
//		//if success (this only dimisses the VCs):
//		AccountSuccessfullyCreated()
                
        if NewAccount.email == "" {
			AccountCreationFailed(problem: .emailTaken)
			return
		}
		
		if NewAccount.instagramUsername == ""{
			AccountCreationFailed(problem: .instaTaken)
			return
		}
		
		if NewAccount.zipCode == "" {
			AccountCreationFailed(problem: .noBasicInfo)
			return
		}
		
		var referralcodeString = ""
		referralcodeString.append(randomString(length: 6))
		let referral = referralcodeString.uppercased()
		NewAccount.referralCode = referral
		let uid = NewAccount.instagramUsername.replacingOccurrences(of: ".", with: ",")
		let NewUserID = uid + ", " + randomString(length: 15)
        checkNewIfUserExists(userID: NewUserID, instagramAuth: NewAccount.instagramAccountId) { (exist, user) in
			
			if exist{
				self.AccountCreationFailed(problem: .instaTaken)
			}else{
				Myself = user
				UserDefaults.standard.set(NewUserID, forKey: "userID")
				UserDefaults.standard.set(NewAccount.email, forKey: "email")
				UserDefaults.standard.set(NewAccount.password, forKey: "password")
				self.AccountSuccessfullyCreated()
			}
			
		}
		
		
	}
	
	//OTHER CODE:
	
	func AccountSuccessfullyCreated() {

        self.delegate?.DismissNow(sender: "CreateAccount")
        AverageLikes(instagramID: Myself.instagramAccountId, userToken: Myself.instagramAuthToken)
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //self.delegate?.DismissNow(sender: "signin")
            let viewReference = instantiateViewController(storyboard: "Main", reference: "TabBarReference") as! TabBarVC
            //downloadDataBeforePageLoad(reference: viewReference)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = viewReference
        }
        
//        self.dismiss(animated: true) {
//
//        }
	}
	
	
	func AccountCreationFailed(problem: CreateAccountProblem) {
		wasFailed = true
		
		YouShallNotPass(SaveButtonView: CreateButtonView, returnColor: UIColor.init(named: "AmbDarkPurple")!)
		
		switch problem {
		case .emailTaken:
			NewAccount.email = ""
			self.showStandardAlertDialog(title: "Email Taken", msg: "The email address has been taken already.", handler: nil)
			break
		case .instaTaken:
			NewAccount.instagramUsername = ""
			self.showStandardAlertDialog(title: "Instagram Account Taken", msg: "This Instagram Account is already being used by another user.", handler: nil)
			break
		case .noConnection:
			self.showStandardAlertDialog(title: "No Connection", msg: "No communication with the Ambasadoor server.s", handler: nil)
			break
        case .noBasicInfo:
            self.showStandardAlertDialog(title: "No Basic Information Given", msg: "Please provide your basic information to Ambasadoor", handler: nil)
        }
        
	}
	
	func AccountUpdated(NewAccount: NewAccountInfo) {
		stepShelf.reloadData()
		let loginGood = NewAccount.email != ""
		let instaGood = NewAccount.instagramUsername != ""
		let infoGood = NewAccount.zipCode != ""
		let allGood = loginGood && instaGood && infoGood
		SetButtonState(enabled: allGood)
	}
	
	@IBOutlet weak var stepShelf: UITableView!
	
	func SetButtonState(enabled: Bool) {
		UIView.animate(withDuration: 0.5) {
			if enabled {
				self.CreateButtonView.backgroundColor = UIColor.init(named: "AmbDarkPurple")!
			} else {
				self.CreateButtonView.backgroundColor = .systemGray
			}
		}
		CreateButton.isEnabled = enabled
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return GetListSize()
	}
	
	@IBAction func createAccount(_ sender: Any) {
		CreateAccount()
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = stepShelf.dequeueReusableCell(withIdentifier: "nextStep") as! CreateStep
		switch indexPath.row {
		case 0:
			cell.titleLabel.text = NewAccount.email == "" ? "Create Login" : "Login Created"
			cell.SetSubtitle(string: NewAccount.email.lowercased())
			cell.checkImage.image = UIImage.init(named: NewAccount.email == "" ? "setup_todo" : "setup_completed")
		case 1:
			cell.titleLabel.text = NewAccount.instagramUsername == "" ? "Connect Instagram" : "Instagram Connected"
			cell.SetSubtitle(string: NewAccount.instagramUsername)
			cell.checkImage.image = UIImage.init(named: NewAccount.instagramUsername == "" ? "setup_todo" : "setup_completed")
		case 2:
			if NewAccount.zipCode == "" {
				cell.titleLabel.text = "Enter Basic Information"
				cell.SetSubtitle(string: "")
			} else {
				cell.titleLabel.text = "Basic Information Entered"
				cell.SetSubtitle(string: "\(NewAccount.gender), \(Calendar.current.dateComponents([.year], from: NewAccount.dob.toUDate(), to: Date()).year!), \(NewAccount.zipCode)")
			}
			cell.checkImage.image = UIImage.init(named: NewAccount.zipCode == "" ? "setup_todo" : "setup_completed")
		default:
			break
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		stepShelf.deselectRow(at: indexPath, animated: true)
		switch indexPath.row {
		case 0:
            //performSegue(withIdentifier: "fromCreateAccount", sender: self)
            performSegue(withIdentifier: "toCreateLogin", sender: self)
		case 1:
			performSegue(withIdentifier: "toConnectPVC", sender: self)
            //performSegue(withIdentifier: "toConnectInstagram", sender: self)
            //toConnectStepVC
            //toConnectPVC toConnectPVC
		case 2:
            performSegue(withIdentifier: "fromCreateAccount", sender: self)
			//performSegue(withIdentifier: "toBasicInfo", sender: self)
		default:
			break
		}
	}
	
	func GetListSize() -> Int {
		if wasFailed {
			return 3
		}
		if NewAccount.instagramUsername != "" {
			return 3
		}
		if NewAccount.email	!= "" {
			return 2
		}
		return 1
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		NewAccountListeners.append(self)
		stepShelf.delegate = self
		stepShelf.dataSource = self
		SetButtonState(enabled: false)
		//nextStep
		stepShelf.alwaysBounceVertical = false
        //wasFailed = true
		
		let showTestingSwitch = false
		testingSwitch.isHidden = !showTestingSwitch
		testingLabel.isHidden = !showTestingSwitch
    }

	@IBAction func cancelled(_ sender: Any) {
		self.navigationController?.dismiss(animated: true, completion: nil)
	}

	@IBAction func YesImABusiness(_ sender: Any) {
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.getNotificationSettings { (settings) in
			DispatchQueue.main.async {
				if settings.authorizationStatus != .authorized {
					let alert = UIAlertController(title: "Business? Wrong App", message: "Download Ambassadoor Business here", preferredStyle: UIAlertController.Style.alert)
					alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
					alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { (_) in
					OpenAppStoreID(id: "amassadoorbusiness/id1483207154")
					}))
					DispatchQueue.main.async {
						self.present(alert, animated: true, completion: nil)
					}
				} else {
					OpenAppStoreID(id: "amassadoorbusiness/id1483207154")
					self.wrongAppNotification()
				}
			}
		}
	}
	func wrongAppNotification() {
		
		let notificationCenter = UNUserNotificationCenter.current()
		let content = UNMutableNotificationContent()
		
		content.title = "Business? Wrong App"
		content.body = "Download Ambassadoor Business Here"
		content.sound = nil
		content.badge = nil
		
	
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.2, repeats: false)
		let identifier = "AMB_wrongApp"
		if let attachment = UNNotificationAttachment.make(identifier: "businessLogo", image: UIImage.init(named: "BusinessIcon")!, options: nil) {
			content.attachments = [attachment]
		}
		
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
	
		notificationCenter.add(request) { (error) in
			if let error = error {
				print("Error \(error.localizedDescription)")
			}
		}
	}
    
    
    
}
