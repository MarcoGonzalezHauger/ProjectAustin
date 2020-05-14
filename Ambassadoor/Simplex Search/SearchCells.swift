//
//  SearchCells.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 5/12/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import UIKit

protocol followUpdateDelegate {
	func followingUpdated()
}

class BusinessUserTVC: UITableViewCell, FollowerButtonDelegete {
	
	func isFollowingChanged(sender: AnyObject, newValue: Bool) {
		if let ThisUser = businessDatail {
			if !newValue {
				//UNFOLLOWING
				var followingList = Yourself.businessFollowing
				if let i = followingList?.firstIndex(of: ThisUser.userId!){
					followingList?.remove(at: i)
					Yourself.businessFollowing = followingList
					updateBusinessFollowingList(company: ThisUser, userID: ThisUser.userId!, ownUserID: Yourself)
					removeFollowingFollowerBusinessUser(user: ThisUser)
					
				}
			}else{
				//FOLLOWING
				var followingList = Yourself.businessFollowing ?? []
				if !followingList.contains(ThisUser.userId!) {
					followingList.append(ThisUser.userId!)
				}
				Yourself.businessFollowing = followingList
				updateBusinessFollowingList(company: ThisUser, userID: ThisUser.userId!, ownUserID: Yourself)
				updateFollowingFollowerBusinessUser(user: ThisUser, identifier: "business")
			}
		}
	}
	
    @IBOutlet weak var businessLogo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mission: UILabel!
	@IBOutlet weak var BusinessButton: FollowButtonSmall!
	
    var businessDatail: CompanyDetails? {
        didSet{
            if let business = businessDatail{
                
                if let picurl = business.logo {
                    self.businessLogo.downloadAndSetImage(picurl)
                } else {
                    self.businessLogo.UseDefaultImage()
                }
                
                self.name.text = business.name
                self.mission.text = business.mission
                
				BusinessButton.isFollowing = (Yourself.businessFollowing?.contains(business.userId!))!
				BusinessButton.isBusiness = true
				BusinessButton.delegate = self
                
            }
        }
    }
}

class InfluencerTVC: UITableViewCell, FollowerButtonDelegete {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tier: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var verifyLogo_img: UIImageView!
	@IBOutlet weak var tierBox: ShadowView!
	@IBOutlet weak var followButton: FollowButtonSmall!
	
    @IBOutlet weak var leadingUserName: NSLayoutConstraint!
	
	func isFollowingChanged(sender: AnyObject, newValue: Bool) {
		if let ThisUser = userData {
			if newValue {
				//FOLLOW
				var followingList = Yourself.following
				if !followingList!.contains(ThisUser.id) {
					followingList?.append(ThisUser.id)
				}
				Yourself.following = followingList
				updateFollowingList(userID: ThisUser.id, ownUserID: Yourself)
				updateFollowingFollowerUser(user: ThisUser, identifier: "influencer")
			} else {
				//UNFOLLOW
				var followingList = Yourself.following
				if let i = followingList?.firstIndex(of: ThisUser.id){
					followingList?.remove(at: i)
					Yourself.following = followingList
					updateFollowingList(userID: ThisUser.id, ownUserID: Yourself)
					removeFollowingFollowerUser(user: ThisUser)
					
				}
			}
		}
	}
	
    var userData: User?{
        didSet{
            if let user = userData{
                tierBox.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "tiergrad")!)
                if let picurl = user.profilePicURL {
                    self.userImage.downloadAndSetImage(picurl)
                } else {
					self.userImage.UseDefaultImage()
                }
                
                //self.userName.text = "@\(user.username)"
				self.userName.text = user.name
                
                self.tier.text = String(GetTierForInfluencer(influencer: user))
                
				followButton.isFollowing = (Yourself.following?.contains(user.id))!
				followButton.isBusiness = false
				followButton.delegate = self
                
                self.followerCount.text = CompressNumber(number: Double(user.followerCount))
                self.likeCount.text = CompressNumber(number: Double(user.averageLikes ?? 0))
                
                if user.isDefaultOfferVerify {
                    verifyLogo_img.image = UIImage(named: "verify_Logo")
                    self.leadingUserName.constant = 34
                    self.updateConstraints()
                    self.layoutIfNeeded()
                } else {
                    verifyLogo_img.image = nil
                    self.leadingUserName.constant = 8
                    self.updateConstraints()
                    self.layoutIfNeeded()
                }
				
				followButton.isHidden = user.id == Yourself.id
                
                if blackIcons.contains(user.username) {
                      verifyLogo_img.image = UIImage.init(named: "verified_black")
                    self.leadingUserName.constant = 34
                    self.updateConstraints()
                    self.layoutIfNeeded()
                }
                
            }
        }
    }
    
    
}
