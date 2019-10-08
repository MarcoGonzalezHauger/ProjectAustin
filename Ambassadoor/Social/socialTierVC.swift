//
//  socialTierVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/1/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

let defaultImage : UIImage = makeImageCircular(image: UIImage.init(named: "defaultuser")!)

let blackIcons: [String] = ["marcogonzalezhauger", "brunogonzalezhauger"]

class SocialUserCell: UITableViewCell {
	@IBOutlet weak var username: UILabel!
	@IBOutlet weak var details: UILabel!
	@IBOutlet weak var profilepicture: UIImageView!
	@IBOutlet weak var shadow: ShadowView!
    @IBOutlet weak var verifyLogo_img: UIImageView!
	@IBOutlet weak var insetOfVerifiedLogo: NSLayoutConstraint!
	
	var ShowCategory: Bool = false
	var ThisUser: User? {
		didSet {
			if let thisUser = ThisUser {
				
				
				
				username.text = thisUser.name ?? "@\(thisUser.username)"

				username.setNeedsLayout()
				username.layoutIfNeeded()
				
				insetOfVerifiedLogo.constant =  username.bounds.width + 12
				
//				let secondtext : String = ShowCategory ? thisUser.primaryCategory.rawValue : "Tier " + String(GetTierFromFollowerCount(FollowerCount: thisUser.followerCount) ?? 0)
                if thisUser.isDefaultOfferVerify {
                    if GetTierFromFollowerCount(FollowerCount: thisUser.followerCount) != nil {
                        let secondtext : String = ShowCategory ? GetCatString(user: thisUser) : "Tier " + String(GetTierFromFollowerCount(FollowerCount: thisUser.followerCount)! + 1 )

                        details.text = NumberToStringWithCommas(number: thisUser.followerCount) + " followers • " + secondtext
                        
                    } else {
                        let secondtext : String = ShowCategory ? GetCatString(user: thisUser) : "Tier " + String(GetTierFromFollowerCount(FollowerCount: thisUser.followerCount) ?? 1)

                        details.text = NumberToStringWithCommas(number: thisUser.followerCount) + " followers • " + secondtext
                        
                    }
                    verifyLogo_img.image = UIImage(named: "verify_Logo")

                } else {
                    let secondtext : String = ShowCategory ? GetCatString(user: thisUser) : "Tier " + String(GetTierFromFollowerCount(FollowerCount: thisUser.followerCount) ?? 0)

                    details.text = NumberToStringWithCommas(number: thisUser.followerCount) + " followers • " + secondtext
                    verifyLogo_img.image = nil
                }
				
				if blackIcons.contains(thisUser.username) {
					  verifyLogo_img.image = UIImage.init(named: "verified_black")
				}
				
//                let secondtext : String = ShowCategory ? thisUser.primaryCategory.rawValue : "Tier " + String(GetTierFromFollowerCount(FollowerCount: thisUser.followerCount) ?? 0)
//
//				details.text = NumberToStringWithCommas(number: thisUser.followerCount) + " followers • " + secondtext
					if let picurl = thisUser.profilePicURL {
                        self.profilepicture.downloadAndSetImage(picurl)
                    } else {
                        self.profilepicture.image = defaultImage
                    }
					self.SetColors(isYourself: thisUser.username == Yourself.username)
			}
		}
	}
	
	func GetCatString(user: User) -> String {
		if user.categories != nil {
			if user.categories!.count > 1 {
				return "\(user.categories![0]) + \(user.categories!.count - 1)"
			} else {
				return user.categories![0]
			}
		} else {
			return ""
		}
	}
	
	func SetColors(isYourself: Bool) {
		if isYourself {
			shadow.ShadowColor = UIColor.init(red: 1, green: 121/255, blue: 8/255, alpha: 1)
			shadow.ShadowOpacity = 0.75
			shadow.ShadowRadius = 4
			shadow.backgroundColor = UIColor.init(named: "SocialYourself")
		} else {
			shadow.ShadowColor = UIColor.black
			shadow.ShadowOpacity = 0.2
			shadow.ShadowRadius =  1.75
			shadow.backgroundColor = UIColor.systemBackground
		}
	}
}

class socialTierVC: UIViewController, UITableViewDelegate, UITableViewDataSource, GlobalListener {
	
	@IBOutlet weak var tierLabel: UILabel!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//filters all users in list and makes sure only to display the users in the same account type.
		return GetSameTierUsers().count
	}
	
	var selectedUser: User?
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedUser = GetSameTierUsers()[indexPath.row]
		performSegue(withIdentifier: "ViewFromTier", sender: self)
		rankedShelf.deselectRow(at: indexPath, animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ViewFromTier" {
			if let destination = segue.destination as? ViewProfileVC {
				if let selected = selectedUser {
					destination.ThisUser = selected
				}
			}
		}
	}
	
	@IBAction func saerch(_ sender: Any) {
		Pager.GoToSearch(sender: self)
	}
	
	func GetSameTierUsers() -> [User] {
		let myTier = GetTierForInfluencer(influencer: Yourself!)
		var allpossibleresults = global.SocialData
		allpossibleresults = allpossibleresults.filter { return GetTierForInfluencer(influencer: $0) == myTier }
		allpossibleresults.sort {
			if $0.zipCode == Yourself!.zipCode && $1.zipCode != Yourself.zipCode {
				return true
			}
			if $0.zipCode != Yourself!.zipCode && $1.zipCode == Yourself.zipCode {
				return false
			}
			return $0.followerCount > $1.followerCount
		}
        return allpossibleresults
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		//Displays user's information in a cell.
		
		let cell = rankedShelf.dequeueReusableCell(withIdentifier: "socialProfileCell") as! SocialUserCell
		let thisUser : User = GetSameTierUsers()[indexPath.row]
		cell.ShowCategory = true
		cell.ThisUser = thisUser
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 86
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Yourself!.isDefaultOfferVerify {
            if GetTierFromFollowerCount(FollowerCount: Yourself!.followerCount) != nil {
                tierLabel.text = "Tier " + String(GetTierFromFollowerCount(FollowerCount: Yourself!.followerCount)! + 1 )
            }else{
               tierLabel.text = "Tier " + String(GetTierFromFollowerCount(FollowerCount: Yourself!.followerCount) ?? 1)
            }
        }else{
            tierLabel.text = "Tier " + String(GetTierFromFollowerCount(FollowerCount: Yourself!.followerCount) ?? 0)

        }
        
//		tierLabel.text = "Tier " + String(GetTierFromFollowerCount(FollowerCount: Yourself!.followerCount) ?? 0)
		rankedShelf.dataSource = self
		rankedShelf.delegate = self
		global.delegates.append(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        rankedShelf.reloadData()
    }
	
	@IBOutlet weak var rankedShelf: UITableView!
	
	var Pager: socialPageVC!
	
}
