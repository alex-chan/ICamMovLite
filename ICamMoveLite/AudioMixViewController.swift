//
//  AudioMixViewController.swift
//  ICamMoveLite
//
//  Created by Alex Chan on 15/5/4.
//  Copyright (c) 2015年 Alex Chan. All rights reserved.
//

import Foundation
import GPUImage


class AudioMixViewController: UIViewController {
    
    var toEditMovieURL: NSURL!
    var toEditMovieType: MovieType!
    var toEditMovieSize: CGSize!
    
    var movie: GPUImageMovie!
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    
    var observer: AnyObject!
    
    @IBOutlet weak var playbackControl: SVControlView!
    
    
    @IBOutlet weak var preview: GPUImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playbackControl.setup(toEditMovieURL)
        playbackControl.addTarget(self, action: "panPlaytimeChanged:", forControlEvents: .ValueChanged)
        playbackControl.addTarget(self, action: "playPauseClicked:", forControlEvents: .PlayPauseClicked)

        self.layoutMoviePreview()
        
        
        println("did load \(playbackControl.bounds)")
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        player.removeTimeObserver(observer)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        

        
        playerItem = AVPlayerItem(URL: toEditMovieURL)
        player = AVPlayer(playerItem: playerItem)
        
        
        observer = player.addPeriodicTimeObserverForInterval(CMTimeMake(3,30), queue: nil, usingBlock: {
            (t: CMTime) in

            self.playbackControl.scrollToTime(t)
            self.playbackControl.playingTime = t
            return
        })
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object:
            playerItem)
        
        movie = GPUImageMovie(playerItem: playerItem)
        movie.playAtActualSpeed = true
        movie.addTarget(self.preview)
        
        player.play()
        
        playbackControl.controlFlow = .ControllerToView
        playbackControl.isPlaying = true
        
        movie.startProcessing()
        

        println("did appear \(playbackControl.bounds)")
        

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
        
        var tolerance = CMTimeMake(2, 30)
        player.seekToTime(ctrl.playingTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
        
    }
    
    func playPauseClicked(ctrl: SVControlView){
        if ctrl.isPlaying {
            player.play()
        }else{
            player.pause()
        }
    }
    
    // MARK: Custom functions
    
    
    func layoutMoviePreview(){
        
        if toEditMovieType == MovieType.Normal {
           preview.addConstraint(NSLayoutConstraint(item: preview, attribute: .Height, relatedBy: .Equal, toItem: preview, attribute: .Width, multiplier: 3.0/14.0, constant: 0))
            
        }else{
        preview.addConstraint(NSLayoutConstraint(item: preview, attribute: .Height, relatedBy: .Equal, toItem: preview, attribute: .Width, multiplier: 9.0/16.0, constant: 0))
            
        }
        
        
    }
    
}