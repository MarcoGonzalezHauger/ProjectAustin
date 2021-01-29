//
//  ViewPostVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/24/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import UIKit
import Firebase
import SDWebImage

//class ProductPreview: UICollectionViewCell {
//	@IBOutlet weak var ProductImage: UIImageView!
//	@IBOutlet weak var ProductLabel: UILabel!
//}

//Cheers, to innovation!

class ViewPostVC: UIViewController {
	
	@IBOutlet weak var IncludeLabel: UILabel!
	
//	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//		var returnValue: Int
//		if let products : [Product] = ThisPost.products {
//			returnValue = products.count
//		} else {
//			returnValue = 0
//		}
//		IncludeLabel.isHidden = returnValue == 0
//		return returnValue
//	}
//
//	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//		return CGSize(width: (MasterView.bounds.width / 2) - 1.25, height: (MasterView.bounds.width / 2) - 1.25	)
//	}
//
//	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//		let cell = grid.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductPreview
//		if let logoUrl = ThisPost.products![indexPath.item].image {
////			cell.ProductImage.downloadAndSetImage(logoUrl, isCircle: false)
//            cell.ProductImage.sd_setImage(with: URL.init(string: logoUrl), placeholderImage: UIImage(named: "shopping cart"))
//
//		} else {
//			cell.ProductImage.image = UIImage(named: "shopping cart")
//		}
//
//		cell.ProductLabel.text = ThisPost.products![indexPath.item].name
//		return cell
//	}
	
	@IBOutlet var MasterView: UIView!

//	var producttosend: Product!
//
//	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//		producttosend = ThisPost.products![indexPath.item]
//		performSegue(withIdentifier: "toProduct", sender: self)
//		grid.selectItem(at: nil, animated: true, scrollPosition: .top)
//	}
	
    //next VC pass product value and companyname
//	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		if let destination = segue.destination as? ProductVC {
//			destination.thisProduct = producttosend
//			destination.companyname = companystring
//		}
//	}

    //post detail UI's
	@IBOutlet weak var postimage: UIImageView!
	@IBOutlet weak var postLabel: UILabel!
	@IBOutlet weak var rulesText: UITextView!
	@IBOutlet weak var captionText: UITextView!
	@IBOutlet weak var captionHeader: UILabel!
    

	override func viewDidLoad() {
        super.viewDidLoad()
//		grid.dataSource = self
//		grid.delegate = self
//
//		gridHeight.constant = grid.collectionViewLayout.collectionViewContentSize.height
//		ViewInsideStackHeight.constant = 333 + grid.collectionViewLayout.collectionViewContentSize.height
		//grid.reloadData()
		UpdatePostInformation()
    }
//	@IBOutlet weak var ViewInsideStackHeight: NSLayoutConstraint!
//	@IBOutlet weak var gridHeight: NSLayoutConstraint!
//
    //post Detail UI's values update here
	func UpdatePostInformation() {
		print("UpdatePostInformation() called")
		
		postimage.image = PostTypeToIcon(posttype: .SinglePost)
		postLabel.text = "Post \(selectedIndex ?? 1)"
		rulesText.text = ThisPost.instructions
		
		var captionString = ""
		
		for p in ThisPost.keywords {
			captionString += "\(p)\n"
		}
		
		for h in ThisPost.hashtags {
			captionString += "#\(h)\n"
		}
		
		captionString += "#ad"
		
		print(captionString)
		
		captionText.text = captionString
        
        //If offer has denied means we will show denied message here
        if ThisPost.status == "denied" {
            if let msg = ThisPost.denyMessage {
                self.showStandardAlertDialog(title: "Alert", msg: msg)
            }
        }
	}
	
	@IBAction func Dismiss(_ sender: Any) {
		_ = navigationController?.popViewController(animated: true)
	}
	
	var ThisPost: Post!
	var companystring: String!
    var isPostEnable = false
    var offer_ID: String!
    var selectedIndex:Int!

}
