//
//  CaptionCrafterVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 5/7/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class CaptionCrafterVC: UIViewController, UITextViewDelegate {

	var requiredStrings: [String] = []
	
	@IBOutlet weak var perfectGoodJob: UILabel!
	@IBOutlet weak var copyCaptionButton: UIButton!
	@IBOutlet weak var captionCanvas: UITextView!
	@IBOutlet weak var listLabel: UILabel!
	@IBOutlet weak var captionView: ShadowView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var bottomOffset: NSLayoutConstraint!
	
	func updateList() {
		var newString: [String] = []
		var goods = 0
		for l in requiredStrings {
			if captionCanvas.text.contains(l) {
				newString.append("✅: \"\(l)\"")
				goods += 1
			} else {
				newString.append("NEEDS: \"\(l)\"")
			}
		}
		
		perfectGoodJob.text = (goods == requiredStrings.count) ? "Perfect!\nJust Copy & Paste this caption to the Instagram Post you made and you're done!" : ""
		copyCaptionButton.isHidden = !(goods == requiredStrings.count)
		
		listLabel.text = newString.joined(separator: "\n")
	}
	
	func textViewDidChange(_ textView: UITextView) {
		updateList()
		if copyCaptionButton.title(for: .normal) == "Copied!" {
			copyCaptionButton.setTitle("Click to Copy Your Caption", for: .normal)
		}
	}
	
	var firstTime = true
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if firstTime {
			captionCanvas.text = ""
			firstTime = false
		}
		let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
		scrollView.setContentOffset(bottomOffset, animated: true)
		
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			isModalInPresentation = true
		}
		captionCanvas.delegate = self
		updateList()

        // Do any additional setup after loading the view.
    }

	@IBAction func backPressed(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func copyCaptionPressed(_ sender: Any) {
		let pasteboard = UIPasteboard.general
		pasteboard.string = captionCanvas.text
		copyCaptionButton.setTitle("Copied!", for: .normal)
	}
}
