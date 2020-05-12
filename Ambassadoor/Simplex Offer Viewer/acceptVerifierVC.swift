//
//  acceptVerifierVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 5/8/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol didAcceptDeleagte {
	func didAccept()
}

class acceptVerifierVC: UIViewController {

	var delegate: didAcceptDeleagte?
	@IBOutlet weak var acceptView: ShadowView!
	@IBOutlet weak var view21: ShadowView!
	@IBOutlet weak var acceptButton: UIButton!
	
	var isOver21 = true
	
    override func viewDidLoad() {
        super.viewDidLoad()
		CreateAnimation()
		view21.backgroundColor = tewntyOneColor
		view21.isHidden = !isOver21
		acceptButton.setTitle(isOver21 ? "ACCEPT (21+)" : "ACCEPT", for: .normal)
        // Do any additional setup after loading the view.
    }
	@IBAction func dismissButtonPressed(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func acceptClicked(_ sender: Any) {
		dismiss(animated: true) {
			self.delegate?.didAccept()
		}
	}
	
	func set21(is21andOver: Bool) {
		isOver21 = is21andOver
	}
	
	
	func CreateAnimation() {
		self.acceptView.backgroundColor = acceptColorOne
		print("[VERIFIER VC] animation has been created for accept button")
		if !alreadyTeal {
			FadeToTeal()
			alreadyTeal = true
		}
	}
	
	var alreadyTeal = false
	
	func FadeToBlue() {
		UIView.animate(withDuration: 2, delay: 0.0, options: [.allowUserInteraction], animations: { () -> Void in
			self.acceptView.backgroundColor = acceptColorOne
		}, completion: { (bl) in
			self.FadeToTeal()
		})
	}
	
	func FadeToTeal() {
		UIView.animate(withDuration: 2, delay: 0.0, options: [.allowUserInteraction], animations: { () -> Void in
			self.acceptView.backgroundColor = acceptColorTwo
		}, completion: { (bl) in
			self.FadeToBlue()
		})
	}
	
}
