//
//  NewGenderVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 28/07/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewGenderVC: UIViewController {
    
    @IBOutlet var genderBtn: [UIButton]!
    @IBOutlet var shadowViews: [ShadowView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeColors()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func genderActionAction(sender: UIButton){
        NewAccount.gender = genders.getGender(tag: sender.tag)
        changeColors(tag: sender)
    }
    
    func changeColors(tag: UIButton? = nil) {
        
        if tag != nil {
            tag!.setTitleColor(UIColor.init(named: "AmbDarkPurple"), for: .normal)
            shadowViews[tag!.tag].backgroundColor = .white
        }
        
        let notSelectedButtons = self.genderBtn.filter { button in
            return tag == nil ? true : tag!.tag != button.tag
        }
        
        for button in notSelectedButtons {
            button.setTitleColor(.white, for: .normal)
            shadowViews[button.tag].backgroundColor = UIColor.init(named: "AmbDarkPurple")
        }
        
    }
    
    enum genders: String{
        case Female = "Female", Male = "Make", NotProvided = "Not Provided"
        
       static func getGender(tag: Int) -> String {
            switch tag {
            case 0:
                return Female.rawValue
            case 1:
                return Male.rawValue
            default:
                return NotProvided.rawValue
            }
        }
    }
    
    @IBAction func nextAction(sender: UIButton){
        if NewAccount.gender == "" {
            self.showStandardAlertDialog(title: "alert", msg: "Please choose any gender") { action in
            }
            return
        }
        self.performSegue(withIdentifier: "toNewZipcodeSegue", sender: self)
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
