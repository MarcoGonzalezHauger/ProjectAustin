//
//  ViewBusinessVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 29/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ViewBusinessVC: UIViewController, UITableViewDataSource, UITableViewDelegate, FollowerButtonDelegete {
	
	var delegate: followUpdateDelegate?
    
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var mission: UILabel!
    @IBOutlet weak var website: UIButton!
    @IBOutlet weak var offerTable: UITableView!
	@IBOutlet weak var webShadowView: ShadowView!
	
    @IBOutlet weak var offerStatus: UILabel!
    
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    
    var businessDatail: CompanyDetails?
    var basicBusinessDetails: BasicBusiness?
    
    var fromSearch: Bool?
    
    var followOfferList = [Offer]()
    var offerVariation: OfferVariation?
	@IBOutlet weak var followButton: FollowButtonRegular!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setData()
		
        
		followButton.delegate = self
		followButton.isBusiness = true
    }
	
	func isFollowingChanged(sender: AnyObject, newValue: Bool) {
        if let ThisUser = self.businessDatail{
		if newValue {
			//FOLLOW
            var followingList = Yourself.businessFollowing!
			if !(followingList.contains(ThisUser.userId!)) {
				followingList.append(ThisUser.userId!)
			}
            Yourself.businessFollowing = followingList
            updateBusinessFollowingList(company: ThisUser, userID: ThisUser.userId!, ownUserID: Yourself)
            updateFollowingFollowerBusinessUser(user: ThisUser, identifier: "business")
		} else {
			//UNFOLLOW
            var followingList = Yourself.businessFollowing
            if let i = followingList?.firstIndex(of: ThisUser.userId!){
                followingList?.remove(at: i)
                Yourself.businessFollowing = followingList
                updateBusinessFollowingList(company: ThisUser, userID: ThisUser.userId!, ownUserID: Yourself)
                removeFollowingFollowerBusinessUser(user: ThisUser)
                
            }
		}
		delegate?.followingUpdated()
        }else if let ThisUser = self.basicBusinessDetails{
            
            if newValue {
                //FOLLOW
                var followingList = Myself.basic.followingBusinesses
                if !(followingList.contains(ThisUser.businessId)) {
                    followingList.append(ThisUser.businessId)
                }
                Myself.basic.followingBusinesses = followingList
                updateBasicInfluencersBusinessFollowingList(userId: Myself.userId, followlist: followingList)
                
                var followedByList = ThisUser.followedBy
                if !(followedByList.contains(Myself.userId)) {
                    followedByList.append(Myself.userId)
                }
                self.basicBusinessDetails?.followedBy = followedByList
                updateBasicBusinessFollowedByList(businessId: ThisUser.businessId, followedBy: followedByList)
               
            } else {
                //UNFOLLOW
                var followingList = Myself.basic.followingBusinesses
                if let i = followingList.firstIndex(of: ThisUser.businessId){
                    followingList.remove(at: i)
                    Myself.basic.followingBusinesses = followingList
                    updateBasicInfluencersBusinessFollowingList(userId: Myself.userId, followlist: followingList)
                    
                }
                
                var followedByList = ThisUser.followedBy
                if let i = followedByList.firstIndex(of: Myself.userId){
                    followedByList.remove(at: i)
                    self.basicBusinessDetails?.followedBy = followedByList
                    updateBasicBusinessFollowedByList(businessId: ThisUser.businessId, followedBy: followedByList)
                }
            }
            delegate?.followingUpdated()
            
        }
	}
	
	@IBOutlet weak var officialLabel: UILabel!
	@IBOutlet weak var reportButton: UIButton!
	
    func setData() {
		if !fromSearch!{
            self.offerTable.isHidden = true
            self.offerStatus.isHidden = true
		}
        
        if let businessData = businessDatail{
			if fromSearch!{
				getFollowing(businessData: businessData)
			}
			
			reportButton.isHidden = businessData.isOfficialAmbassadoorAccount
			officialLabel.isHidden = !businessData.isOfficialAmbassadoorAccount
			
			followButton.isFollowing = (Yourself.businessFollowing?.contains(businessData.userId!))!
            if let picurl = businessData.logo {
                self.companyLogo.downloadAndSetImage(picurl)
            } else {
                self.companyLogo.UseDefaultImage()
            }
            
            self.companyName.text = businessData.name
            self.mission.text = businessData.mission
            //self.website.setTitle(businessData.website, for: .normal)
                        
            if let url = URL.init(string: businessData.website!){
                
                if url.host != nil{
                    self.getDomainFromUnFormatedUrl(website: businessData.website!)
                }else{
                    self.getDomainFromUnFormatedUrl(website: businessData.website!)
                }
            }else{
                self.getDomainFromUnFormatedUrl(website: businessData.website!)
            }
        }else if let basicInfo = basicBusinessDetails{
            
            followButton.isFollowing = Myself.basic.followingBusinesses.contains(basicInfo.businessId)
            self.companyLogo.downloadAndSetImage(basicInfo.logoUrl)
            self.companyName.text = basicInfo.name
            self.mission.text = basicInfo.mission
            //self.website.setTitle(businessData.website, for: .normal)
            
            if let url = URL.init(string: basicInfo.website){
                
                if url.host != nil{
                    self.getDomainFromUnFormatedUrl(website: basicInfo.website)
                }else{
                    self.getDomainFromUnFormatedUrl(website: basicInfo.website)
                }
            }else{
                self.getDomainFromUnFormatedUrl(website: basicInfo.website)
            }
            
        }
    }
	
	@IBAction func websiteClicked(_ sender: Any) {
		if let urlString = businessDatail?.website {
			if let url = URL(string: urlString) {
				if #available(iOS 10.0, *) {
					UIApplication.shared.open(url, options: [:], completionHandler: nil)
				} else {
					UIApplication.shared.openURL(url)
				}
			} else {
				MakeShake(viewToShake: webShadowView)
			}
        }else if let urlString = basicBusinessDetails?.website{
            
            if let url = URL(string: urlString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                MakeShake(viewToShake: webShadowView)
            }
            
        }else {
			MakeShake(viewToShake: webShadowView)
		}
	}
	
    func getDomainFromUnFormatedUrl(website: String) {
		var websiteString = website.lowercased()
		var result = ""
		while(websiteString.contains("///")) {
			websiteString = websiteString.replacingOccurrences(of: "///", with: "//")
		}
        if websiteString.starts(with: "https://"){

            let removedString = websiteString.replacingOccurrences(of: "https://", with: "")

            let stringPool = removedString.components(separatedBy: "/")

            result = stringPool.first!
        }else if websiteString.starts(with: "http://"){

            let removedString = websiteString.replacingOccurrences(of: "http://", with: "")

            let stringPool = removedString.components(separatedBy: "/")
			
            result = stringPool.first!
		} else if websiteString == "" {
			self.website.setTitle(" No Website", for: .normal)
			self.website.isEnabled = false
			return
        }else{
			print(websiteString)
			let stringPool = websiteString.components(separatedBy: "/")
            result = stringPool.first!
        }
		
		print("before: \(result)")
		
		switch result.split(separator: ".").count {
		case 1: result = "www.\(result).com"
		case 2: result = "www.\(result)"
		default: break
		}
		
		
		self.website.setTitle(" " + result, for: .normal)
    }
    
    func getFollowing(businessData: CompanyDetails) {
        
        getOfferByBusiness(userId: businessData.userId!) { (status, offers) in
            
			if offers.count != 0 {
                
                self.followOfferList = offers
                
                self.offerStatus.text = "Avaliable Offers"
                self.offerTable.isHidden = false
				
//				for o in offers {
//					print(o.offer_ID + " + " + (o.accepted ?? []).joined(separator: ", "))
//				}
                
				self.tableviewHeight.constant = CGFloat((CGFloat(offers.count) * unviersalOfferHeight) + 10)
                
                self.offerTable.updateConstraints()
                self.offerTable.layoutIfNeeded()
                
                self.offerTable.delegate = self
                self.offerTable.dataSource = self
                
                DispatchQueue.main.async {
                    self.offerTable.reloadData()
                }
            }else{
				self.offerStatus.text = "No avaliable offers."
                self.offerTable.isHidden = true
            }
            
        }
    }
    
    @IBAction func dismissAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followOfferList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "followedoffer"
        
        var cell = offerTable.dequeueReusableCell(withIdentifier: identifier) as? StandardOfferCell
        
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("StandardOfferCell", owner: self, options: nil)
            cell = nib![0] as? StandardOfferCell
        }
        cell!.offer = followOfferList[indexPath.row]
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return unviersalOfferHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        self.offerVariation = .canBeAccepted
        self.performSegue(withIdentifier: "FromOBtoVO", sender: followOfferList[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
//        let allOfferObj = followOfferList[indexPath.row]
//        if allOfferObj.isAccepted{
//        offerVariation = .inProgress
//        }else{
//        offerVariation = .canBeAccepted
//        }
//        self.performSegue(withIdentifier: "FromFollowedToOV", sender: followOfferList[indexPath.row].offer)
//        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FromOBtoVO" {
         //guard let newviewoffer = viewoffer else { return }
         let destination = (segue.destination as! StandardNC).topViewController as! OfferViewerVC
        
             destination.offer = sender as? Offer
		} else if segue.identifier == "toReporterFromBV" {
			let destination	= segue.destination as! ReporterFeature
			destination.TargetCompany = businessDatail
		}
    }
    

}
