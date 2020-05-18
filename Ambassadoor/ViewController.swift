//
//  ViewController.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/18/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
//

import UIKit

@IBDesignable
class AmbassadoorTopLabel: UIView {
	
	override func awakeFromNib() {
		SetupViews()
		SetupConstraints()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func SetupViews() {
		self.addSubview(AmbassadoorLabel)
	}
	
	func SetupConstraints() {
		self.translatesAutoresizingMaskIntoConstraints = false
		AmbassadoorLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		AmbassadoorLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
	}
	
	let AmbassadoorLabel: UILabel = {
		let amblbl: UILabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
		let fontSize: CGFloat = 21
		let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize), NSAttributedString.Key.foregroundColor : UIColor.init(named: "Main_ambassa")]
		let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize), NSAttributedString.Key.foregroundColor : UIColor.init(named: "Main_door")]
		let ambassa = NSMutableAttributedString(string:"Ambassa", attributes:attrs1 as [NSAttributedString.Key : Any])
		let door = NSMutableAttributedString(string:"door", attributes:attrs2 as [NSAttributedString.Key : Any])
		ambassa.append(door)
		amblbl.attributedText = ambassa
		amblbl.textAlignment = .center
		return amblbl
	}()
	
}

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
	}


}
