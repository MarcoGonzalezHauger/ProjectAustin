//
//  InstructVideoTwoVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 28/09/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class InstructVideoTwoVC: UIViewController {
    
    var player: AVPlayer!
    var playerLayer = AVPlayerLayer()
    let playerViewController = AVPlayerViewController()
    @IBOutlet weak var playBackView: ShadowView!
    @IBOutlet weak var playBackBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        connectICPageIndex = 3
        self.playBackView.isHidden = true
        self.playAppOpen(sender: self)
    }
    
    func playAppOpen(sender: UIViewController) {
        //        var vidfile = "AppOpen"
        //        if #available(iOS 12.0, *) {
        //            if traitCollection.userInterfaceStyle == .light {
        //                vidfile += "W" //white
        //            } else {
        //                vidfile += "B" //black
        //            }
        //        } else {
        //            vidfile += "W" //white
        //        }
        DispatchQueue.main.async {
            let vidfile = "SignUpTutorial2"
            guard let path = Bundle.main.path(forResource: vidfile, ofType:"mp4") else {
                print("Ambasadoor intro video not loading.")
                return
            }
            self.player = AVPlayer(url: URL(fileURLWithPath: path))
            _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
            self.player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            self.playerViewController.player = self.player
            self.playerViewController.view.frame = self.view.bounds
            self.addChild(self.playerViewController)
            self.view.addSubview(self.playerViewController.view)
            self.playerViewController.didMove(toParent: self)
            self.player.play()
        }
    }
    
    @IBAction func playAgain(){
        self.playBackView.isHidden = true
        player.seek(to: CMTime.zero)
        self.player.play()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as AnyObject? === player {
            if keyPath == "timeControlStatus" {
                if #available(iOS 10.0, *) {
                    if player.timeControlStatus == .playing {
                        
                    }
                }
            }
        }
    }
    
    func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
        if keyPath == "status" {
            print(player.status)
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        self.playBackView.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool)  {
        player.pause()
        player = nil
        self.playerLayer.removeFromSuperlayer()
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
