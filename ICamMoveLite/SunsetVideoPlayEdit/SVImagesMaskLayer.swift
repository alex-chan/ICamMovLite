//
//  SVImagesMaskLayer.swift
//  ICamMoveLite
//
//  Created by Alex Chan on 15/5/12.
//  Copyright (c) 2015年 Alex Chan. All rights reserved.
//

import Foundation


struct SVAudioRange {
    var start: CGFloat
    var end: CGFloat
}

extension SVAudioRange {
    var width: CGFloat {
        return (end - start)
    }
}

class SVImagesMaskLayer: CALayer {
    
    var isDrawing: Bool = true
    
//    var currentPoint: CGFloat!
    var fillColor: CGColor = UIColor(red: 0, green: 0, blue: 0.8, alpha: 0.5).CGColor
    
    
    var range: SVAudioRange!
    
    func drawRect(start: CGFloat, end: CGFloat){
        isDrawing = true
        range = SVAudioRange(start: start, end: end)
        
        self.setNeedsDisplay()
    }
    
    func removeRange(range: SVAudioRange){
        isDrawing = false
        self.range = range
        self.setNeedsDisplay()
    }
    
    override func drawInContext(ctx: CGContext!) {
        
        let height = bounds.size.height
        var rect: CGRect
        if isDrawing {
        
            
            let width:  CGFloat = 1.0
            rect = CGRectMake(range.start, 0, range.width, height)
        
            CGContextSetFillColorWithColor(ctx, fillColor)

        
        }else{
            rect = CGRectMake(range.start, 0, range.width, height)
            CGContextSetFillColorWithColor(ctx, UIColor.clearColor().CGColor)
            
        }
        CGContextFillRect(ctx, rect)
    }

}