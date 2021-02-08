//
//  NewSettingsVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/5/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol NewSettingsDelegate {
	func GoIntoEditMode()
}

class NewSettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		scrollView.alwaysBounceVertical = false
		invisibleSwitch.isOn = Myself.basic.checkFlag("isInvisible")
    }
	
	@IBOutlet weak var invisibleSwitch: UISwitch!
	@IBOutlet weak var scrollView: UIScrollView!
	var delegate: NewSettingsDelegate?
	
	@IBAction func closeButtonPressed(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func editMyProfile(_ sender: Any) {
		delegate?.GoIntoEditMode()
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func switchChanged(_ sender: Any) {
		if invisibleSwitch.isOn {
			Myself.basic.AddFlag("isInvisible")
		} else {
			Myself.basic.RemoveFlag("isInvisible")
		}
		Myself.UpdateToFirebase(alsoUpdateToPublic: true, completed: nil)
	}
	
}
