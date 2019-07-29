//
//  ProductVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/24/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class ProductVC: UIViewController {

	@IBOutlet weak var productLabel: UILabel!
	@IBOutlet weak var companyLabel: UILabel!
	@IBOutlet weak var productImage: UIImageView!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		UpdatePostInformation()
    }
	
	func UpdatePostInformation() {
		productLabel.text = thisProduct.name
		if let logoUrl = thisProduct.image {
			productImage.downloadAndSetImage(logoUrl, isCircle: false)
		} else {
			productImage.image = UIImage(named: "shopping cart")
			
		}
		
		companyLabel.text = "by " + companyname
	}
	
	@IBAction func dismiss(_ sender: Any) {
		_ = navigationController?.popViewController(animated: true)
	}
	
	@IBAction func buyButton(_ sender: Any) {
		if let url = URL(string: thisProduct.buy_url) {
			UIApplication.shared.open(url, options: [:])
		}
	}
	
	@IBAction func GoogleIt(_ sender: Any) {
		GoogleSearch(query: thisProduct.name)
	}
	
	var thisProduct: Product!
	var companyname: String!

}
