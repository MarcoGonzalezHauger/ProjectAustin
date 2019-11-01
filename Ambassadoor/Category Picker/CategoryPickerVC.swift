//
//  CategoryPickerVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class catCell: UITableViewCell {
	@IBOutlet weak var titleLabel: UILabel!
}

class CategoryPickerVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var header: UINavigationItem!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cats.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "catCell") as! catCell
		cell.titleLabel.text = cats[indexPath.row]
		if delegate?.GetSelectedList().contains(cats[indexPath.row]) ?? false {
			categoryShelf.selectRow(at: indexPath, animated: true, scrollPosition: .none)
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		return cell
	}
	
	var toSelect: [IndexPath] = []
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if delegate?.CategoryAdded(newCategory: cats![indexPath.row]) == false {
			categoryShelf.deselectRow(at: indexPath, animated: true)
			MakeShake(viewToShake: (categoryShelf.cellForRow(at: indexPath) as! catCell).titleLabel, coefficient: 0.42)
		} else {
			tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
			didChangeSelection()
		}
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		delegate?.CategoryRemoved(removedCategory: cats![indexPath.row])
		tableView.cellForRow(at: indexPath)?.accessoryType = .none
		didChangeSelection()
	}
	
	func didChangeSelection() {
		header.title = delegate?.getTitleHeading()
		if delegate?.GetSelectedList().count ?? maximumCategories >= maximumCategories {
			
		}
		doneButton.isEnabled = (delegate?.isDoneButtonClickable() ?? false)
	}
	
	@IBAction func doneClicked(_ sender: Any) {
		dismiss(animated: true, completion: nil)
		self.delegate?.DoneClicked()
	}
	
	var categoryClass: categoryClass! {
		didSet {
			cats = ClassToCategories[categoryClass]!
		}
	}
	
	var cats: [String]!
	var delegate: SubCategoryResultDelegate?
	
	override func viewDidAppear(_ animated: Bool) {
		for ip in toSelect {
			categoryShelf.selectRow(at: ip, animated: false, scrollPosition: .none)
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		categoryShelf.delegate = self
		categoryShelf.dataSource = self
		didChangeSelection()
		for ip in toSelect {
			categoryShelf.selectRow(at: ip, animated: false, scrollPosition: .none)
		}
    }

	@IBOutlet weak var categoryShelf: UITableView!
	
}
