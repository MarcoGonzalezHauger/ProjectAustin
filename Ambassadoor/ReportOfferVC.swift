//
//  ReportOfferVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 10/6/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

struct OfferReport {
	let DateReported: Date
	let report: String
	let OfferID: String
	let UserID: String
	let hasBeenResolved: Bool
}

class ReportOfferVC: UIViewController, UITextViewDelegate {

	@IBOutlet weak var textview: UITextView!
	@IBOutlet weak var reportButton: UIButton!
	@IBOutlet weak var reportView: ShadowView!
	
	var ThisOffer: Offer!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		textview.delegate = self
    }
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if (text == "\n") {
			textView.resignFirstResponder()
			return false
		}
		return true
	}

	@IBAction func dismissThis(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func reportPressed(_ sender: Any) {
		if textview.text == "" {
			MakeShake(viewToShake: reportView)
		} else {
			guard let ThisOffer = ThisOffer else { return }
			let report: OfferReport = OfferReport(DateReported: Date(), report: textview.text, OfferID: ThisOffer.offer_ID, UserID: Yourself.id, hasBeenResolved: false)
			
			let ref = Database.database().reference().child("reports").childByAutoId()
			
			let datef = DateFormatter()
			datef.dateFormat = "yyyy-MM-dd hh:mm:ss"
			let nowString: String = datef.string(from: Date())
			
			ref.updateChildValues(["dateReported": nowString,
			"reportString": report.report,
			"offerID": report.OfferID,
			"userID": report.UserID,
			"resolved": report.hasBeenResolved])
			
			let alert = UIAlertController(title: "Reported", message: "Your report has been filed.", preferredStyle: .alert)

			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (ui) in
				self.dismiss(animated: true, completion: nil)

		}
		))

			self.present(alert, animated: true)
			
			
		}
	}
	
}
