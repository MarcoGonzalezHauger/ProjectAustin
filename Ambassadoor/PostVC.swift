//
//  ViewPostVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/24/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit
import Firebase

class ProductPreview: UICollectionViewCell {
	@IBOutlet weak var ProductImage: UIImageView!
	@IBOutlet weak var ProductLabel: UILabel!
}

//Cheers, to innovation!

class ViewPostVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let products : [Product] = ThisPost.products else { return 0 }
		return products.count
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: (MasterView.bounds.width / 2) - 1.25, height: (MasterView.bounds.width / 2) - 1.25	)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = grid.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductPreview
		if let logoUrl = ThisPost.products![indexPath.item].image {
			cell.ProductImage.downloadAndSetImage(logoUrl, isCircle: false)
		} else {
			cell.ProductImage.image = UIImage(named: "shopping cart")
		}
		cell.ProductLabel.text = ThisPost.products![indexPath.item].name
		return cell
	}
	
	@IBOutlet var MasterView: UIView!

	var producttosend: Product!
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		producttosend = ThisPost.products![indexPath.item]
		performSegue(withIdentifier: "toProduct", sender: self)
		grid.selectItem(at: nil, animated: true, scrollPosition: .top)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? ProductVC {
			destination.thisProduct = producttosend
			destination.companyname = companystring
		}
	}

	@IBOutlet weak var postimage: UIImageView!
	@IBOutlet weak var postLabel: UILabel!
	@IBOutlet weak var rulesText: UITextView!
	@IBOutlet weak var captionText: UITextView!
	@IBOutlet weak var grid: UICollectionView!
	@IBOutlet weak var captionHeader: UILabel!
    

    func PostToInstagram() {
        if let theProfileImageUrl = ThisPost.products![0].image {
            do {
                let url = NSURL(string: theProfileImageUrl)
                let imageData = try Data(contentsOf: url! as URL)
                let image = UIImage(data: imageData)
                print(ThisPost.captionMustInclude!)
                if ThisPost.PostType == .Story {
//                    // *******
//                    let instanceOfCustomObject: CustomObject = CustomObject()
//                    instanceOfCustomObject.backgroundImage(imageData, attributionURL: ThisPost.captionMustInclude!)
                }else{
                    InstagramManager.sharedManager.postImageToInstagramWithCaption(imageInstagram: image!, instagramCaption: ThisPost.captionMustInclude!, view: self.view, completion: {(bool) in
                        if bool{
                            print("bbbb=",self.ThisPost.post_ID)
                            let prntRef  = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(self.offer_ID).child("posts")
                            prntRef.observeSingleEvent(of: .value) { (dataSnapshot) in
                                if let posts = dataSnapshot.value as? NSMutableArray{
                                    var final: [[String : Any]] = []
                                    for value in posts{
                                        var obj = value as! [String : Any]
                                        if obj["post_ID"] as! String == self.ThisPost.post_ID {
                                            obj["isConfirmed"] = true as Bool
                                            obj["confirmedSince"] = getStringFromTodayDate()

                                            final.append(obj)
                                        }else{
                                            final.append(obj)
                                        }
                                    }
                                    
                                    let update  = Database.database().reference().child("SentOutOffersToUsers").child(Yourself.id).child(self.offer_ID)
                                    update.updateChildValues(["posts": final])
                                
                                    //naveen added
                                    OfferFromID(id: self.offer_ID, completion: {(offer)in
                                        global.AcceptedOffers[self.selectedIndex] = offer!
                                        
                                        self.navigationController!.popToRootViewController(animated: true)
                                        //                                                break
                                        
//                                        for controller in self.navigationController!.viewControllers as Array {
//                                            if controller.isKind(of: OfferVC.self) {
//                                                self.navigationController!.popToViewController(controller, animated: true)
//                                                break
//                                            }
//
//                                        }

                                    })
                                    
                                }
                            }
                            
                        }else{
                            let alert = UIAlertController(title: "Error", message: "Please install the Instagram application", preferredStyle: .alert)
                            self.present(alert, animated: true, completion: nil)

                        }
                    })
                }
                

                
            } catch {
                print("Unable to load data: \(error)")
            }
        }
    }
	

	override func viewDidLoad() {
        super.viewDidLoad()
		grid.dataSource = self
		grid.delegate = self

		gridHeight.constant = grid.collectionViewLayout.collectionViewContentSize.height
		ViewInsideStackHeight.constant = 333 + grid.collectionViewLayout.collectionViewContentSize.height
		UpdatePostInformation()
		grid.reloadData()
    }
	@IBOutlet weak var ViewInsideStackHeight: NSLayoutConstraint!
	@IBOutlet weak var gridHeight: NSLayoutConstraint!
	
	func UpdatePostInformation() {

        postimage.image = PostTypeToIcon(posttype: ThisPost.PostType)
		postLabel.text = PostTypeToText(posttype: ThisPost.PostType)
		rulesText.text = ThisPost.instructions
		
		captionText.text = ThisPost.captionMustInclude
	}
	
	@IBAction func Dismiss(_ sender: Any) {
		_ = navigationController?.popViewController(animated: true)
	}
	
	var ThisPost: Post!
	var companystring: String!
    //naveen added
    var isPostEnable = false
    var offer_ID: String!
    var selectedIndex:Int!

}
