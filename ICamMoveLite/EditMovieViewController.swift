//
//  EditMovieViewController.swift
//  ICamMoveLite
//
//  Created by Alex Chan on 15/5/4.
//  Copyright (c) 2015年 Alex Chan. All rights reserved.
//


import Foundation
import AssetsLibrary
import MobileCoreServices

import GPUImage

var sourcePictures = [GPUImagePicture]()
var filter: GPUImageFilter!


class EditMovieViewController: UIViewController,  FilterCollectionViewDelegate{
    
    // MARK: IBOutlets
    @IBOutlet weak var moviePreview: GPUImageView!
    @IBOutlet weak var progress: UISlider!
    @IBOutlet weak var playback: UIButton!
    @IBOutlet weak var subtitleView: UIView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: Movie attributes
    
    var movie2 : GPUImageMovie!
    var player:  AVPlayer!
    var playerItem: AVPlayerItem!
    var movieDuration: CMTime!
    

    // MARK: segue presented attributes
    var toEditMovieURL: NSURL!
    var toEditMovieType: MovieType!
    var toEditMovieSize: CGSize!
    
    // MARK: Filters
//    var filter: GPUImageFilter!
//    var sourcePicture: GPUImagePicture!
//    var sourcePicture2: GPUImagePicture!
//    var sourcePicture3: GPUImagePicture!
//    var sourcePicture4: GPUImagePicture!
//    var sourcePicture5: GPUImagePicture!
    var colorGen = GPUImageSolidColorGenerator()
    
    // MARK: Other attriubtes
    var currentShowing: UIView?
    var curFilterIndex: Int?
    var timer: NSTimer!
    
    var movieURLToShare: NSURL!
    
    
    var observer: AnyObject!
    
    
    // Set show mask as default
    var maskShowing: Bool  = true {
        didSet {
            
            (filter as GPUImageExtendFilter).borderHeight =  maskShowing ? 0.1 : 0
        }
    }


    
    var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                player.play()
                playback.setImage(UIImage(named: "pause"), forState: .Normal)
                
            }else{
                player.pause()
                playback.setImage(UIImage(named: "play"), forState: .Normal)
            }
            
        }
    }
    
    

    
    // MARK: Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        colorGen.setColorRed(1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        
        toEditMovieURL = Utils.getTestVideo2Url()
        toEditMovieType = .Cinema
        toEditMovieSize = CGSize(width: 400, height: 300)
        
        
        println("edit movie:\(toEditMovieURL)")
        println("to edit movie size:\(toEditMovieSize)")

        
        self.getMovieInfo(toEditMovieURL)
        
        
        for childVC in childViewControllers{
            if let child = childVC as? FilterCollectionViewController{
                var filterVC = child
                filterVC.delegate = self
            }
        }
        
        self.layoutMoviePreview()
        
    }
    
    //    override func shouldAutorotate() -> Bool {
    //        return false
    //    }
    //
    //    override func supportedInterfaceOrientations() -> Int {
    //        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    //    }
    
    
    



    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //        self.view.setNeedsLayout()
        //        self.view.layoutIfNeeded()
        
        self.activityIndicator.stopAnimating()
        
        
        playerItem = AVPlayerItem(URL: toEditMovieURL)
        player = AVPlayer(playerItem: playerItem)
        
        
        movie2 = GPUImageMovie(playerItem: playerItem)
        movie2.playAtActualSpeed = true
        
      
        if filter == nil {
            filter = GPUImageFilter(fragmentShaderFromString: kGPUImagePassthroughFragmentShaderString)
        }
        
        movie2.addTarget(filter)
        
        for pic in sourcePictures {
            pic.addTarget(filter)
        }
        
        filter.addTarget(self.moviePreview)
        
        
        observer = player.addPeriodicTimeObserverForInterval(CMTimeMake(3,30), queue: nil, usingBlock: {
            (t: CMTime) in
            
            if let duration = self.movieDuration {
                var percent = Float( CMTimeGetSeconds(t) / CMTimeGetSeconds(duration) )
                self.progress.value = percent
            }
            
            
            return
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        isPlaying = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object:
            playerItem)
        
        movie2.startProcessing()
    }
    

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        isPlaying = false

        
        movie2.removeAllTargets()
        filter.removeAllTargets()
        for pic in sourcePictures {
            pic.removeAllTargets()
        }
