//
//  ViewPostDetailedVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 22/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ViewPostDetailedVC: UIViewController {
    
    @IBOutlet weak var postStatusImg: UIImageView!
    @IBOutlet weak var postName: UILabel!
    @IBOutlet weak var postStatusText: UILabel!
    
    @IBOutlet weak var insTitle: UILabel!
    @IBOutlet weak var instruction: UILabel!
    @IBOutlet weak var tagData: UILabel!
    
    @IBOutlet weak var shadow: ShadowView!
    
    var index: Int?
    var offer: Offer?
    var captionItems = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setPostedData()
    }
    
    func setPostedData() {
        
        let post = self.offer!.posts[self.index!]
        let postValue = postStatus.returnImageStatus(status: post.status)
        
        self.postStatusImg.image = UIImage(named: postValue.1)
        
        postStatusText.text = postValue.0.rawValue
        postStatusText.textColor = postValue.2
        
        let colorValue = ViewPostColorfulVC.getColor(index: self.index!)
        self.postName.text = "Post \(colorValue.1)"
        
        if postValue.0 == .Rejected{
            
            self.insTitle.text = "Reason Your Post Was Denied"
            self.insTitle.textColor = .systemRed
            
            self.instruction.text = post.denyMessage!
			self.shadow.isHidden = true
            
        }else if postValue.0 == .NotPosted {
            
            self.shadow.isHidden = false
			
			self.instruction.text = post.instructions
            
            if self.offer!.posts[index!].keywords.count != 0 {
                self.captionItems.append(contentsOf: self.offer!.posts[index!].keywords)
            }
            
            if self.offer!.posts[index!].hashtags.count != 0 {
                
                let hashes = self.offer!.posts[index!].hashtags.map { (hash) -> String in
                    return "#\(hash)"
                }
                self.captionItems.append(contentsOf: hashes)
            }
            
            if self.captionItems.count != 0{
                let caption = self.captionItems.reduce("") { (final, next) -> String in
                        return final + next + "\n"
                }
                self.tagData.text = caption
            }
            
        }else{
            self.instruction.text = post.instructions
            
            self.shadow.isHidden = false
            
            if self.offer!.posts[index!].keywords.count != 0 {
                self.captionItems.append(contentsOf: self.offer!.posts[index!].keywords)
            }
            
            if self.offer!.posts[index!].hashtags.count != 0 {
                
                let hashes = self.offer!.posts[index!].hashtags.map { (hash) -> String in
                    return "#\(hash)"
                }
                self.captionItems.append(contentsOf: hashes)
            }
            
            if self.captionItems.count != 0{
                let caption = self.captionItems.reduce("") { (final, next) -> String in
                        return final + next + "\n"
                }
                self.tagData.text = caption
            }
        }
        
    }
    
    @IBAction func dismissAction(sender: UIButton){
		self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? CaptionCrafterVC {
			var stringItems: [String] = []
			stringItems.append(contentsOf: self.offer!.posts[index!].keywords)
			for x in self.offer!.posts[index!].hashtags {
				stringItems.append("#\(x)")
			}
			destination.requiredStrings = stringItems
		}
    }

}
