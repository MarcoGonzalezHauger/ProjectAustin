//
//  InProgressVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 09/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class InProgressTVC: UITableViewCell{
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var postImgOne: UIImageView!
    @IBOutlet weak var postOne: UILabel!
    
    @IBOutlet weak var postImgTwo: UIImageView!
    @IBOutlet weak var postImgTwoHeight: NSLayoutConstraint!
    @IBOutlet weak var postTwo: UILabel!
    @IBOutlet weak var postTwoHeight: NSLayoutConstraint!
    
    @IBOutlet weak var postImgThree: UIImageView!
    @IBOutlet weak var postImgThreeHeight: NSLayoutConstraint!
    @IBOutlet weak var postThree: UILabel!
    @IBOutlet weak var postThreeHeight: NSLayoutConstraint!
    
    @IBOutlet weak var paymentReceiveAt: UILabel!
    @IBOutlet weak var progrssView: ShadowView!
    
    var offer: Offer?{
        didSet{
            if let offerValue = offer{
                
                if let picurl = offerValue.company?.logo {
                    self.companyLogo.downloadAndSetImage(picurl)
                } else {
                    self.companyLogo.image = defaultImage
                }
                
                if let incresePay = offerValue.incresePay {
                    
                    let pay = calculateCostForUser(offer: offerValue, user: Yourself, increasePayVariable: incresePay)
                    
                    self.amount.text = NumberToPrice(Value: pay)
                    
                }else{
                    
                    let pay = calculateCostForUser(offer: offerValue, user: Yourself)
                    self.amount.text = NumberToPrice(Value: pay)
                }
                
                self.name.text = offerValue.company!.name
                
            }
        }
    }
    
    
}

class InProgressVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allInprogressOffer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "inprogresscell"
        let cell = inProgressTable.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! InProgressTVC
        cell.offer = allInprogressOffer[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 200.0
    }
    
    @IBOutlet weak var inProgressTable: UITableView!
    
    var allInprogressOffer = [Offer]()

    override func viewDidLoad() {
        super.viewDidLoad()
        getAcceptedOffers { (status, offers) in
            
            if status{
                self.allInprogressOffer = offers
                DispatchQueue.main.async {
                    self.inProgressTable.reloadData()
                }
            }
            
        }
        // Do any additional setup after loading the view.
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