//
        player.removeTimeObserver(observer)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toShareMovieSegue" {
            print("toShareMovieSegue: " )
            if let url = movieURLToShare{
                (segue.destinationViewController as ShareMovieViewController).toShareMovieURL  = url
            }
        }else if segue.identifier == "toAudioMixMovieSegue" {
            var vc = segue.destinationViewController.viewControllers![0] as AudioMixViewController
            vc.toEditMovieURL = toEditMovieURL
            vc.toEditMovieType = toEditMovieType
            vc.toEditMovieSize = toEditMovieSize
//            vc.movie = movie2
        }
    }
    
    // MARK: Selectors
    
    func onProgress(){
        
        
    }
    
    func videoItemDidReachEnd(notif: NSNotification){
        
        var item = notif.object as AVPlayerItem
        item.seekToTime(kCMTimeZero)
        isPlaying = false
        
    }
    
    
    // MARK: Utils
    
    func getMovieInfo(url: NSURL){
        var asset = AVURLAsset(URL: url, options: nil)
        asset.loadValuesAsynchronouslyForKeys(["tracks","duration"], completionHandler: {
            var error: NSError?
            if asset.statusOfValueForKey("tracks", error: &error) == .Loaded {
                var track = asset.tracksWithMediaType(AVMediaTypeVideo) [0] as AVAssetTrack
                
                println("naturalSize:\(track.naturalSize)")
                
            }else{
                println("Erorr:\(error!.localizedDescription)")
            }
            
            if asset.statusOfValueForKey("duration", error: &error) == .Loaded {
                self.movieDuration = asset.duration
            }else{
                println("Error get Duration:\(error!.localizedDescription)")
            }
        })
    }
    
    
    
    
    
    // MARK: FilterCollectionViewDelegates
    
    var tmpFilter: GPUImagePerlinNoiseFilter!
    
    func filterSelected(filterType: FilterType) {
        
        
        movie2.removeAllTargets()
        filter.removeAllTargets()
        
        
        var name = filterType.filterFileName
        
        
        switch(name){
        case kGPUImagePassthroughFragmentShaderString:
            filter = GPUImageFilter(fragmentShaderFromString: kGPUImagePassthroughFragmentShaderString)
            movie2.addTarget(filter)
            filter.addTarget(moviePreview)
            break;
            
        case "test":
            filter = GPUImageFilter(fragmentShaderFromFile: "test")
            movie2.addTarget(filter)
            filter.addTarget(moviePreview)
            break;
            
            
        default:
            
            
            var maskCount = 0
            
            sourcePictures.removeAll(keepCapacity: false)
            
            if let masks = filterType.masks {
                maskCount = masks.count
            }
            
            
            if maskCount > 0 {
                
                filter = GPUImageMultipleInputFilter(fragmentShaderFromFile: name, textureCount: maskCount+1)
                movie2.addTarget(filter)
                
                
                for  i in 0...maskCount-1 {
                    var image = UIImage(named: filterType.masks![i])
                    var sourcePicture = GPUImagePicture(image: image)
                    
                    sourcePictures.append(sourcePicture)
                    sourcePicture.processImage()
                    sourcePicture.addTarget(filter)
                }
                
            }else{
                
                filter = GPUImageFilter(fragmentShaderFromFile: name)
                movie2.addTarget(filter)
                
            }
            
            
            filter.addTarget(moviePreview)

                
            
            
        }
        
        

        isPlaying = true
        
    }
    
    

