//
//  PlayViewController.swift
//  Buoy
//
//  Created by Kamakshi Duvvuru on 7/24/16.
//  Copyright © 2016 Kamakshi Duvvuru. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class PlayViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var audioPlayer: AVAudioPlayer!
    var audioID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func playSound(sender: UIButton) {
        let query = PFQuery(className:"Memo")
        query.getObjectInBackgroundWithId(audioID) {
            (memo: PFObject?, error: NSError?) -> Void in
            if error == nil && memo != nil {
                let audio = memo!["audio"] as! PFFile
                self.playFile(audio)
            } else {
                print(error)
            }
        }
    }
    
    func playFile(file: PFFile) {
        file.getDataInBackgroundWithBlock {
            (data: NSData?, error: NSError?) -> Void in
            if error == nil && data != nil {
                do {
                    self.audioPlayer = try AVAudioPlayer(data: data!)
                } catch {
                    print("could not play file.")
                }
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.play()
                self.playButton.enabled = false
                self.stopButton.enabled = true
            }else {
                print(error)
            }
        }
    }
    
    @IBAction func stopSound(sender: UIButton){
        if audioPlayer != nil {
            audioPlayer.stop()
            audioPlayer = nil
            stopButton.enabled = false
            playButton.enabled = true
        }
    }
    
}
