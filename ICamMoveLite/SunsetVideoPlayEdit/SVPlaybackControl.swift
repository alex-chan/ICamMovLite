//
//  SVPlaybackControl.swift
//  ICamMoveLite
//
//  Created by Alex Chan on 15/5/15.
//  Copyright (c) 2015年 Alex Chan. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable class SVPlaybackControl: UIView {
    
    
    var playbackBtn: UIButton!
    var progressView: UIProgressView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    func setup(){
        
        playbackBtn = UIButton()
        playbackBtn.setImage(UIImage(named: "play"), forState: .Normal)
        
        progressView = UIProgressView()
        
        
        self.addSubview(playbackBtn)
        self.addSubview(progressView)
        
        var c1 =  NSLayoutConstraint(item: playbackBtn, attribute: .Width, relatedBy: .Equal, toItem: playbackBtn, attribute: .Height, multiplier: 1.0, constant: 0.0)

        var c2 = NSLayoutConstraint(item: playbackBtn, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        
//        var c3 = NSLayoutConstraint(item: playbackBtn, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1.0, constant: 0.0)
//
////        var c3 = NSLayoutConstraint(item: playbackBtn, attribute: .Trailing , relatedBy: .Equal, toItem: progressView, attribute: .Leading , multiplier: 1.0, constant: 0.0)
//        
//        var c4 = NSLayoutConstraint(item: progressView, attribute: .Trailing , relatedBy: .Equal, toItem: self, attribute: .Trailing , multiplier: 1.0, constant: 0.0)
        
//        var c5 = NSLayoutConstraint(item: playbackBtn, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)
//        
//        var c6 = NSLayoutConstraint(item: playbackBtn, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
//
//        var c7 = NSLayoutConstraint(item: progressView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)
//        
//        var c8 = NSLayoutConstraint(item: progressView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        
        
        

        
//        self.addConstraints([c1, c2, c3])
        
    }
    
}