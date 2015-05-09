//
//  ViewController.swift
//  ICamMoveLite
//
//  Created by Alex Chan on 15/5/4.
//  Copyright (c) 2015年 Alex Chan. All rights reserved.
//

import UIKit
import GPUImage


class TakeMovieViewController: UIViewController {

    
    @IBOutlet var preview: GPUImageView!
    @IBOutlet var rootBlur: GPUImageView!
    @IBOutlet weak var recordStopBtn: UIButton!
    
    
    var videoCamera: GPUImageVideoCamera!
    var videoWriter: GPUImageMovieWriter!
    var cropFilter: GPUImageCropFilter!
    var outURL: NSURL!
    var movieType : MovieType = .Normal
    var movieSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .Front)
        
        videoCamera.outputImageOrientation = .Portrait
        videoCamera.horizontallyMirrorFrontFacingCamera = true
        
        preview.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        
        
        videoCamera.addTarget(preview)
                
        videoCamera.addAudioInputsAndOutputs()
        
        videoCamera.startCameraCapture()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toEditMovieSegue" {
            var vc = segue.destinationViewController as EditMovieViewController
            vc.toEditMovieURL = outURL
            vc.toEditMovieType = movieType
            vc.toEditMovieSize = movieSize
            
            
        }
    }

    // MARK: IBActions
    
    @IBAction func unwindToTakeMovie(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func recordOrStop(sender: UIButton) {
        self.recordStopBtn.selected = !self.recordStopBtn.selected
        var isRecord: Bool =  self.recordStopBtn.selected
        
        if isRecord {
            
            var path = NSTemporaryDirectory().stringByAppendingPathComponent("tmp".stringByAppendingPathExtension("mov")!)
            var url = NSURL(fileURLWithPath: path)
            if NSFileManager.defaultManager().fileExistsAtPath(path){
                var error:NSError?
                if NSFileManager.defaultManager().removeItemAtPath(path, error: &error) == false {
                    println("remove item at path \(path) failed: \(error!.localizedDescription)")
                }
            }
            
            
            outURL = url
            
            var view = self.preview as GPUImageView
            
            println("size:\(view.bounds.size)")
            
            var size = self.getCaptureVideoSize()
            var destRect: CGRect!
            var kAspect: CGFloat!
            if movieType == .Normal {
                kAspect = 3 / 4
            }else{
                kAspect = 9 / 16
            }
            
            var movieAspect = size.height / size.width
            
            if movieAspect < kAspect {
                destRect = CGRectMake( (kAspect-movieAspect)/kAspect/2 , 0, movieAspect/kAspect, 1)
                destRect = CGRectMake(0, 0, movieAspect/kAspect, 1)
            }else{
                destRect = CGRectMake(0, (movieAspect-kAspect)/movieAspect/2, 1, kAspect/movieAspect)
            }
            

            
            
            
            movieSize = CGSizeMake(destRect.size.width * size.width, destRect.size.height * size.height)
            
            
            cropFilter = GPUImageCropFilter(cropRegion: destRect)
            
            videoWriter = GPUImageMovieWriter(movieURL: url, size: movieSize)
            
            videoCamera.addTarget(cropFilter)
            
            cropFilter.addTarget(videoWriter)
            
            videoWriter.encodingLiveVideo = true
            
            videoCamera.audioEncodingTarget = videoWriter
            
            videoWriter.startRecordingInOrientation(CGAffineTransformMakeRotation(0))
            
        }else{
            videoWriter.finishRecordingWithCompletionHandler({
                self.performSegueWithIdentifier("toEditMovieSegue", sender: self)
            })
            
        }
        
    }
    
    
    // MARK: Custom functions
    func getCaptureVideoSize() -> CGSize{
        
        var outputSettings: [NSObject: AnyObject]?
        
        for output in self.videoCamera.captureSession.outputs {
            if let out = output as? AVCaptureVideoDataOutput {
                outputSettings = out.videoSettings
            }
        }
        
        if outputSettings == nil {
            return CGSizeMake(0, 0)
        }
        
        
        var width = CGFloat(outputSettings!["Width"]!.doubleValue)
        var height = CGFloat(outputSettings!["Height"]!.doubleValue)
        
        if UIInterfaceOrientationIsPortrait(self.videoCamera.outputImageOrientation){
            var tmp = width
            width = height
            height = tmp
        }
        
        return CGSizeMake(width, height)
        
    }
}

