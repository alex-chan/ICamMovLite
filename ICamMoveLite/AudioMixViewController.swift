//
//  AudioMixViewController.swift
//  ICamMoveLite
//
//  Created by Alex Chan on 15/5/4.
//  Copyright (c) 2015年 Alex Chan. All rights reserved.
//

import Foundation
import GPUImage

struct AudioTimeRange {
    var startTime: CMTime
    var endTime: CMTime
}
extension AudioTimeRange {
    var start: Double{
        return Double(CMTimeGetSeconds(startTime))
    }
    
}

class RecordedAudio{
    
    var count = 0
    var audios: [NSURL]!
    var timerange: [AudioTimeRange]!
    
    func appendAudio(audioURL: NSURL, timeRange: AudioTimeRange){
        
    }
    
    func removeAudio(atIndex: Int){
        
    }
    
    func removeAudio(atTime: CMTime){
        
    }
}

class AudioMixViewController: UIViewController {
    
    var toEditMovieURL: NSURL!
    var toEditMovieType: MovieType!
    var toEditMovieSize: CGSize!
    
    var movie: GPUImageMovie!
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    var observer: AnyObject!
    
    
    var aRecorder: AVAudioRecorder!
    var aPlayer: AVAudioPlayer!
    var soundFileURL: NSURL!
    var meterTimer:NSTimer!
    
    var recordedAudio: RecordedAudio!
    
    @IBOutlet weak var playbackControl: SVControlView!
    @IBOutlet weak var recordAudioBtn: UIButton!
    
    
    @IBOutlet weak var preview: GPUImageView!
    
    
    
    
    
    // MARK: Overrided methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPlaybackControl()

        self.layoutMoviePreview()
        
        self.setSessionPlayback()
        
        

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        playerItem = AVPlayerItem(URL: toEditMovieURL)
        player = AVPlayer(playerItem: playerItem)
        
        
        observer = player.addPeriodicTimeObserverForInterval(CMTimeMake(3,30), queue: nil, usingBlock: {
            (t: CMTime) in
            
            self.playbackControl.scrollToTime(t)
            self.playbackControl.playingTime = t
            
            self.updateAudioMaskIfNeeded(t)
            
            return
        })
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object:
            playerItem)
        
        
        var composition = AVMutableComposition()
        movie = GPUImageMovie(playerItem: playerItem)
        
        
        movie.playAtActualSpeed = true
        
        movie.addTarget(filter)
        
        for pic in sourcePictures {
            pic.addTarget(filter)
        }
        filter.addTarget(self.preview)
        
        player.volume = 1.0
        player.play()
        
        playbackControl.controlFlow = .ControllerToView
        playbackControl.isPlaying = true
        
        movie.startProcessing()
    }
    

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        

        

        

        println("did appear \(playbackControl.bounds)")
        

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        movie.removeAllTargets()
        filter.removeAllTargets()
        for pic in sourcePictures {
            pic.removeAllTargets()
        }
        player.pause()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        player.removeTimeObserver(observer)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        
