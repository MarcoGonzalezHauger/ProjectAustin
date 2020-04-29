//
//  ViewBusinessVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 29/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ViewBusinessVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var mission: UILabel!
    @IBOutlet weak var website: UIButton!
    @IBOutlet weak var offerTable: UITableView!
    
    @IBOutlet weak var offerStatus: UILabel!
    
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    
    var businessDatail: CompanyDetails?
    var fromSearch: Bool?
    
    var followOfferList = [allOfferObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setData()
        
    }
    
    func setData() {
        
        if !fromSearch!{
            self.offerTable.isHidden = true
            self.offerStatus.isHidden = true
        }
        
        if let businessData = businessDatail{
            if let picurl = businessData.logo {
                self.companyLogo.downloadAndSetImage(picurl)
            } else {
                self.companyLogo.UseDefaultImage()
            }
            
            self.companyName.text = businessData.name
            self.mission.text = businessData.mission
            //self.website.setTitle(businessData.website, for: .normal)
                        
            if let url = URL.init(string: businessData.website!){
                
                if let host = url.host{
                   self.website.setTitle(host, for: .normal)
                }else{
                    self.getDomainFromUnFormatedUrl(businessData: businessData)
                }
            }else{
                    self.getDomainFromUnFormatedUrl(businessData: businessData)
            }
        }
    }
    
    func getDomainFromUnFormatedUrl(businessData: CompanyDetails) {
        if businessData.website!.starts(with: "https://"){
            let websiteString = businessData.website!

            let removedString = websiteString.replacingOccurrences(of: "https://", with: "")

            let stringPool = removedString.components(separatedBy: "/")

            self.website.setTitle(stringPool.first!, for: .normal)
        }else if businessData.website!.starts(with: "http://"){
            let websiteString = businessData.website!

            let removedString = websiteString.replacingOccurrences(of: "http://", with: "")

            let stringPool = removedString.components(separatedBy: "/")

            self.website.setTitle(stringPool.first!, for: .normal)
        }else{
            let stringPool = businessData.website!.components(separatedBy: "/")
             self.website.setTitle(stringPool.first!, for: .normal)
        }
    }
    
    func getFollowing(businessData: CompanyDetails) {
        
        getOfferByBusiness(userId: businessData.userId!) { (status, offers) in
            
            if status{
                
                self.followOfferList = offers
                
                self.offerStatus.text = "Availabe Offers"
                self.offerTable.isHidden = false
                
                self.tableviewHeight.constant = CGFloat(((offers.count) * 110) + 25)
                
                self.offerTable.updateConstraints()
                self.offerTable.layoutIfNeeded()
                
                self.offerTable.delegate = self
                self.offerTable.dataSource = self
                
                DispatchQueue.main.async {
                    self.offerTable.reloadData()
                }
            }else{
                self.offerStatus.text = "No availabe offers"
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
//        //self.performSegue(withIdentifier: "FromFollowedOfferSegue", sender: followOfferList[indexPath.row])
//        let allOfferObj = followOfferList[indexPath.row]
//        if allOfferObj.isAccepted{
//        offerVariation = .inProgress
//        }else{
//        offerVariation = .canBeAccepted
//        }
//        self.performSegue(withIdentifier: "FromFollowedToOV", sender: followOfferList[indexPath.row].offer)
//        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}