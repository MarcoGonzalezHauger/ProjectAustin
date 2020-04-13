//
//  OfferHistoryVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/11/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class OldOfferCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
}

class OfferHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var shelf: UITableView!
    
    var PreviousOffers: [Offer] = [] {
        didSet {
            shelf.reloadData()
        }
    }
    
    @IBAction func dismissed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 98
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shelf.delegate = self
        shelf.dataSource = self
        PreviousOffers = global.OffersHistory
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thisOffer = PreviousOffers[indexPath.row]
        let cell = shelf.dequeueReusableCell(withIdentifier: "OldOffer") as! OldOfferCell
        
        cell.nameLabel.text = thisOffer.company?.name ?? ""
        cell.completedLabel.text = DateToAgo(date: thisOffer.allPostsConfirmedSince!)
        cell.infoLabel.text = "\(thisOffer.posts.count) post\(thisOffer.posts.count == 1 ? "" : "s") for \(NumberToPrice(Value: thisOffer.money))"
        
//        cell.nameLabel.text = "This feature will be avaliable soon."
//        cell.completedLabel.text = ""
//        cell.infoLabel.text = ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PreviousOffers.count
//        return 1
    }

}
