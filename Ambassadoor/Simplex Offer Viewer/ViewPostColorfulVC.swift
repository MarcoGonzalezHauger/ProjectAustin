//
//  ViewPostColorfulVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 22/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ViewPostColorfulVC: UIViewController {
    
    @IBOutlet weak var postSerialNo: UILabel!
    @IBOutlet weak var postName: UILabel!
    
    @IBOutlet weak var postInstructions: UILabel!
    @IBOutlet weak var tagData: UILabel!
    
    @IBOutlet weak var shadowView: ShadowView!
    
    var index: Int?
    var offer: Offer?
    var captionItems = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setPostData()
        // Do any additional setup after loading the view.
    }
    
    static func getColor(index: Int) -> (UIColor, String){
        switch index{
        case 0:
            return (UIColor.systemBlue, "1")
        case 1:
            return (UIColor.systemRed, "2")
        case 2:
            return (UIColor.systemYellow, "3")
        default:
            return (UIColor.white, "")
        }
    }
    
    func setPostData() {
        
        let colorValue = ViewPostColorfulVC.getColor(index: self.index!)
        self.postSerialNo.text = colorValue.1
        self.postName.text = "Post \(colorValue.1)"
        shadowView.backgroundColor = colorValue.0
        self.postInstructions.text = self.offer!.posts[self.index!].instructions
        
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
    
    @IBAction func dismissAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
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
