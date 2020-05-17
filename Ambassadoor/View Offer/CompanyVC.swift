//
//  CompanyVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/24/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import UIKit

class CompanyVC: UIViewController {

    //Company Detail UI's
	@IBOutlet weak var companyLogo: UIImageView!
	@IBOutlet weak var companyNameLabel: UILabel!
	@IBOutlet weak var CompanyMission: UILabel!
	@IBOutlet weak var CompanyDescription: UITextView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		if let logoUrl = thisCompany.logo {
			companyLogo.downloadAndSetImage(logoUrl, isCircle: false)
		} else {
			companyLogo.image = UIImage(named: "defaultcompany")
		}
		companyNameLabel.text = thisCompany.name
		CompanyMission.text = thisCompany.mission
		CompanyDescription.text = thisCompany.description
		
    }
	
	@IBAction func dismissed(_ sender: Any) {
		_ = navigationController?.popViewController(animated: true)
	}
	
    //open company website here
	@IBAction func openwebsite(_ sender: Any) {
		if let url = URL(string: thisCompany.website) {
			UIApplication.shared.open(url, options: [:])
		}
	}
	//open google search for company name
	@IBAction func GoogleIt(_ sender: Any) {
		GoogleSearch(query: thisCompany.name)
	}
	
	var thisCompany: Company!

}
