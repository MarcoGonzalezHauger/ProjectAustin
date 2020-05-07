//
//  ReportWriterVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 5/6/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class ReportWriterVC: UIViewController, UITextViewDelegate {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	@IBOutlet weak var TextCanvas: UITextView!
	@IBOutlet weak var sendReportButton: UIButton!
	@IBOutlet weak var reportButtonView: ShadowView!
	@IBOutlet weak var backButton: UIButton!
	
	var option: ReportType!
	var isBusiness = false
	var id: String?
			
	override func viewDidLoad() {
        super.viewDidLoad()

		TextCanvas.delegate = self
		
		titleLabel.text = option.writerTitle
		subtitleLabel.text = option.writerSubtitle
		TextCanvas.text = option.defaultText
		
        // Do any additional setup after loading the view.
    }
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			TextCanvas.resignFirstResponder()
			return false
		}
		return true
	}
	
	@IBAction func backButtonPressed(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func sendReportPressed(_ sender: Any) {
		sendReportButton.isEnabled = false
		sendReportButton.setTitle("SENDING...", for: .normal)
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
		self.backButton.isEnabled = false
		
		let dictionary: [String: Any] = [(isBusiness ? "businessID" : "offerID"): id ?? "UNKNOWN",
											"priorityLevel": option.priority,
											"reportType": option.itemName,
											"reportContent": TextCanvas.text!,
											"idOfReporter": Yourself.id,
											"isResolved": false,
											"dateCreated": getStringFromTodayDate()]
		
		let ref = Database.database().reference().child(isBusiness ? "companyReports" : "offerReports").childByAutoId()
		ref.updateChildValues(dictionary) { (error, dbr) in
			if error == nil {
				self.sendReportButton.setTitle("SENT", for: .normal)
				if #available(iOS 13.0, *) {
					self.isModalInPresentation = false
				}
				DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
					self.navigationController?.dismiss(animated: true, completion: nil)
				}
			} else {
				if #available(iOS 13.0, *) {
					self.isModalInPresentation = false
				}
				self.backButton.isEnabled = true
				self.sendReportButton.setTitle("FAILED TO SEND", for: .normal)
				DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
					self.sendReportButton.setTitle("TRY AGAIN", for: .normal)
					self.sendReportButton.isEnabled = true
				}
				MakeShake(viewToShake: self.reportButtonView)
			}
		}
	}
	
}
