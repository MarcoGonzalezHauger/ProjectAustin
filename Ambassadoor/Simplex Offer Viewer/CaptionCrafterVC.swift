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
		
		var extraquotes = false
		var notCaseSensitive = false
		
		var newString: [String] = []
		var goods = 0
		for l in requiredStrings {
			if captionCanvas.text.contains(l) {
				goods += 1
				if captionCanvas.text.contains("\"\(l)\"") {
					extraquotes = true
					newString.append("⚠️: \"\(l)\"")
				} else {
					newString.append("✅: \"\(l)\"")
				}
			} else {
				if captionCanvas.text.lowercased().contains(l.lowercased()) {
					newString.append("⚠️: \"\(l)\"")
					notCaseSensitive = true
				} else {
					newString.append("❌: \"\(l)\"")
				}
			}
		}
		
		let hasWarning = extraquotes || notCaseSensitive
		
		if (goods == requiredStrings.count) {
			perfectGoodJob.textColor = .systemGreen
			if hasWarning {
				perfectGoodJob.text = "This will work, but you shouldn't add the quotes around the items.\nJust Copy & Paste this caption to the Instagram Post you made and you're done!"
			} else {
				perfectGoodJob.text = "Perfect!\nJust Copy & Paste this caption to the Instagram Post you made and you're done!"
			}
		} else {
			if hasWarning {
				perfectGoodJob.textColor = .systemRed
				if notCaseSensitive {
					perfectGoodJob.text = "The caption is case sensitive."
				} else if extraquotes {
					perfectGoodJob.text = "Don't add quotes around the items in your caption."
				}
			} else {
				perfectGoodJob.text = "Write a caption including all items above."
				perfectGoodJob.textColor = .systemGray
			}
		}
		
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
		scrollView.setContentOffset(bottomOffset, animated: false)
		scrollView.scrollRectToVisible(captionView.frame, animated: false)
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
