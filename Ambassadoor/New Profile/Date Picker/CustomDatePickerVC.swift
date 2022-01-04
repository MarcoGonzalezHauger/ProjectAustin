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
    
    /// Configure custom date picker
    /// - Parameter animated: true or false
    override func viewWillAppear(_ animated: Bool) {
        self.setConfigDatePicker()
    }
    
    
    /// Initialise date components
    func setConfigDatePicker() {
        var components = DateComponents()
        components.year = -18
        let maxDate = Calendar.current.date(byAdding: components, to: Date())
        datePicker.maximumDate = maxDate
        datePicker.date = selectedDate ?? maxDate!
    }
    
    
    /// Dismiss current controller
    /// - Parameter _sender: UIButton referrance
    @IBAction func cancelAction(_sender: Any){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = .clear
        }, completion: { (b) in
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    /// send picked date to CustomDatePickerDelegate deleagte method. Dismiss current view controller
    /// - Parameter _sender: UIButton referrance
    @IBAction func doneAction(_sender: Any){
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = .clear
        }, completion: { (b) in
            self.pickerDelegate?.pickedDate(date: self.datePicker.date)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    /// Change UIView background color
    /// - Parameter animated: true or false
    override func viewDidAppear(_ animated: Bool) {
		UIView.animate(withDuration: 0.2) {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
		}
    }
}
