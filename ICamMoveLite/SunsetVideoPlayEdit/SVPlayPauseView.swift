//
//  SVPlayPauseView.swift
//  ICamMoveLite
//
//  Created by Alex Chan on 15/5/8.
//  Copyright (c) 2015年 Alex Chan. All rights reserved.
//

import Foundation
import Darwin

class SVPlayPauseButton: UIButton {
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        var context = UIGraphicsGetCurrentContext()
        
        var radius = bounds.size.height/2-2.0
        
        
        CGContextAddArc(context, center.x, center.y, radius, 0.0, CGFloat(M_PI * 2), 1)
        CGContextSetLineWidth(context, 2.0)
        CGContextSetStrokeColorWithColor(context, UIColor.blueColor().CGColor)
        CGContextStrokePath(context)
        
    }
}

class SVPlayPauseView: UIView {
    
    var isPlaying = true
    
    let playPath = UIBezierPath()
    let pausePath = UIBezierPath()
    
    var shapeLayer: CAShapeLayer!
    

    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commitInit()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commitInit()
    }
    
    func commitInit(){
        shapeLayer = CAShapeLayer()
        shapeLayer.delegate = self
        layer.addSublayer(shapeLayer)
        
    }
//
//    override class func layerClass() -> AnyClass {
//        return CAShapeLayer.self
//    }
    
    override func drawLayer(layer: CALayer!, inContext ctx: CGContext!) {
        println("drawLayer")
        
        if isPlaying {
            self.drawPlay(layer, inContext: ctx)
        }else{
            self.drawPause(layer, inContext: ctx)
        }
    }
    
    func drawPlay(layer: CALayer!, inContext ctx: CGContext!){
        println("drawPlay")
        
        var rect = bounds.rectByInsetting(dx: 4.0, dy: 4.0)
        var radius = bounds.size.height/2-2.0
        playPath.moveToPoint(center)
        playPath.addArcWithCenter(center, radius: radius , startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        var sl = layer as CAShapeLayer
        shapeLayer.path = playPath.CGPath
        shapeLayer.fillColor = UIColor.greenColor().CGColor
        shapeLayer.lineWidth = 4.0
        shapeLayer.strokeColor = UIColor.blueColor().CGColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.fillRule = kCAFillRuleNonZero
        
        
        
    }
    
    func drawPause(layer: CALayer!, inContext ctx: CGContext!){
        
    }
    
}
