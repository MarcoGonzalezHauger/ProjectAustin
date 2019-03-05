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
	
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cats.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "catCell") as! catCell
		cell.titleLabel.text = cats[indexPath.row].rawValue
		if cats[indexPath.row] == selectedCategory {
			toSelect = indexPath
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		return cell
	}
	
	var toSelect: IndexPath?
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		delegate?.CategoryChanged(newCategory: cats[indexPath.row])
		selectedCategory = cats[indexPath.row]
		tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		tableView.cellForRow(at: indexPath)?.accessoryType = .none
	}
	
	@IBAction func doneClicked(_ sender: Any) {
		dismiss(animated: false, completion: nil)
		self.delegate?.DoneClicked()
	}
	
	var categoryClass: categoryClass! {
		didSet {
			cats = ClassToCategories[categoryClass]!
		}
	}
	var selectedCategory: Category? {
		didSet {
			doneButton.isEnabled = selectedCategory != nil
		}
	}
	var cats: [Category]!
	var delegate: SubCategoryResultDelegate?
	
	override func viewDidAppear(_ animated: Bool) {
		if let ip = toSelect {
			categoryShelf.selectRow(at: ip, animated: false, scrollPosition: .middle)
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		categoryShelf.delegate = self
		categoryShelf.dataSource = self
		if let ip = toSelect {
			categoryShelf.selectRow(at: ip, animated: false, scrollPosition: .middle)
			categoryShelf.cellForRow(at: ip)?.accessoryType = .checkmark
		}
    }

	@IBOutlet weak var categoryShelf: UITableView!
	
}
