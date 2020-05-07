//
//  ProblemPickerVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 5/6/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ReportTypeTVC: UITableViewCell {
	@IBOutlet weak var title: UILabel!
}

class ProblemPickerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return options.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "reportTypeCell") as! ReportTypeTVC
		cell.title.text = options[indexPath.row].itemName
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		optionToPass = options[indexPath.row]
		performSegue(withIdentifier: "toReportWriter", sender: self)
	}

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var reportShelf: UITableView!
	
	var options: [ReportType] = []
	var optionToPass: ReportType!
	var isBusiness: Bool = false
	var object: Any?
	
	override func viewDidLoad() {
        super.viewDidLoad()

		reportShelf.delegate = self
		reportShelf.dataSource = self
		
		titleLabel.text = isBusiness ? "Report this Business" : "Report this Offer"
		
        // Do any additional setup after loading the view.
    }
	
	
	
	@IBAction func dismissView(_ sender: Any) {
		navigationController?.dismiss(animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? ReportWriterVC {
			destination.option = optionToPass
			destination.isBusiness = isBusiness
			destination.id = isBusiness ? (object as! CompanyDetails).account_ID : (object as! Offer).offer_ID
		}
	}
	
}
