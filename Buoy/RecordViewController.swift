//
//  RecordViewController.swift
//  Buoy
//
//  Created by Kamakshi Duvvuru on 7/17/16.
//  Copyright © 2016 Kamakshi Duvvuru. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class RecordViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioURL: NSURL!
    var audioID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordButton.enabled = false
        stopButton.enabled = false

        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        self.recordButton.enabled = true
                    } else {
                        print("Failed to record.")
                    }
                }
            }
        } catch {
            print("You have to allow permission to record.")
            
        }
    }
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    @IBAction func startRecording(sender: UIButton) {
        audioURL = NSURL(fileURLWithPath: getDocumentsDirectory()).URLByAppendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.enabled = false
            stopButton.enabled = true
        } catch {
            print("recording audio failed.")
        }
    }

    
    @IBAction func finishRecording(sender: UIButton) {
        audioRecorder.stop()
        audioRecorder = nil
        
        recordButton.enabled = true
        stopButton.enabled = false

        let audioData = NSData(contentsOfURL: audioURL)
        let file = PFFile(name: "recording.m4a", data: audioData!)
        file?.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if(success) {
                let memo = PFObject(className: "Memo")
                memo["name"] = "memo one"
                memo["audio"] = file
                memo["user"] = "kamakshi"
                memo.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    if(success) {
                        self.audioID = memo.objectId
                        self.performSegueWithIdentifier("playSound", sender: nil)
                    }else {
                        print(error!)
                    }
                }
            }else {
                print(error!)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "playSound" {
            if let destination = segue.destinationViewController as? PlayViewController {
                print(self.audioID)
                destination.audioID = self.audioID
            }
        }
    }
}
