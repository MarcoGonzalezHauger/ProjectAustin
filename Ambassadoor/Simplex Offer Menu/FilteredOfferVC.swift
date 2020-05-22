//
//  FilteredOfferVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 03/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit



class FilteredOfferVC: UIViewController, UITableViewDelegate, UITableViewDataSource, OfferResponse, refreshDelegate {
	
	func refreshOfferDate() {
		filteredOfferAction(timer: nil)
	}
	
    func OfferAccepted(offer: Offer) {
        
    }
    
    @IBOutlet weak var filteredOfferTable: UITableView!
    
    var filteredOfferList = [Offer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		filteredOfferTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        self.filteredOfferAction(timer: nil)
        
		refreshDelegates.append(self)
		
        // Do any additional setup after loading the view.
    }
    
    @objc func filteredOfferAction(timer: Timer?) {
        getObserveFilteredOffer { (status, offers) in
            
            self.filteredOfferList = offers
            
            DispatchQueue.main.async {
                self.filteredOfferTable.reloadData()
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredOfferList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let identifier = "standardoffer"
        
        //let cell = filteredOfferTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! StandardOfferCell
		var cell: StandardOfferCell!
        
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("StandardOfferCell", owner: self, options: nil)
            cell = nib![0] as? StandardOfferCell
        }
		
        cell.offer = filteredOfferList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		return unviersalOfferHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //FromFilteredToOV
        //self.performSegue(withIdentifier: "FromFilterOfferSegue", sender: filteredOfferList[indexPath.row].offer)
        self.performSegue(withIdentifier: "FromFilteredToOV", sender: filteredOfferList[indexPath.row])
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
			let destination = (segue.destination as! StandardNC).topViewController as! OfferViewerVC
                 destination.offer = sender as? Offer
				destination.thisParent = self
             }
        
    }
    

}
