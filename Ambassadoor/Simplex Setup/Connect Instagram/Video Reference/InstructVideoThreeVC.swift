//
//  InstructVideoThreeVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 28/09/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class InstructVideoThreeVC: UIViewController {
    
    var player: AVPlayer!
    var playerLayer = AVPlayerLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        connectICPageIndex = 5
        self.playAppOpen(sender: self)
    }
    
    func playAppOpen(sender: UIViewController) {
        var vidfile = "AppOpen"
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                vidfile += "W" //white
            } else {
                vidfile += "B" //black
            }
        } else {
            vidfile += "W" //white
        }
        guard let path = Bundle.main.path(forResource: vidfile, ofType:"mp4") else {
            print("Ambasadoor intro video not loading.")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        self.playerLayer.player = player
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.frame = self.view.bounds
        playerLayer.backgroundColor = UIColor.clear.cgColor
        player.allowsExternalPlayback = false
        
        
        self.view.layer.addSublayer(playerLayer)
       // self.view.sendSubviewToBack(LogoImage)
        player.play()
        
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
        self.playerLayer.removeFromSuperlayer()
        //self.playerLayer.removeFromSuperlayer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
