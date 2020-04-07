//
//  BusinessInfluencerVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit



class BusinessInfluencerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var UserTable: UITableView!
    
    var totalUserData = [AnyObject]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if global.SocialData.count != 0 {
            if global.BusinessUser.count != 0 {
                
                self.totalUserData.append(contentsOf: global.BusinessUser)
                self.totalUserData.append(contentsOf: global.SocialData)
                self.totalUserData.shuffle()
                DispatchQueue.main.async {
                    self.UserTable.reloadData()
                }
            }else{
                
                _ = GetAllUsers(completion: { (users) in
                    global.SocialData = users
                    
                    self.totalUserData.append(contentsOf: global.BusinessUser)
                    self.totalUserData.append(contentsOf: global.SocialData)
                    self.totalUserData.shuffle()
                    DispatchQueue.main.async {
                        self.UserTable.reloadData()
                    }
                    
                })
                
            }
        }else{
            
            _ = GetAllBusiness(completion: { (business) in
                
                global.BusinessUser = business
                
                _ = GetAllUsers(completion: { (users) in
                    global.SocialData = users
                    
                    self.totalUserData.append(contentsOf: global.BusinessUser)
                    self.totalUserData.append(contentsOf: global.SocialData)
                    self.totalUserData.shuffle()
                    DispatchQueue.main.async {
                        self.UserTable.reloadData()
                    }
                    
                    
                })
                
            })
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalUserData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if ((self.totalUserData[indexPath.row] as? User) != nil){
            let identifier = "InfluencerResult"
            
            var cell = UserTable.dequeueReusableCell(withIdentifier: identifier) as? InfluencerTVC

            if cell == nil {
                let nib = Bundle.main.loadNibNamed("InfluencerTVC", owner: self, options: nil)
                cell = nib![0] as? InfluencerTVC
            }
            cell!.userData = (self.totalUserData[indexPath.row] as! User)
            
            return cell!
        }else{
        
        let identifier = "BusinessResult"
        
        var cell = UserTable.dequeueReusableCell(withIdentifier: identifier) as? BusinessUserTVC

        if cell == nil {
            let nib = Bundle.main.loadNibNamed("BusinessUserTVC", owner: self, options: nil)
            cell = nib![0] as? BusinessUserTVC
        }
        cell!.businessDatail = (self.totalUserData[indexPath.row] as! CompanyDetails)
        
        return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        let user = self.totalUserData[indexPath.row]
        
        if ((user as? User) != nil){
        return 80.0
        }else{
        return 150.0
        }
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
