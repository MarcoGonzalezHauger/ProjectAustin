//
//  FollowedOfferVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class FollowedCompaniesOffer: UITableViewCell {
	
	@IBOutlet weak var logo: UIImageView!
	@IBOutlet weak var cashOut: UILabel!
	@IBOutlet weak var companyName: UILabel!
	@IBOutlet weak var progressView: ShadowView!
	
	@IBOutlet weak var progressViewWidth: NSLayoutConstraint!
	var offer: Offer?{
		didSet{
			if let offerDetail = offer{
				if let picurl = offerDetail.company?.logo {
					self.logo.downloadAndSetImage(picurl)
				} else {
					self.logo.UseDefaultImage()
				}
				
				
				let pay = calculateCostForUser(offer: offerDetail, user: Yourself)
				self.cashOut.text = NumberToPrice(Value: pay)
				self.progressViewWidth.constant = self.frame.size.width * CGFloat((offerDetail.cashPower!/offerDetail.money))
				self.progressView.backgroundColor = UIColor.init(red: 1, green: 227/255, blue: 35/255, alpha: 1)
				self.companyName.text = offerDetail.company?.name
				self.updateConstraints()
				self.layoutIfNeeded()
				
			}
			
		}
	}
	
}

class FollowedOfferVC: UIViewController, UITableViewDelegate, UITableViewDataSource, OfferResponse {
    func OfferAccepted(offer: Offer) {
        
    }
    
    
    @IBOutlet weak var offerTable: UITableView!
    
    var followOfferList = [allOfferObject]()
    
    var offerVariation: OfferVariation?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		offerTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        
        if global.followOfferList.count == 0 {
        
        getFollowerCompaniesOffer(followers: Yourself.businessFollowing!) { (status, offers) in
            
            if status {
                self.followOfferList = offers!
                DispatchQueue.main.async {
                    self.offerTable.reloadData()
                }
            }
            
        }
        }else{
            self.followOfferList = global.followOfferList
            DispatchQueue.main.async {
                self.offerTable.reloadData()
        }
        // Do any additional setup after loading the view.
    }
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.followerCompaniesAction(timer:)), userInfo: nil, repeats: false)
    }
    
    @objc func followerCompaniesAction(timer: Timer?) {
        getObserveFollowerCompaniesOffer(followers: Yourself.businessFollowing!) { (status, offers) in
        
        if status {
            self.followOfferList = offers!
            DispatchQueue.main.async {
                self.offerTable.reloadData()
            }
        }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followOfferList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "followedoffer"
        
        var cell = offerTable.dequeueReusableCell(withIdentifier: identifier) as? FollowedCompaniesOffer
        
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("FollowedCompaniesOffer", owner: self, options: nil)
            cell = nib![0] as? FollowedCompaniesOffer
        }
        cell!.offer = followOfferList[indexPath.row].offer
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 110
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //self.performSegue(withIdentifier: "FromFollowedOfferSegue", sender: followOfferList[indexPath.row])
        let allOfferObj = followOfferList[indexPath.row]
        if allOfferObj.isAccepted{
        offerVariation = .inProgress
        }else{
        offerVariation = .canBeAccepted
        }
        self.performSegue(withIdentifier: "FromFollowedToOV", sender: followOfferList[indexPath.row].offer)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        /*
        if segue.identifier == "FromFollowedOfferSegue" {
            //guard let newviewoffer = viewoffer else { return }
            let destination = segue.destination
            if let destination = (destination as! UINavigationController).topViewController as? OfferVC {
                destination.delegate = self
                destination.ThisOffer = sender as? Offer


            }
            }
        */
        if segue.identifier == "FromFollowedToOV" {
        //guard let newviewoffer = viewoffer else { return }
        let destination = (segue.destination as! StandardNC).topViewController as! OfferViewerVC
       
            destination.offerVariation = offerVariation!
            destination.offer = sender as? Offer
        }
        
    }
    

}
