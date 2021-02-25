//
//  CustomDatePickerVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 23/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol CustomDatePickerDelegate {
    func pickedDate(date: Date)
}

class CustomDatePickerVC: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var pickerDelegate: CustomDatePickerDelegate?
    
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setConfigDatePicker()
    }
    
    func setConfigDatePicker() {
        var components = DateComponents()
        components.year = -18
        let maxDate = Calendar.current.date(byAdding: components, to: Date())
        datePicker.maximumDate = maxDate
        datePicker.date = selectedDate ?? maxDate!
    }
    
    @IBAction func cancelAction(_sender: Any){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = .clear
        }, completion: { (b) in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func doneAction(_sender: Any){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = .clear
        }, completion: { (b) in
            self.pickerDelegate?.pickedDate(date: self.datePicker.date)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
		UIView.animate(withDuration: 0.2) {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
		}
    }
}
