//
//  SVImagesView.swift
//  ICamMoveLite
//
//  Created by Alex Chan on 15/5/9.
//  Copyright (c) 2015年 Alex Chan. All rights reserved.
//

import Foundation
import AVFoundation

class SVImagesView: UIView {
    
    
    
    var totalDuration: CMTime! {
        didSet {
            totalDurationSec = Double(CMTimeGetSeconds(totalDuration) )
            weakControl.videoDuration = Double(CMTimeGetSeconds(totalDuration))
        }
    }
    
    var totalDurationSec: Double!
    
    var currentPlayingTime:CMTime! {
        didSet  {
            currentPlayingTimeSec = Double(CMTimeGetSeconds(currentPlayingTime) )
            weakControl.playingTime = currentPlayingTime
        }
    }
    
    var currentPlayingTimeSec: Double = 0.0
    
    let imagesLayer =  SVImagesLayer()
    let imagesMaskLayer = SVImagesMaskLayer()
    let scrollLayer = CAScrollLayer()
    let splitterLayer = CAShapeLayer()
    
    
    var videoURL: NSURL!
    
    var updateTimeLabelQueue: dispatch_queue_t!
    
    
    
    
    weak var  weakControl: SVControlView!
    
    // MARK: Override attribute
    
    override var frame: CGRect {
        didSet {
            println("setted frame:\(frame), bounds:\(bounds)")
            self.updateLayerFrames()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            println("setted bounds:\(bounds)")
        }
    }
    
    // MARK: Init
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(videoURL: NSURL){
        self.videoURL = videoURL
        self.getMovieFrame()
        
        //        imagesLayer.backgroundColor = UIColor.blueColor().CGColor
        
        updateTimeLabelQueue = dispatch_queue_create("updateTimeLabelQueue", nil)
        
        imagesLayer.shouldRasterize = true
        imagesLayer.opaque = true
        imagesMaskLayer.shouldRasterize = true
//        scrollLayer.masksToBounds = false
        scrollLayer.opaque = true
        scrollLayer.addSublayer(imagesLayer)
        scrollLayer.addSublayer(imagesMaskLayer)
        
        layer.addSublayer(scrollLayer)
        layer.addSublayer(splitterLayer)
        
        layer.backgroundColor = UIColor.redColor().CGColor
        
        //
//        var pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
//        
//        self.addGestureRecognizer(pan)
        //
        
        self.updateLayerFrames()
    }
    
    
    // MARK: UIView overrides
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //        println("layoutSubviews in ImagesView")
        
        //        self.updateLayerFrames()
    }
    
    
    // MARK: Touches
    
    var startTouchX: CGFloat!
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var t = touches.anyObject() as? UITouch
        if let touch =  t {
           var point = touch.locationInView(self)
            startTouchX = point.x
        }
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        self.handleTouch(touches, sendAction: false)

    }
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.handleTouch(touches, sendAction: true)

    }
    
    func handleTouch(touches: NSSet, sendAction: Bool) {
        weakControl.isPlaying = false
        weakControl.sendActionsForControlEvents(.PlayPauseClicked)
        
        var t = touches.anyObject() as? UITouch
        if let touch =  t {
            var point = touch.locationInView(self)
            
            
            
            var offset = scrollLayer.bounds.origin
            offset.x -= (point.x - startTouchX)
            
            
            
            
            
            
            var cur = offset.x + CGRectGetMidX(bounds)
            
//            println("cur:\(cur)")
            if  cur >= imagesLayer.totalPixWidth {
                offset.x = imagesLayer.totalPixWidth - CGRectGetMidX(bounds)
            }else if cur <= 0.0 {
                offset.x =  -CGRectGetMidX(bounds)
            }
            
            startTouchX = point.x
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            scrollLayer.scrollToPoint(offset)
            CATransaction.commit()
            
            
            
            
            var t = self.pixelToTime(cur)
            
            
            if sendAction || ( abs(self.currentPlayingTimeSec - Double(CMTimeGetSeconds(t)) ) >= 0.2 ){
                self.currentPlayingTime =  t
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    self.weakControl.sendActionsForControlEvents(.ValueChanged)
                })


            }
            
            
        
        }
    }
    