//        println("layout bounds\(playbackControl.bounds)")
//        println("layout frame \(playbackControl.frame)")
//        
//        playbackControl.frame = playbackControl.frame
    }
    
    // MARK: selectors
    func videoItemDidReachEnd(notif: NSNotification){
        
        var item = notif.object as AVPlayerItem
        item.seekToTime(kCMTimeZero)
        playbackControl.isPlaying = false
        
    }
    
    func panPlaytimeChanged(ctrl: SVControlView){
        
        playbackControl.isPlaying = false
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var tolerance = CMTimeMake(3, 30)
            self.player.seekToTime(ctrl.playingTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
//        })
            
        
        
    }
    
    func playPauseClicked(ctrl: SVControlView){
        if ctrl.isPlaying {
            player.play()
            self.playAudio()
            
        }else{
            player.pause()
        }
    }
    
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayback, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
    func setSessionPlayAndRecord() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
    
    // MARK: Custom UI functions
    
    
    func layoutMoviePreview(){
        
        if toEditMovieType == MovieType.Normal {
           preview.addConstraint(NSLayoutConstraint(item: preview, attribute: .Height, relatedBy: .Equal, toItem: preview, attribute: .Width, multiplier: 3.0/4.0, constant: 0))
            
        }else{
        preview.addConstraint(NSLayoutConstraint(item: preview, attribute: .Height, relatedBy: .Equal, toItem: preview, attribute: .Width, multiplier: 9.0/16.0, constant: 0))
            
        }
        
        
    }
    
    func setupPlaybackControl(){
        
        playbackControl.setup(toEditMovieURL)
        playbackControl.addTarget(self, action: "panPlaytimeChanged:", forControlEvents: .ValueChanged)
        playbackControl.addTarget(self, action: "playPauseClicked:", forControlEvents: .PlayPauseClicked)
        println("did load \(playbackControl.bounds)")
        
    }
    
    func playAudio() {
        
        if (aRecorder != nil  && aRecorder.recording) {
            return
        }
        
        println("playing")
        var error: NSError?
        // recorder might be nil
        self.aPlayer = AVAudioPlayer(contentsOfURL: soundFileURL, error: &error)
        if aPlayer == nil {
            if let e = error {
                println(e.localizedDescription)
                return
            }
        }
        aPlayer.delegate = self
        aPlayer.prepareToPlay()
        aPlayer.volume = 1.0
        aPlayer.play()
    }
    
    
    // MARK: Custom UI functions
    func setupRecorder() {
        var format = NSDateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        var currentFileName = "recording-\(format.stringFromDate(NSDate())).m4a"
        println(currentFileName)
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var docsDir: AnyObject = dirPaths[0]
        var soundFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(soundFilePath) {
            // probably won't happen. want to do something about it?
            println("sound exists")
        }
        
        var recordSettings = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        var error: NSError?
        aRecorder = AVAudioRecorder(URL: soundFileURL!, settings: recordSettings, error: &error)
        if let e = error {
            println(e.localizedDescription)
        } else {
            aRecorder.delegate = self
            aRecorder.meteringEnabled = true
            aRecorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        }
    }

    func updateAudioMeter(timer:NSTimer) {
        
        if aRecorder.recording {
            let dFormat = "%02d"
            let min:Int = Int(aRecorder.currentTime / 60)
            let sec:Int = Int(aRecorder.currentTime % 60)
            let s = "\(String(format: dFormat, min)):\(String(format: dFormat, sec))"
//            statusLabel.text = s
            aRecorder.updateMeters()
            var apc0 = aRecorder.averagePowerForChannel(0)
            var peak0 = aRecorder.peakPowerForChannel(0)
        }
    }
    
    func recordWithPermission(setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    println("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.aRecorder.record()
                    self.meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
                        target:self,
                        selector:"updateAudioMeter:",
                        userInfo:nil,
                        repeats:true)
                } else {
                    println("Permission to record not granted")
                }
            })
        } else {
            println("requestRecordPermission unrecognized")
        }
    }
    
    
    func updateAudioMaskIfNeeded(nowTime: CMTime){
        if startRecordTime != nil && aRecorder != nil && aRecorder.recording {
            playbackControl.drawMask(startRecordTime, end: nowTime)
        }
    }

    
    // MARK: IBActions
    var startRecordTime : CMTime!
    
    @IBAction func recordAudio(sender: UIButton) {
        
        startRecordTime = playbackControl.playingTime
        
        if aPlayer != nil && aPlayer.playing {
            aPlayer.stop()
            aPlayer.prepareToPlay()
        }
        
        if player != nil && !playbackControl.isPlaying {
            player.muted =  true
            player.play()
            playbackControl.isPlaying = true
            
        }
        
        recordAudioBtn.setImage(UIImage(named: "audio_record"), forState: .Normal)
        
        if aRecorder == nil {
            println("recording. recorder nil")
            self.recordWithPermission(true)
            return
        }

        println("recording")
        recordWithPermission(false)
        
    }
    
    @IBAction func stopRecordAudio(sender: UIButton) {
        
        player.muted =  false
        player.pause()
        playbackControl.isPlaying = false
        
        if aRecorder != nil && aRecorder.recording {
            println("pausing")
            aRecorder.pause()

            println("stop")
            aRecorder.stop()
            meterTimer.invalidate()
            
            let session:AVAudioSession = AVAudioSession.sharedInstance()
            var error: NSError?
            if !session.setActive(false, error: &error) {
                println("could not make session inactive")
                if let e = error {
                    println(e.localizedDescription)
                    return
                }
            }
        }
    }
    
    @IBAction func cancelRecordAudio(sender: UIButton) {
        self.stopRecordAudio(sender)
    }
    
    
}




// MARK: AVAudioRecorderDelegate
extension AudioMixViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!,
        successfully flag: Bool) {
            println("finished recording \(flag)")
            
            if player != nil && playbackControl.isPlaying {
                player.muted =  false
                player.pause()
                playbackControl.isPlaying = false
            }

    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!,
        error: NSError!) {
            println("\(error.localizedDescription)")
            if player != nil && playbackControl.isPlaying {
                player.pause()
                player.muted =  false
                playbackControl.isPlaying = false
            }
    }
}

// MARK: AVAudioPlayerDelegate
extension AudioMixViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("finished playing \(flag)")
        
        

    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("\(error.localizedDescription)")
    }
}