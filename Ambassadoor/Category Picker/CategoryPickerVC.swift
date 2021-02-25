//
//  CategoryPickerVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 3/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  All code contained in this file is sole property of Marco Gonzalez Hauger.
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
	var denyAtRow: [Int] = []
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if denyAtRow.contains(indexPath.row) {
			categoryShelf.deselectRow(at: indexPath, animated: true)
			return
		}
		if delegate?.CategoryAdded(newCategory: cats![indexPath.row]) == false {
			categoryShelf.deselectRow(at: indexPath, animated: true)
			let cell = categoryShelf.cellForRow(at: indexPath) as! catCell
			
			denyAtRow.append(indexPath.row)
			
			let oldText = cell.titleLabel.text!
			
			cell.titleLabel.textColor = .systemRed
			AnimateLabelText(label: cell.titleLabel, text: "Categories Full")
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
				cell.titleLabel.textColor = GetForeColor()
				AnimateLabelText(label: cell.titleLabel, text: oldText)
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
				self.denyAtRow.removeAll(where: {$0 == indexPath.row})
			}
			
			MakeShake(viewToShake: cell.titleLabel, coefficient: 0.1)
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
		if delegate?.GetSelectedList().count ?? maxInterests >= maxInterests {
			
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
