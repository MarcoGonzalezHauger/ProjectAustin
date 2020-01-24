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
	func CategoryAdded(newCategory: String) -> Bool
	func CategoryRemoved(removedCategory: String)
	func GetSelectedList() -> [String]
	func DoneClicked()
	func isDoneButtonClickable() -> Bool
	func getTitleHeading() -> String
}

protocol CategoryPickerDelegate {
	func CategoriesPicked(newCategory: [String])
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
	
	func CategoryAdded(newCategory: String) -> Bool {
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
		DisableUndo()
		catChanged()
		return true
	}
	
	func CategoryRemoved(removedCategory: String) {
		returnValue = returnValue.filter{ return $0 != removedCategory }
		print("Category Removed: \(removedCategory)")
		catChanged()
	}
	
	func GetSelectedList() -> [String] {
		return returnValue
	}
	
	func catChanged() {
		classShelf.reloadData()
		header.title = "\(returnValue.count)/\(maximumCategories) Categories Picked"
	}
	
	
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	func DoneClicked() {
		print("returning", returnValue)
		delegate?.CategoriesPicked(newCategory: returnValue)
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func DoneButtonClicked(_ sender: Any) {
		DoneClicked()
	}
	
	var returnValue: [String] = [] {
		didSet {
			doneButton.isEnabled = returnValue.count > 0
		}
	}
	var originalValue: [String] = [] {
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
				var selectedCats: [String] = []
				for c in returnValue {
					if cat.contains(c) {
						selectedCats.append(c)
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
				cell.detailLabel.textColor = GetForeColor()
				if cat.count < 3 {
					cell.detailLabel.text = ""
				} else {
					cell.detailLabel.text = "\(cat[0]), \(cat[1]), \(cat[2]), etc."
				}
			}
		} else {
			cell.detailLabel.text = ""
		}
		return cell
	}
	
	@IBOutlet weak var clearButton: UIBarButtonItem!
	
	var undoEnabled = false
	var MuteDisable = false
	var undoSavedItems: [String] = []
	
	func DisableUndo() {
		undoEnabled	= false
		clearButton.title = "Clear"
		clearButton.style = .plain
	}
	
	@IBAction func clear(_ sender: Any) {
		if undoEnabled {
			returnValue = undoSavedItems
			catChanged()
		} else {
			undoSavedItems = returnValue
			returnValue = []
			catChanged()
		}
		undoEnabled	= !undoEnabled
		clearButton.title = undoEnabled ? "Undo" : "Clear"
		clearButton.style = undoEnabled ? .done : .plain
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
