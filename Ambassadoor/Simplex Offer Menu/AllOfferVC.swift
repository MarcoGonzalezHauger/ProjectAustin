//
//  AllOfferVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 06/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

let unviersalOfferHeight: CGFloat = 77.5

class AllOfferVC: UIViewController,UITableViewDataSource, UITableViewDelegate, OfferResponse, refreshDelegate {
	
	func refreshOfferDate() {
		allOfferAction(timer: nil)
	}	
	
    func OfferAccepted(offer: Offer) {
        
    }
    
    @IBOutlet weak var allOfferTable: UITableView!
    
    var allOfferList = [Offer]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
		allOfferTable.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
		
        if global.allOfferList.count != 0{
            self.allOfferList = global.allOfferList
            DispatchQueue.main.async {
                self.allOfferTable.reloadData()
            }
        }
        
//        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.allOfferAction(timer:)), userInfo: nil, repeats: false)
		self.allOfferAction(timer: nil)
		refreshDelegates.append(self)
        // Do any additional setup after loading the view.
    }
    
    @objc func allOfferAction(timer: Timer?) {
        getObserveAllOffer { (status, allOffer) in
            
            if status{
                self.allOfferList = allOffer
                DispatchQueue.main.async {
                    self.allOfferTable.reloadData()
                }
            }
            
        }
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
        
        cell!.offer = allOfferList[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		return unviersalOfferHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        //FromAllToOV
        //self.performSegue(withIdentifier: "ViewOfferSegue", sender: allOfferList[indexPath.row].offer)
        self.performSegue(withIdentifier: "FromAllToOV", sender: allOfferList[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ViewOfferSegue" {
//        //guard let newviewoffer = viewoffer else { return }
//        let destination = segue.destination
//        if let destination = (destination as! UINavigationController).topViewController as? OfferVC {
//            destination.delegate = self
//            destination.ThisOffer = sender as? Offer
//
//
//        }
//        }
        if segue.identifier == "FromAllToOV" {
         //guard let newviewoffer = viewoffer else { return }
         let destination = (segue.destination as! StandardNC).topViewController as! OfferViewerVC
        
             destination.offer = sender as? Offer
         }
    }
    

}
