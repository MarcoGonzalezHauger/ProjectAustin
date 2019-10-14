//
//  ProfileVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class SettingCell: UITableViewCell {
	@IBOutlet weak var categoryHeader: UILabel!
	@IBOutlet weak var categoryLabel: UILabel!
}

struct ProfileSetting {
	let Header: String
	let Information: AnyObject
	let identifier: String
}

var attemptedLogOut: Bool = false

class ProfileVC: UIViewController, EnterZipCode, UITableViewDelegate, UITableViewDataSource {
	
    @IBOutlet weak var referralCode_btn: UIButton!
    //@IBOutlet weak var joinedOn_lbl: UILabel!
    var userSettings: [ProfileSetting] = []
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return userSettings.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 75
	}
	
	
	
	@IBAction func logOut(_ sender: Any) {            signOutofAmbassadoor()
		attemptedLogOut = true
		let loginVC = self.storyboard?.instantiateInitialViewController()
		let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
		appDel.window?.rootViewController = loginVC
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = shelf.dequeueReusableCell(withIdentifier: "menuItem") as! SettingCell
		let settings = userSettings[indexPath.row]
		cell.categoryHeader.text = settings.Header
		switch settings.identifier {
		case "main_cat":
//			cell.categoryLabel.text = (settings.Information as! Category).rawValue
			let finalCategories: String = GetCategoryStringFromlist(categories: Yourself.categories ?? [])
            let catcount = settings.Information as! [String]
            
            cell.categoryHeader.text = settings.Header + (" \(catcount.count)/\(maximumCategories)")
            cell.categoryLabel.text = finalCategories
		case "zip":
			let zip = settings.Information as! String
			if zip == "0" {
				cell.categoryLabel.text = "None, you won't recieve Geo Offers."
			} else {
				cell.categoryLabel.text = "Zip Code: \(zip)"
				//naveen commented
				GetTownName(zipCode: String(zip)) { (townName, zipCode) in
					cell.categoryLabel.text = townName
					zipCodeDic[String(zip)] = townName
				}
			}
		default:
			cell.categoryLabel.text = "N/A"
		}
		return cell
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let setting = userSettings[indexPath.row]
		selectedID = setting.identifier
		switch setting.identifier {
		case "main_cat":
			//curcat = Yourself.primaryCategory
			//performSegue(withIdentifier: "toPicker", sender: self)
			performSegue(withIdentifier: "toPicker", sender: self)
		case "zip":
			performSegue(withIdentifier: "toZip", sender: self)
		default:
			break
		}
		shelf.deselectRow(at: indexPath, animated: false)
	}
	
	var selectedID: String!
	var curcat: Category?
	
	func ZipCodeEntered(zipCode: String?) {
		if let zipCode = zipCode {
			Yourself.zipCode = zipCode
		}
		self.dataUpdated()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? CategoryPicker {
			
			var yourCats: [Category] = []
			
			for c in Yourself.categories ?? [] {
				yourCats.append(Category(rawValue: c)!)
			}
			
			destination.SetupPicker(originalCategories: yourCats) { (cat) in
				

				var newCats: [String] = []
				for c in cat {
					newCats.append(c.rawValue)
				}
				Yourself.categories = newCats
				self.dataUpdated()
			}
		}
		if let destination = segue.destination as? ZipCodeVC {
			destination.delegate = self
		}
	}
	
	func dataUpdated() {
		userSettings = reloadUserSettings()
        //naveen commented
//		self.shelf.reloadData()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        if let profilepic = Yourself.profilePicURL {
            ProfilePicture.downloadAndSetImage(profilepic, isCircle: true)
        } else {
            ProfilePicture.image = defaultImage
        }
        tierBox.layer.cornerRadius = tierBox.bounds.height / 2
//        tierLabel.text = String(GetTierFromFollowerCount(FollowerCount: Yourself.followerCount) ?? 0)
        
        if Yourself.isDefaultOfferVerify {
            if GetTierFromFollowerCount(FollowerCount: Yourself.followerCount) != nil {
                tierLabel.text = String(GetTierFromFollowerCount(FollowerCount: Yourself.followerCount)! + 1)
            }else{
                tierLabel.text = String(GetTierFromFollowerCount(FollowerCount: Yourself.followerCount) ?? 1)
            }
        }else{
            tierLabel.text = String(GetTierFromFollowerCount(FollowerCount: Yourself.followerCount) ?? 0)
        }

        
        followerCount.text = CompressNumber(number: Yourself.followerCount)
        averageLikes.text = Yourself.averageLikes == nil ? "N/A" : CompressNumber(number: Yourself.averageLikes!)
        //joinedOn_lbl.text = Yourself.joinedDate != nil ? "Joined On : " + Yourself.joinedDate! : ""
        referralCode_btn.setTitle("Referral Code: " + Yourself.referralcode, for: .normal)
        
        tierBox.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "tiergrad")!)
        
        userSettings = reloadUserSettings()
        
        shelf.dataSource = self
        shelf.delegate = self
    }
	
	@IBOutlet weak var shelf: UITableView!
	@IBOutlet weak var followerCount: UILabel!
	@IBOutlet weak var tierBox: UIView!
	@IBOutlet weak var ProfilePicture: UIImageView!
	@IBOutlet weak var averageLikes: UILabel!
	@IBOutlet weak var tierLabel: UILabel!
	
	func reloadUserSettings() -> [ProfileSetting] {
		var avaliableSettings: [ProfileSetting] = []
        print(Yourself.zipCode as AnyObject)
        print(Yourself.categories as AnyObject)



        avaliableSettings.append(ProfileSetting.init(Header: "CATEGORIES", Information: Yourself.categories as AnyObject, identifier: "main_cat"))
		avaliableSettings.append(ProfileSetting.init(Header: "TOWN (ALLOWS GEO OFFERS)", Information: (Yourself.zipCode ?? "0") as AnyObject, identifier: "zip"))
        
        
        let ref = Database.database().reference().child("users")
        let userReference = ref.child(Yourself.id)
        let userData = API.serializeUser(user: Yourself, id: Yourself.id)
        userReference.updateChildValues(userData)
        
        self.shelf.reloadData()
        
		return avaliableSettings
	}
	
	@IBAction func OfferHistoryClicked(_ sender: Any) {
		let alert = UIAlertController(title: "Unavaliable", message: "This feature is not avaliable yet.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
	}
	
    @IBAction func referral_Action(_ sender: Any) {
        // text to share
        let text = "Ambassadoor Business Referral Code: \(Yourself!.referralcode)"
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.postToTwitter ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}
