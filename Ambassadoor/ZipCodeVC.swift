//
//  ZipCodeVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/4/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol EnterZipCode {
	func ZipCodeEntered(zipCode: String?)
}

class ZipCodeVC: UIViewController {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var zipField: UITextField!
	
	var delegate: EnterZipCode?
	var currentquery: String?
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	func TownToZip(code: String) {
		GetTownName(zipCode: code) { (name, zipCode) in
			if self.currentquery == zipCode {
				self.nameLabel.text = name
			}
		}
	}
	
	@IBAction func textChanged(_ sender: Any) {
		if let text = zipField.text {
			zipField.text = text.replacingOccurrences(of: " ", with: "")
		}
		enterbutton.isEnabled = zipField.text?.count ?? 0 >= 5
		//if zip length = 4 then get all possible results = 10001, 10002, 10003, etc. and put them in RAM.
		if zipField.text?.count == 4 {
			for x: Int in 0...9 {
				nameLabel.text = ""
				TownToZip(code: zipField.text! + String(x))
			}
			//if zip length is 5 or 6, display city&state on label depending on the ZIP code inputted by the user.
		} else if zipField.text?.count == 5 || zipField.text?.count == 6 {
			currentquery = zipField.text!
			if let citystate = zipCodeDic[zipField.text!] {
				nameLabel.text = citystate
			} else {
				TownToZip(code: zipField.text!)
			}
		} else {
			nameLabel.text = ""
		}
	}
	
	@IBOutlet weak var enterbutton: UIButton!
	
	func done() {
		delegate?.ZipCodeEntered(zipCode: zipField.text!)
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func DoneClicked(_ sender: Any) {
		done()
	}
	
	@IBAction func entered(_ sender: Any) {
		done()
	}
	
	@IBAction func cancel(_ sender: Any) {
		delegate?.ZipCodeEntered(zipCode: nil)
		dismiss(animated: true, completion: nil)
	}
	
}