//    // MARK: Gestures
//    func handlePan(gesture: UIPanGestureRecognizer){
//
//        weakControl.controlFlow = .ViewToController
//        weakControl.setPlaying(false, sendEvent: true)
//
//        
//        var offset = scrollLayer.bounds.origin
//        
////        println("offset x:\(offset.x)")
//        
//
//        
//        var translation = gesture.translationInView(self)
//        
//        offset.x -= translation.x
//        
////        println("translation x:\(translation.x)")
//        
//        gesture.setTranslation(CGPointZero, inView: self)
//        
//        
////        println("image width:\(imagesLayer.totalPixWidth)")
//        var cur = offset.x + CGRectGetMidX(bounds)
//        if  cur >= imagesLayer.totalPixWidth  || cur <= 0.0 {
//            // Stop animate cause we have reach the end
//            return
//        }
//        
//        
//        
//        
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        
//        scrollLayer.scrollToPoint(offset)
//        CATransaction.commit()
//        
//        
//        // update the currentPlayingTime
//        
////        println("vel:\(gesture.velocityInView(self))")
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//            var vel = gesture.velocityInView(self).x
//            var thredhold = 0.2
//            if abs(vel) >= 500.0 {
//                thredhold = 1.0
//            }else if abs(vel) >= 100 {
//                thredhold = 0.5
//            }else {
//                thredhold = 0.2
//            }
//            var t2 = self.pixelToTime2(cur)
//            if abs( t2 - self.currentPlayingTimeSec ) >= thredhold {
//                self.currentPlayingTime =  CMTimeMakeWithSeconds(Float64(t2), 30)
//            }
//
//        })
//        
//
//        
//        
//    }
    
    // MARK: UI
    
    func drawSplitterLayer(){
        var path =  UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: 0, y: bounds.height))
        
        splitterLayer.path = path.CGPath
        //        splitterLayer.fillColor = UIColor.whiteColor().CGColor
        //        splitterLayer.fillRule = kCAFillRuleNonZero
        splitterLayer.lineCap = kCALineCapRound
        splitterLayer.lineWidth = 2.0
        splitterLayer.strokeColor = UIColor.whiteColor().CGColor
        
        splitterLayer.frame = bounds.rectByOffsetting(dx: CGRectGetMidX(bounds), dy: 0)
        splitterLayer.contentsScale = UIScreen.mainScreen().scale
        
        println("scrollLayer frame:\(scrollLayer.frame) bounds:\(scrollLayer.bounds)")
        println("scrollto:\(CGRectGetMidX(bounds))")
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        
        scrollLayer.scrollToPoint(CGPoint(x: CGRectGetMidX(bounds)*(-1.0), y: 0.0))
        
        CATransaction.commit()
        
        println("frame after:\(scrollLayer.frame) bounds:\(scrollLayer.bounds)")
    }
    
    
    func updateLayerFrames(){
        
        println("updateLayerFrames")
        
        
        
        
        scrollLayer.scrollMode = kCAScrollHorizontally
        scrollLayer.frame = bounds.rectByInsetting(dx: 0.0, dy: 0.0)
        println("scrollFrame: \(scrollLayer.frame)")
        var imgframe = bounds
        imgframe.size.width = 400
        imagesLayer.frame = imgframe
        imagesMaskLayer.frame = imgframe
        
        self.drawSplitterLayer()
        
        
        
        scrollLayer.setNeedsDisplay()
        
        
        
        
    }
    
    func scrollToTime(t: CMTime){
        var pix = self.timeToPixel(t)
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
        
        scrollLayer.scrollToPoint(CGPoint(x: pix + CGRectGetMidX(bounds)*(-1.0), y: 0))
        
//        CATransaction.commit()
        
    }
    
    
    func drawMask(start: CMTime, end: CMTime){
        var s = self.timeToPixel(start)
        var e = self.timeToPixel(end)
        imagesMaskLayer.drawRect(s, end: e)
    }
    
    // MARK: Video
    func getMovieFrame(){
        
        let asset = AVURLAsset(URL: videoURL, options: nil)
        
        
        
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        var image = imageGenerator.copyCGImageAtTime(kCMTimeZero, actualTime: nil, error: nil)
        //        imagesLayer.contents = image
        //        layer.contents = image
        
        //        imageGenerator.maximumSize =
        
        let picWidth = 20
        
        totalDuration = asset.duration
        
        
        
        var picCnt: Int
        let intervalSec: Double = imagesLayer.secPerPic
        
        let durationSec = Double(CMTimeGetSeconds(totalDuration))
        
        println("durationSec:\(durationSec)")
        
        
        self.imagesLayer.movDuration = durationSec
        
        picCnt = Int( ceil( durationSec / intervalSec ) )
        
        
        
        println("picCnt:\(picCnt)")
        
        var allTimes: [AnyObject] = []
        for i in 0...picCnt-1 {
            var time = Float64( Double(i) * intervalSec )
            
            //            println("time:\(time)")
            var timeFrame = CMTimeMakeWithSeconds(time, 30)
            allTimes.append(    NSValue(CMTime:timeFrame) )
            
        }
        
        var doneCnt = 0
        
        println("count allTime: \(countElements(allTimes))")
        
        imageGenerator.generateCGImagesAsynchronouslyForTimes(allTimes, completionHandler: {
            (requestTime, image2, actualTime, result, error) in
            
            
            if result == .Succeeded {
                println("get image succeeded")
                
                self.imagesLayer.appendImage(image2)
                doneCnt += 1
                
                if doneCnt >= picCnt {
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), {
//                        println("images count:\(self.imagesLayer.images)")
                        self.imagesLayer.drawAllImages()
                    })
                }
                
                
            }else if result == .Failed{
                println(error.localizedDescription)
            }else{
                println("Canceled")
            }
        })
        
    }
    
    
    // MARK: Coordiration
    func timeToPixel(t: CMTime) -> CGFloat{
        var percent = CMTimeGetSeconds(t) / CMTimeGetSeconds(totalDuration)
        var pixwidth = imagesLayer.totalPixWidth
        if pixwidth == nil{
            pixwidth = 0.0
        }
        return CGFloat(percent) * CGFloat(pixwidth)
    }
    
    func pixelToTime(p: CGFloat) -> CMTime{
        
        var t = CGFloat(totalDurationSec ) *  p / imagesLayer.totalPixWidth

        return CMTimeMakeWithSeconds(Float64(t), 30)
        
        
    }
    
    func pixelToTime2(p: CGFloat) -> Double{
        return Double(  CGFloat(totalDurationSec ) *  p / imagesLayer.totalPixWidth )
    }
}