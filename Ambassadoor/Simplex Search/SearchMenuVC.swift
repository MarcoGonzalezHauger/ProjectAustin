//
//  SearchMenuVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 07/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol SearchSegmentDelegate {
    
    func searchSegmentIndex(index: Int)
    
}

class SearchMenuVC: UIViewController {
    
    @IBOutlet weak var searchSegment: UISegmentedControl!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var segmentDelegate: SearchSegmentDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchSegment.selectedSegmentIndex = 1
        // Do any additional setup after loading the view.
    }
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl){
        
        self.segmentDelegate?.searchSegmentIndex(index: sender.selectedSegmentIndex)
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "PageView"{
            let view = segue.destination as! SearchPVC
            self.segmentDelegate = view
        }
    }
    

}
