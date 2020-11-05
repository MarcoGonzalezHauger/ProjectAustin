//
//  InstagramBaseVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 28/09/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

var connectICPageIndex = 0

protocol InstagramPageDelegate {
    func pageIndex(index: Int)
}

class InstagramBaseVC: UIViewController, PageViewDelegate {
    func pageViewIndexDidChangedelegate(index: Int) {
        updatePageIndex(index)
    }
	
	func updatePageIndex(_ index: Int) {
		previousBtn.isEnabled = index != 0
		nextBtn.isEnabled = index != 4
		UIView.animate(withDuration: 0.3) {
			self.backView.alpha = index == 0 ? 0 : 1
			self.nextView.alpha = index == 4 ? 0 : 1
			if index == 2 || index == 3 {
				self.bottomBar.backgroundColor = .black
				self.TopBar.backgroundColor = .black
				self.TopLabel.textColor = .white
			} else {
				self.bottomBar.backgroundColor = GetBackColor()
				self.TopBar.backgroundColor = GetBackColor()
				self.TopLabel.textColor = GetForeColor()
			}
		}
	}
	
	@IBOutlet weak var backView: ShadowView!
	@IBOutlet weak var nextView: ShadowView!
	@IBOutlet weak var bottomBar: ShadowView!
	@IBOutlet weak var TopBar: ShadowView!
	@IBOutlet weak var TopLabel: UILabel!
	
    var pageIndexDelegate: InstagramPageDelegate?
    
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        connectICPageIndex = 0
		updatePageIndex(0)
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func previousAction(sender: UIButton){
        
        
        if(connectICPageIndex != 0){
			self.pageIndexDelegate?.pageIndex(index: connectICPageIndex - 1)
			connectICPageIndex -= 1
        }
		updatePageIndex(connectICPageIndex)
    }
    @IBAction func nextAction(sender: UIButton){
        
        
        if(connectICPageIndex != 4){
			self.pageIndexDelegate?.pageIndex(index: connectICPageIndex + 1)
			connectICPageIndex += 1
        }
		updatePageIndex(connectICPageIndex)
    }
    
    @IBAction func cancelAction() {
        self.navigationController?.popViewController(animated: true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "pageviewCI"{
            let view = segue.destination as! ConnectInstagramPVC
            self.pageIndexDelegate = view
            view.pageViewDidChange = self
        }
    }
    

}
