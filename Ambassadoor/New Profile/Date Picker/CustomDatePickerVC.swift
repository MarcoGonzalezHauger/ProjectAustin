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
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setConfigDatePicker()
    }
    
    func setConfigDatePicker() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        var components = DateComponents()
        components.year = -18
        let maxDate = Calendar.current.date(byAdding: components, to: Date())
        datePicker.maximumDate = maxDate
        datePicker.date = selectedDate ?? maxDate!
    }
    
    @IBAction func cancelAction(_sender: Any){
        self.view.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_sender: Any){
        self.pickerDelegate?.pickedDate(date: self.datePicker.date)
        self.view.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
