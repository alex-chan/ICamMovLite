//
//  SunsetVideoPlayAudioEdit.swift
//  ICamMoveLite
//
//  Created by Alex Chan on 15/5/5.
//  Copyright (c) 2015年 Alex Chan. All rights reserved.
//

import Foundation
import AVFoundation

extension UIControlEvents{
    static var PlayPauseClicked: UIControlEvents {
        let shiftBit: UInt = 1
        return UIControlEvents(0x1 << 24)  // 0x1<< 24~28, application reserved events
    }
}

enum ControlFlow {
    case ControllerToView
    case ViewToController
}

class SVControlView: UIControl{
    
    
    
    var imagesView: SVImagesView!
    var playPauseView: UIButton!
    var playtimeLabel: UILabel!
    var durationLabel: UILabel!
    
    var controlFlow: ControlFlow = .ControllerToView
    
   
    var videoDuration: Double! {
        didSet {
            durationLabel.text = self.formatSeconds(videoDuration)
        }
        
    }
    

    
    var playingTime: CMTime! {
        didSet {
            playtimeLabel.text = self.formatSeconds(Double(CMTimeGetSeconds(playingTime)))
        }
 
    }
    


    var isPlaying: Bool = false  {
        didSet {
            playPauseView.setImage(UIImage(named: isPlaying ?"pause" : "play"), forState: .Normal)
        }
    }
    
    
    // MARK: init
    
    override init(frame: CGRect) {
        imagesView = SVImagesView(frame: frame)
        super.init(frame: frame)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        imagesView = SVImagesView(coder: aDecoder)
        super.init(coder: aDecoder)
        
    }
    
    func setup(videoURL: NSURL){
        
        
        playtimeLabel = UILabel()
        playtimeLabel.text = "00:00"
        playtimeLabel.font = UIFont.systemFontOfSize(14)
        
        durationLabel = UILabel()
        durationLabel.text = "00:00"
        durationLabel.font = UIFont.systemFontOfSize(14)
        
        
        imagesView.weakControl = self
        imagesView.setup(videoURL)
        
        
        
        playPauseView = UIButton()
        playPauseView.addTarget(self, action: "playPauseClicked:", forControlEvents: .TouchUpInside)
        
        isPlaying =  false
        
        
        self.addSubview(durationLabel)
        self.addSubview(playtimeLabel)
        self.addSubview(imagesView)
        self.addSubview(playPauseView)
        
        imagesView.frame = bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        println("layout subviews")
        
        let labelHeight: CGFloat = 22.0, labelWidth: CGFloat = 60.0
        
        
        var upper: CGRect, bottom: CGRect, empty: CGRect, label: CGRect
        
        (upper, bottom) = bounds.rectsByDividing(labelHeight, fromEdge: .MinYEdge)
        
        (empty, label) = upper.rectsByDividing(bounds.height, fromEdge: .MinXEdge)
        
        playtimeLabel.bounds = CGRect(x: 0, y: 0, width: labelWidth, height: labelHeight)
        playtimeLabel.center = CGPoint(x: label.midX, y: label.midY)
        playtimeLabel.textAlignment = .Center
        
        
        durationLabel.frame = CGRect(x: bounds.width-labelWidth, y: 0, width: labelWidth, height: labelHeight)
        durationLabel.textAlignment = .Right
        
        var tmpframe: CGRect
        (playPauseView.frame, tmpframe)  = bottom.rectsByDividing(bounds.height, fromEdge: .MinXEdge)
        
//        tmpframe.size.width = 2000.0
        imagesView.frame = tmpframe
        
        
        playPauseView.setNeedsDisplay()
        
    }
    
    
    func playPauseClicked(btn: UIButton){
        
        isPlaying = !isPlaying
        self.sendActionsForControlEvents(.PlayPauseClicked)
        
    }
    
    func scrollToTime(t: CMTime){
        
        imagesView.scrollToTime(t)
    }
    
    func drawMask(start: CMTime, end: CMTime){
        imagesView.drawMask(start, end: end)
    }

    // MARK: Utils
    
    func formatSeconds(sec: Double) -> String{
        let totalSeconds = Int(round(sec))
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        return  String(format: "%02d:%02d", minutes, seconds)
    }
    
}



    
