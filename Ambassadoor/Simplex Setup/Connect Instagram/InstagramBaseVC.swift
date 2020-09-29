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
		SetButtonVisibility(index)
		
    }
	
	func SetButtonVisibility(_ index: Int) {
		previousBtn.isEnabled = index != 0
		nextBtn.isEnabled = index != 6
		UIView.animate(withDuration: 0.2) {
			self.NextView.alpha = index == 6 ? 0 : 1
			self.BackView.alpha = index == 0 ? 0 : 1
		}
	}
    
	@IBOutlet weak var NextView: ShadowView!
	@IBOutlet weak var BackView: ShadowView!
	
    var pageIndexDelegate: InstagramPageDelegate?
    
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        connectICPageIndex = 0
		SetButtonVisibility(0)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func previousAction(sender: UIButton){
		
		SetButtonVisibility(connectICPageIndex - 1)
        
        if(connectICPageIndex != 0){
			self.pageIndexDelegate?.pageIndex(index: connectICPageIndex - 1)
        }
    }
    @IBAction func nextAction(sender: UIButton){
		
		SetButtonVisibility(connectICPageIndex + 1)
        
        if(connectICPageIndex != 6){
        self.pageIndexDelegate?.pageIndex(index: connectICPageIndex + 1)
        }
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
