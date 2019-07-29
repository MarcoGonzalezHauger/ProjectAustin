//
//  CategoryPicker.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/4/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class CategoryPicker: UINavigationController, CategoryPickerDelegate {
	
	var complete: ((_ newCategory: Category) -> ())?
	
	func CategoryPicked(newCategory: Category) {
		if let completedFunction = complete {
			completedFunction(newCategory)
		}
	}
	

    override func viewDidLoad() {
        super.viewDidLoad()

    }
	
	func SetupPicker(originalCategory: Category?, completed: ((_ newCategory: Category) -> ())?) {
		complete = completed
		if let ClassPicker = self.topViewController as? ClassPickerVC {
			ClassPicker.delegate = self
			ClassPicker.originalValue = originalCategory
		} else {
			debugPrint("Error; unable to find ClassPicker VC as topViewController @ CategoryPicker: UINavCntrl.")
		}
	
	}

}
