//
//  SunsetImagesLayer.swift
//  ICamMoveLite
//
//  Created by Alex Chan on 15/5/6.
//  Copyright (c) 2015年 Alex Chan. All rights reserved.
//

import Foundation




class SVImagesLayer: CALayer {
    
    var images: [CGImage] = []
    
    var movDuration: Double!
    var widthPerPic: CGFloat!
    
    let secPerPic = 2.0
    
    var totalPixWidth : CGFloat!
    
    func appendImage(image: CGImage){
        images.append(image)
    }
    
    func drawAllImages(){
        self.setNeedsDisplay()
    }
    
    override func drawInContext(ctx: CGContext!) {
        if countElements(images) > 0 && movDuration != nil{
            
            let height = bounds.size.height
            let imgWidth = CGImageGetWidth(images[0])
            let imgHeight = CGImageGetHeight(images[0])
            
            let aspect = 1.0
            
            widthPerPic = height * CGFloat(aspect)
            let width = widthPerPic
            
            CGContextTranslateCTM(ctx, 0, height)
            CGContextScaleCTM(ctx, 1.0, -1.0)
            var cnt = countElements(images)
            
            var tmpPixWidth: CGFloat = 0.0
            
            for var i = 0; i < cnt; ++i {
                println("i :\(i)")
                var image = images[i]
                var rect = CGRectMake( (width) * CGFloat(i), 0, width, height)
                
                
                
                if i == cnt-1 {
                    let leftSec = CGFloat(movDuration) - CGFloat(secPerPic) * CGFloat(cnt-1)
                    let aspect2 = leftSec / CGFloat(secPerPic)
                    rect.size.width = widthPerPic * aspect2
                    let width2 = CGFloat(imgWidth) * aspect2
                    image = CGImageCreateWithImageInRect(image, CGRectMake(0, 0, width2, CGFloat(imgHeight) ) )
                    
                }
                tmpPixWidth += rect.width
                
                CGContextDrawImage(ctx, rect, image)
                
            }
            totalPixWidth = tmpPixWidth

            
        }
        
    }
}