//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        
//        coordinator.animateAlongsideTransition(nil, completion: {
//            (context: UIViewControllerTransitionCoordinatorContext!) in
//            self.layoutMoviePreview()
//        })
//    }
    
    
    // MARK: Custom functions

    func layoutMoviePreview(){
        var myframe = moviePreview.frame
        
        if toEditMovieType == MovieType.Normal {
            //            myframe.size.height =  myframe.size.width * 3 / 4
            moviePreview.addConstraint(NSLayoutConstraint(item: moviePreview, attribute: .Height, relatedBy: .Equal, toItem: moviePreview, attribute: .Width, multiplier: 3.0/4.0, constant: 0))
            
        }else{
            //            myframe.size.height =  myframe.size.width * 9 / 16
            moviePreview.addConstraint(NSLayoutConstraint(item: moviePreview, attribute: .Height, relatedBy: .Equal, toItem: moviePreview, attribute: .Width, multiplier: 9.0/16.0, constant: 0))
            
        }
        
        
        
        moviePreview.frame =  myframe
        //        playControlWrapper.setNeedsDisplay()
        
    }
    
    
    // MARK: Actions
    @IBAction func unwindToEditMovie(segue: UIStoryboardSegue) {
        if segue.identifier == "segueDidAddSubtitle" {
            
            
        }
    }
    
    @IBAction func maskAction(sender: UIButton) {
        
        maskShowing = !maskShowing
        
        if !isPlaying {
            isPlaying = true
            isPlaying = false
            
        }
    }
    
    
    @IBAction func subtitleAction(sender: UIBarButtonItem) {
        
        if self.currentShowing != nil {
            self.currentShowing!.hidden = true
        }
        
        
        if self.currentShowing != self.subtitleView {
            self.subtitleView.hidden = false
            self.currentShowing = self.subtitleView
        }else{
            self.currentShowing = nil
        }
        
        
        
    }
    
    @IBAction func onProgressDrag(sender: UISlider) {
        
        isPlaying = false
        
        var val = sender.value
        if let duration = movieDuration {
            var time = CMTimeMultiplyByFloat64(duration, Float64(val))
            var tolerance = CMTimeMake(2, 30)
            player.seekToTime(time, toleranceBefore: tolerance, toleranceAfter: tolerance)
        }
        
    }
    @IBAction func onPlaybackClick(sender: UIButton) {
        isPlaying = !isPlaying
    }
    
    @IBAction func filerAction(sender: UIBarButtonItem) {
        
        if self.currentShowing != nil {
            self.currentShowing!.hidden = true
        }
        
        if self.currentShowing != self.filterView {
            self.filterView.hidden = false
            self.currentShowing = self.filterView
        }else{
            self.currentShowing = nil
        }
        
        
    }
    @IBAction func showShareScene(sender: AnyObject) {
        
        self.activityIndicator.startAnimating()
        
        var movie2 = GPUImageMovie(URL: toEditMovieURL)
        
        
        var  kDateFormatter: NSDateFormatter?
        kDateFormatter = NSDateFormatter()
        kDateFormatter!.dateStyle = NSDateFormatterStyle.MediumStyle
        kDateFormatter!.timeStyle = NSDateFormatterStyle.ShortStyle
        var outurl = NSFileManager.defaultManager()
            .URLForDirectory(
                .DocumentDirectory,
                inDomain: .UserDomainMask,
                appropriateForURL: nil,
                create: true,
                error: nil)!
            .URLByAppendingPathComponent(kDateFormatter!.stringFromDate( NSDate() ) )
            .URLByAppendingPathExtension( UTTypeCopyPreferredTagWithClass( AVFileTypeQuickTimeMovie , kUTTagClassFilenameExtension).takeRetainedValue() )
        
        
        var movie2writer = GPUImageMovieWriter(movieURL: outurl, size: toEditMovieSize)
        movie2.addTarget(movie2writer)
        movie2writer.completionBlock = {
            self.activityIndicator.stopAnimating()
            self.movieURLToShare = outurl
            
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("toShareMovieSegue", sender: nil)
            })
        }
        
        movie2writer.startRecording()
        movie2.startProcessing()
        
    }
}