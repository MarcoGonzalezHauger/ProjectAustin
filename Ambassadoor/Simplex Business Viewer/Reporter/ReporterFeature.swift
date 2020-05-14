//
//  ReporterFeature.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 5/6/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

struct ReportType {
	let itemName: String
	let writerTitle: String
	let writerSubtitle: String
	let priority: Int
	let defaultText: String
}

class ReporterFeature: StandardNC {
	
	var TargetCompany: CompanyDetails?
	var TargetOffer: Offer?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let problemPicker = self.topViewController as! ProblemPickerVC

		var options: [ReportType] = []
		
		if TargetCompany != nil {
			problemPicker.isBusiness = true
			
			//Create business options
			
			//INAPPROPRIATE
			options.append(ReportType.init(itemName: "Inappropriate", writerTitle: "Inappropriate", writerSubtitle: "Describe what you find inappropriate.", priority: 2, defaultText: ""))
			
			//Fake Company
			options.append(ReportType.init(itemName: "Fake Business", writerTitle: "Fake Business", writerSubtitle: "Describe why you believe this company is fake.", priority: 5, defaultText: ""))
			
			//Scam/Illigitamate Business
			options.append(ReportType.init(itemName: "Scam/Illegitimate", writerTitle: "Scam/Illegitimate", writerSubtitle: "Describe why you believe this company is a scam.", priority: 7, defaultText: ""))
			
			problemPicker.object = TargetCompany
			
		}
		if TargetOffer != nil {
			problemPicker.isBusiness = false
			
			//Create offer options
			
			//Unclear Guidelines
			options.append(ReportType.init(itemName: "Unclear Instructions", writerTitle: "Unclear Instructions", writerSubtitle: "Why are these instructions unclear?", priority: 8, defaultText: ""))
			
			//Innappropriate
			options.append(ReportType.init(itemName: "Inappropriate", writerTitle: "Inappropriate", writerSubtitle: "Describe what you find inappropriate.", priority: 15, defaultText: ""))
			
			//Encouraging Illigal Activity
			options.append(ReportType.init(itemName: "Illegal References", writerTitle: "Illegal References", writerSubtitle: "What seems illigal about this offer?", priority: 20, defaultText: ""))
			
			//Location Doesn't exist
			options.append(ReportType.init(itemName: "Business Location Doesn't Exist", writerTitle: "Location Not Real", writerSubtitle: "Describe the issue.", priority: 12, defaultText: "The location listed on a post in this offer does not exist."))
			
			//trolling
			options.append(ReportType.init(itemName: "Trolling", writerTitle: "Trolling", writerSubtitle: "How does this offer seem to be trolling?", priority: 3, defaultText: ""))
			
			//fake company
			options.append(ReportType.init(itemName: "Fake Company", writerTitle: "Fake Company", writerSubtitle: "Describe why you believe this company is fake.", priority: 5, defaultText: ""))
			
			//Slander
			options.append(ReportType.init(itemName: "Slander", writerTitle: "Slander", writerSubtitle: "Describe who this offer is attempting to slander.", priority: 7, defaultText: ""))
			
			problemPicker.object = TargetOffer
		}
		
		options.append(ReportType.init(itemName: "Other", writerTitle: "Other", writerSubtitle: "What seems to be the issue?", priority: 10, defaultText: ""))
		
		problemPicker.options = options
    }
    
}
