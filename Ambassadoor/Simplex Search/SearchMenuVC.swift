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

protocol SearchBarDelegate {
    func SearchTextIndex(text: String, segmentIndex: Int)
}

class SearchMenuVC: UIViewController, UISearchBarDelegate,PageViewDelegate {
    func pageViewIndexDidChangedelegate(index: Int) {
        self.searchSegment.selectedSegmentIndex = index
    }
    
    @IBOutlet weak var searchSegment: UISegmentedControl!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var segmentDelegate: SearchSegmentDelegate?
    
    static var searchDelegate: SearchBarDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchSegment.selectedSegmentIndex = 1
        // Do any additional setup after loading the view.
    }
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl){
        
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.segmentDelegate?.searchSegmentIndex(index: sender.selectedSegmentIndex)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)    {
//        query = searchText != "" ? searchText : nil
//        if let query = query {
//            socialSearchVC.GetSearchedItems(query: query, completed: DoneSearch(Results:))
//        } else {
//            DoneSearch(Results: GetTrendingUsers())
//        }
        
        SearchMenuVC.searchDelegate?.SearchTextIndex(text: searchText, segmentIndex: searchSegment.selectedSegmentIndex)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "PageView"{
            let view = segue.destination as! SearchPVC
            self.segmentDelegate = view
            view.pageViewDidChange = self
        }
    }
    

}
