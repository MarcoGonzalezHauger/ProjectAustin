//
//  CompanyVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/24/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class CompanyVC: UIViewController {

	@IBOutlet weak var companyLogo: UIImageView!
	@IBOutlet weak var companyNameLabel: UILabel!
	@IBOutlet weak var CompanyMission: UILabel!
	@IBOutlet weak var CompanyDescription: UITextView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		companyLogo.image = thisCompany.logo ?? UIImage(named: "defaultcompany")
		companyNameLabel.text = thisCompany.name
		CompanyMission.text = thisCompany.mission
		CompanyDescription.text = thisCompany.description
		
    }
	
	@IBAction func dismissed(_ sender: Any) {
		_ = navigationController?.popViewController(animated: true)
	}
	
	@IBAction func openwebsite(_ sender: Any) {
		if let url = URL(string: thisCompany.website) {
			UIApplication.shared.open(url, options: [:])
		}
	}
	
	@IBAction func GoogleIt(_ sender: Any) {
		GoogleSearch(query: thisCompany.name)
	}
	
	var thisCompany: Company!

}
