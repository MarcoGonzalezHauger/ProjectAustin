//
//  FilteredOfferVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 03/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class StandardOfferCell: UITableViewCell {
    
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
                self.logo.image = defaultImage
            }
            
            self.cashOut.text = NumberToPrice(Value: offerDetail.cashPower!)
            
            self.companyName.text = offerDetail.company?.name
            
//            self.progressView.frame.size.width = self.frame.size.width * CGFloat((offerDetail.cashPower!/offerDetail.money))
                self.progressViewWidth.constant = self.frame.size.width * CGFloat((offerDetail.cashPower!/offerDetail.money))
                self.progressView.backgroundColor = .yellow
                self.updateConstraints()
                self.layoutIfNeeded()
                
        }
            
        }
    }
    
    var isFiltered: allOfferObject? {
        didSet{
            if let filter = isFiltered {
                if filter.isFiltered{
                    
                    self.progressViewWidth.constant = self.frame.size.width * CGFloat((filter.offer.cashPower!/filter.offer.money))
                    self.progressView.backgroundColor = .yellow
                    self.updateConstraints()
                    self.layoutIfNeeded()
                    
                }else{
                    
                    self.progressViewWidth.constant = self.frame.size.width
                    self.progressView.backgroundColor = .red
                    self.updateConstraints()
                    self.layoutIfNeeded()
                    
                }
            }
        }
    }
    
    
}

class FilteredOfferVC: UIViewController, UITableViewDelegate, UITableViewDataSource, OfferResponse {
    func OfferAccepted(offer: Offer) {
        
    }
    
    
    @IBOutlet weak var filteredOfferTable: UITableView!
    
    var filteredOfferList = [allOfferObject]()
    var offerVariation: OfferVariation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFilteredOffer { (status, offers) in
            
            self.filteredOfferList = offers!
            
            DispatchQueue.main.async {
                self.filteredOfferTable.reloadData()
            }
            
        }
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredOfferList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "standardoffer"
        
        let cell = filteredOfferTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! StandardOfferCell
        
        cell.offer = filteredOfferList[indexPath.row].offer
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		return unviersalOfferHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let allOfferObj = filteredOfferList[indexPath.row]
        if allOfferObj.isAccepted{
        offerVariation = .inProgress
        }else{
        offerVariation = .canBeAccepted
        }
        //FromFilteredToOV
        //self.performSegue(withIdentifier: "FromFilterOfferSegue", sender: filteredOfferList[indexPath.row].offer)
        self.performSegue(withIdentifier: "FromFilteredToOV", sender: filteredOfferList[indexPath.row].offer)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
        if segue.identifier == "FromFilterOfferSegue" {
        //guard let newviewoffer = viewoffer else { return }
        let destination = segue.destination
        if let destination = (destination as! UINavigationController).topViewController as? OfferVC {
            destination.delegate = self
            destination.ThisOffer = sender as? Offer


        }
        }
        */
        
        if segue.identifier == "FromFilteredToOV" {
            //guard let newviewoffer = viewoffer else { return }
             let destination = segue.destination as! OfferViewerVC
            
                 destination.offerVariation = offerVariation!
                 destination.offer = sender as? Offer
             }
        
    }
    

}
