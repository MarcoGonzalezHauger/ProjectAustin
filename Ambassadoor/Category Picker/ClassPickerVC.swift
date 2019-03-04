//
//  ClassPickerVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

protocol SubCategoryResultDelegate {
	func CategoryChanged(newCategory: Category)
	func DoneClicked()
}

protocol CategoryPickerDelegate {
	func CategoryPicked(newCategory: Category?)
}

class ClassCell: UITableViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
}

class ClassPickerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SubCategoryResultDelegate {
	
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	func DoneClicked() {
		delegate?.CategoryPicked(newCategory: returnValue)
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func DoneButtonClicked(_ sender: Any) {
		DoneClicked()
	}
	
	var returnValue: Category? {
		didSet {
			doneButton.isEnabled = returnValue != nil
		}
	}
	var originalValue: Category? {
		didSet {
			returnValue = originalValue
		}
	}
	var delegate: CategoryPickerDelegate?
	
	func CategoryChanged(newCategory: Category) {
		if originalValue == newCategory {
			returnValue = nil
		} else {
			returnValue = newCategory
		}
		classShelf.reloadData()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return allCategoryClasses.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = classShelf.dequeueReusableCell(withIdentifier: "ClassCell") as! ClassCell
		cell.titleLabel.text = allCategoryClasses[indexPath.row].rawValue
		if let cat = ClassToCategories[allCategoryClasses[indexPath.row]] {
			var isSelected = false
			if returnValue != nil || originalValue != nil {
				let ref: Category = returnValue ?? originalValue!
				if cat.contains(ref) {
					cell.detailLabel.text = "Selected: \(ref.rawValue)"
					isSelected = true
				}
			}
			if isSelected == false {
				if cat.count < 3 {
					cell.detailLabel.text = ""
				} else {
					cell.detailLabel.text = "\(cat[0].rawValue), \(cat[1].rawValue), \(cat[2].rawValue), etc."
				}
			}
		} else {
			cell.detailLabel.text = ""
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedCatClass = allCategoryClasses[indexPath.row]
		performSegue(withIdentifier: "ToCategoryFromClass", sender: self)
		classShelf.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 64
	}

	@IBOutlet weak var classShelf: UITableView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		classShelf.dataSource = self
		classShelf.delegate = self
    }
	
	var selectedCatClass: categoryClass!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? CategoryPickerVC {
			destination.selectedCategory = returnValue
			destination.categoryClass = selectedCatClass
			destination.delegate = self
		}
    }

}
