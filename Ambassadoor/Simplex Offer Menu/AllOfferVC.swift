//
//  AllOfferVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 06/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class AllOfferVC: UIViewController,UITableViewDataSource, UITableViewDelegate, OfferResponse {
    func OfferAccepted(offer: Offer) {
        
    }
    
    @IBOutlet weak var allOfferTable: UITableView!
    
    var allOfferList = [allOfferObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllOffer { (status, allOffer) in
            
            if status{
                self.allOfferList = allOffer!
                DispatchQueue.main.async {
                    self.allOfferTable.reloadData()
                }
            }
            
        }

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allOfferList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "standardoffer"
        
        var cell = allOfferTable.dequeueReusableCell(withIdentifier: identifier) as? StandardOfferCell
        
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("StandardOfferCell", owner: self, options: nil)
            cell = nib![0] as? StandardOfferCell
        }
        
        cell!.offer = allOfferList[indexPath.row].offer
        cell!.isFiltered = allOfferList[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        self.performSegue(withIdentifier: "ViewOfferSegue", sender: allOfferList[indexPath.row].offer)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewOfferSegue" {
        //guard let newviewoffer = viewoffer else { return }
        let destination = segue.destination
        if let destination = (destination as! UINavigationController).topViewController as? OfferVC {
            destination.delegate = self
            destination.ThisOffer = sender as? Offer


        }
        }
    }
    

}