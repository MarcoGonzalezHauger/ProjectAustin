//
//  ProfileVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
	@IBOutlet weak var categoryHeader: UILabel!
	@IBOutlet weak var categoryLabel: UILabel!
}

struct ProfileSetting {
	let Header: String
	let Information: AnyObject
	let identifier: String
}

class ProfileVC: UIViewController, EnterZipCode, UITableViewDelegate, UITableViewDataSource {
	
	var userSettings: [ProfileSetting] = []
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return userSettings.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 75
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = shelf.dequeueReusableCell(withIdentifier: "menuItem") as! SettingCell
		let settings = userSettings[indexPath.row]
		cell.categoryHeader.text = settings.Header
		switch settings.identifier {
		case "main_cat":
			cell.categoryLabel.text = (settings.Information as! Category).rawValue
		case "second_cat":
			let cat: Category? = settings.Information as? Category
			cell.categoryLabel.text = cat == nil ? "Choose" : cat!.rawValue
		case "zip":
			let zip = settings.Information as! Int
			if zip == 0 {
				cell.categoryLabel.text = "None, you won't recieve Geo Offers."
			} else {
				if (zipCodeDic[String(zip)] ?? "") != "" {
					cell.categoryLabel.text = zipCodeDic[String(zip)]!
				} else {
					cell.categoryLabel.text = "Zip Code: \(zip)"
					GetTownName(zipCode: String(zip)) { (townName) in
						cell.categoryLabel.text = townName
						zipCodeDic[String(zip)] = townName
					}
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
			curcat = Yourself.primaryCategory
			performSegue(withIdentifier: "toPicker", sender: self)
		case "second_cat":
			curcat = Yourself.SecondaryCategory
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
			Yourself.zipCode = Int(zipCode)
		}
		self.dataUpdated()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? CategoryPicker {
			destination.SetupPicker(originalCategory: curcat) { (cat) in
				if self.selectedID == "main_cat" {
					Yourself.primaryCategory = cat
				} else if self.selectedID == "second_cat" {
					Yourself.SecondaryCategory = cat
				}
				self.dataUpdated()
			}
		}
		if let destination = segue.destination as? ZipCodeVC {
			destination.delegate = self
		}
	}
	
	func dataUpdated() {
		userSettings = reloadUserSettings()
		self.shelf.reloadData()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		if let profilepic = Yourself.profilePicURL {
			ProfilePicture.downloadAndSetImage(profilepic, isCircle: true)
		} else {
			ProfilePicture.image = defaultImage
		}
		tierBox.layer.cornerRadius = tierBox.bounds.height / 2
		tierLabel.text = String(GetTierFromFollowerCount(FollowerCount: Yourself.followerCount) ?? 0)
		
		followerCount.text = CompressNumber(number: Yourself.followerCount)
		averageLikes.text = Yourself.averageLikes == nil ? "N/A" : CompressNumber(number: Yourself.averageLikes!)
		
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
		avaliableSettings.append(ProfileSetting.init(Header: "MAIN CATEGORY", Information: Yourself.primaryCategory as AnyObject, identifier: "main_cat"))
		//minimum category of 6.
		if GetTierFromFollowerCount(FollowerCount: Yourself.followerCount) ?? 0 > 6 {
			avaliableSettings.append(ProfileSetting.init(Header: "SECONDARY CATEGORY", Information: Yourself.SecondaryCategory as AnyObject, identifier: "second_cat"))
		}
		avaliableSettings.append(ProfileSetting.init(Header: "TOWN (ALLOWS GEO OFFERS)", Information: (Yourself.zipCode ?? 0) as AnyObject, identifier: "zip"))
		return avaliableSettings
	}

}
