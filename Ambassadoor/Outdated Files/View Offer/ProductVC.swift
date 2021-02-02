//
//  ProductVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/24/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import UIKit

//class ProductVC: UIViewController {
//
//    //Product Details UI's
//	@IBOutlet weak var productLabel: UILabel!
//	@IBOutlet weak var companyLabel: UILabel!
//	@IBOutlet weak var productImage: UIImageView!
//
//
//	override func viewDidLoad() {
//        super.viewDidLoad()
//		UpdatePostInformation()
//    }
//
//    //Product Detail UI's values update here
//	func UpdatePostInformation() {
//		productLabel.text = thisProduct.name
//		if let logoUrl = thisProduct.image {
//			productImage.downloadAndSetImage(logoUrl, isCircle: false)
//		} else {
//			productImage.image = UIImage(named: "shopping cart")
//
//		}
//
//		companyLabel.text = "by " + companyname
//	}
//
//	@IBAction func dismiss(_ sender: Any) {
//		_ = navigationController?.popViewController(animated: true)
//	}
//
//    //open product buy page
//	@IBAction func buyButton(_ sender: Any) {
//		if let url = URL(string: thisProduct.buy_url) {
//			UIApplication.shared.open(url, options: [:])
//		}
//	}
//
//    //open google for product name details search
//	@IBAction func GoogleIt(_ sender: Any) {
//		GoogleSearch(query: thisProduct.name)
//	}
//
////	var thisProduct: Product!
//	var companyname: String!
//
//}
