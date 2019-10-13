//
//  ClassPickerVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

let maximumCategories: Int = 5

protocol SubCategoryResultDelegate {
	func CategoryAdded(newCategory: Category) -> Bool
	func CategoryRemoved(removedCategory: Category)
	func GetSelectedList() -> [Category]
	func DoneClicked()
	func isDoneButtonClickable() -> Bool
	func getTitleHeading() -> String
}

protocol CategoryPickerDelegate {
	func CategoriesPicked(newCategory: [Category])
}


class ClassCell: UITableViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
}

class ClassPickerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SubCategoryResultDelegate {
	
	func isDoneButtonClickable() -> Bool {
		return returnValue.count > 0
	}
	
	func getTitleHeading() -> String {
		 return "\(returnValue.count)/\(maximumCategories)"
	}
	
	
	@IBOutlet weak var header: UINavigationItem!
	
	func CategoryAdded(newCategory: Category) -> Bool {
		if returnValue.count >= maximumCategories {
			print("No room for new category.")
			return false
		}
		if returnValue.contains(newCategory) {
			print("Category already containing")
			return false
		}
		print("added category selection: \(newCategory)")
		returnValue.append(newCategory)
		catChanged()
		return true
	}
	
	func CategoryRemoved(removedCategory: Category) {
		returnValue = returnValue.filter{ return $0 != removedCategory }
		print("Category Removed: \(removedCategory)")
		catChanged()
	}
	
	func GetSelectedList() -> [Category] {
		return returnValue
	}
	
	func catChanged() {
		classShelf.reloadData()
		header.title = "\(returnValue.count)/\(maximumCategories) Categories Picked"
	}
	
	
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	func DoneClicked() {
		delegate?.CategoriesPicked(newCategory: returnValue)
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func DoneButtonClicked(_ sender: Any) {
		DoneClicked()
	}
	
	var returnValue: [Category] = [] {
		didSet {
			doneButton.isEnabled = returnValue.count > 0
		}
	}
	var originalValue: [Category] = [] {
		didSet {
			returnValue = originalValue
		}
	}
	
	var delegate: CategoryPickerDelegate?
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return allCategoryClasses.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = classShelf.dequeueReusableCell(withIdentifier: "ClassCell") as! ClassCell
		cell.titleLabel.text = allCategoryClasses[indexPath.row].rawValue
		if let cat = ClassToCategories[allCategoryClasses[indexPath.row]] {
			var isSelected = false
			if returnValue.count > 0 || originalValue.count > 0 {
				let ref: [Category] = returnValue
				var selectedCats: [String] = []
				for c in ref {
					if cat.contains(c) {
						selectedCats.append(c.rawValue)
					}
				}
				if selectedCats.count > 0 {
					cell.detailLabel.textColor = selectedBoxColor
					let s = GetCategoryStringFromlist(categories: selectedCats)
					cell.detailLabel.text = "Selected: \(s)"
					isSelected = true
				}
			}
			if isSelected == false {
				cell.detailLabel.textColor = UIColor.label
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
		catChanged()
		classShelf.dataSource = self
		classShelf.delegate = self
		navigationController?.navigationBar.prefersLargeTitles = true
    }
	
	var selectedCatClass: categoryClass!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? CategoryPickerVC {
			destination.categoryClass = selectedCatClass
			destination.delegate = self
		}
    }

}
