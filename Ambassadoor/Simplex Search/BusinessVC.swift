//
//  BusinessVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class BusinessUserTVC: UITableViewCell {
    @IBOutlet weak var businessLogo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mission: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    var businessDatail: CompanyDetails? {
        didSet{
            if let business = businessDatail{
                
                if let picurl = business.logo {
                    self.businessLogo.downloadAndSetImage(picurl)
                } else {
                    self.businessLogo.image = defaultImage
                }
                
                self.name.text = business.name
                self.mission.text = business.mission
                
                if (Yourself.businessFollowing?.contains(businessDatail!.userId!))!{
                    
                    self.followBtn.setTitle("Unfollow", for: .normal)
                    
                }else{
                    
                    self.followBtn.setTitle("Follow", for: .normal)
                    
                }
                
            }
        }
    }
}

class BusinessVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var businessUserTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        _ = GetAllBusiness(completion: { (business) in
            
            global.BusinessUser = business
            
            DispatchQueue.main.async {
                self.businessUserTable.reloadData()
            }
            
            
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return global.BusinessUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "BusinessResult"
        
        var cell = businessUserTable.dequeueReusableCell(withIdentifier: identifier) as? BusinessUserTVC

        if cell == nil {
            let nib = Bundle.main.loadNibNamed("BusinessUserTVC", owner: self, options: nil)
            cell = nib![0] as? BusinessUserTVC
        }
        cell!.businessDatail = global.BusinessUser[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 150.0
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
