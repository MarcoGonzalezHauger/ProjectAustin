//
//  FollowedOfferVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class FollowedOfferVC: UIViewController, UITableViewDelegate, UITableViewDataSource, OfferResponse, refreshDelegate {
    
    func refreshOfferDate() {
        followerCompaniesAction(timer: nil)
    }
    
    
    func OfferAccepted(offer: Offer) {
        
    }
    
    @IBOutlet weak var offerTable: UITableView!
    
    var followOfferList = [Offer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        offerTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        
        if global.followOfferList.count != 0 {
            self.followOfferList = global.followOfferList
            DispatchQueue.main.async {
                self.offerTable.reloadData()
            }
            // Do any additional setup after loading the view.
        }
        //		Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.followerCompaniesAction(timer:)), userInfo: nil, repeats: false)
        self.followerCompaniesAction(timer: nil)
        refreshDelegates.append(self)
    }
    
    @objc func followerCompaniesAction(timer: Timer?) {
        getObserveFollowerCompaniesOffer() { (status, offers) in
            
            if status {
                self.followOfferList = offers
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
        cell!.offer = followOfferList[indexPath.row]
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //self.performSegue(withIdentifier: "FromFollowedOfferSegue", sender: followOfferList[indexPath.row])
        let offerValue = followOfferList[indexPath.row]
        if offerValue.isDefaultOffer{
            self.performSegue(withIdentifier: "FromFollowedToOV", sender: offerValue)
            tableView.deselectRow(at: indexPath, animated: true)
        }else{
            let payCheck = getofferPayOfuser(offerValue: offerValue, user: Yourself)
            if payCheck != 0 {
                self.performSegue(withIdentifier: "FromFollowedToOV", sender: offerValue)
                tableView.deselectRow(at: indexPath, animated: true)
            }else{
                self.showStandardAlertDialog(title: "You have low likes", msg: "Your pay for this offer is very low. Increse your instagram's post likes and try again later") { (alert) in
                    
                }
            }
        }
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
            
            destination.offer = sender as? Offer
            destination.thisParent = self
        }
        
    }
    
    
}
