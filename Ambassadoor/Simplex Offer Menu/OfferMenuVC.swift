//
//  OfferMenuVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 03/04/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol OfferMenuSegmentDelegate {
    func segmentIndex(index: Int)
}

enum Description: String {
    case Followed = "View Offers from Businesses You Follow", Filtered = "View Offers You Are Able to Accept", All = "View All Offers on Ambassadoor"
    static var allValues = [Followed, Filtered, All]
}

class OfferMenuVC: UIViewController,PageViewDelegate {
    
    func pageViewIndexDidChangedelegate(index: Int) {
        self.offerSegmentFilter.selectedSegmentIndex = index
        self.desText.text = Description.allValues[index].rawValue
    }
    
    @IBOutlet weak var desText: UILabel!
    
    @IBOutlet weak var offerSegmentFilter: UISegmentedControl!
    
    var offerPVCDelegate: OfferMenuSegmentDelegate?
    
    @IBOutlet weak var pageViewContainer: UIView!
    @IBOutlet weak var videoDumpView: UIView!
    
    var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        self.playTutorialVideo(sender: self)
        
        self.pageViewContainer.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.scaleAnimateView()
        offerSegmentFilter.selectedSegmentIndex = 1
        self.desText.text = Description.allValues[1].rawValue
        // Do any additional setup after loading the view.
        
        timer = Timer.scheduledTimer(timeInterval: rememberOfferPoolFor, target: self, selector: #selector(self.getPoolThenRefresh(timer:)), userInfo: nil, repeats: true)
        timer.fire()
        
    }
    
    var timer: Timer!
    
    @objc func getPoolThenRefresh(timer: Timer?) {
        GetOfferPool { (offers) in
            for del in refreshDelegates {
                del.refreshOfferDate()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    @IBAction func segmentValueChange(sender: UISegmentedControl){
        self.offerPVCDelegate?.segmentIndex(index: offerSegmentFilter.selectedSegmentIndex)
        //let adddd = self.children[0] as! OfferVC
        self.desText.text = Description.allValues[offerSegmentFilter.selectedSegmentIndex].rawValue
    }
    
    func scaleAnimateView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            self.pageViewContainer.isHidden = false
            
            self.pageViewContainer.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.pageViewContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
                
                
            }) { (status) in
                self.tabBarController?.tabBar.isHidden = false
                
            }
            
        }
    }
    
    func playTutorialVideo(sender: UIViewController) {
        guard let path = Bundle.main.path(forResource: "AppOpenW", ofType:"mp4") else {
            print("Ambasadoor Tutorial Video not found.")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        self.playerLayer.player = player
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.frame = self.view.bounds
        playerLayer.backgroundColor = UIColor.white.cgColor
        
        self.videoDumpView.layer.addSublayer(playerLayer)
        player.play()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        self.playerLayer.removeFromSuperlayer()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PageView"{
            let view = segue.destination as! OffersPVC
            self.offerPVCDelegate = view
            view.pageViewDidChange = self
        }
    }
    
    
}
