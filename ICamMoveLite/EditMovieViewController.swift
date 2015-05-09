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

class EditMovieViewController: UIViewController,  FilterCollectionViewDelegate{
    
    
    @IBOutlet weak var moviePreview: GPUImageView!
    var movie2 : GPUImageMovie!
    var player:  AVPlayer!
    var playerItem: AVPlayerItem!
    
    
    
    
    var isPlaying = false
    
    
    
    var toEditMovieURL: NSURL!
    var toEditMovieType: MovieType!
    var toEditMovieSize: CGSize!
    
    var currentShowing: UIView?
    
    var curFilterIndex: Int?
    
    var timer: NSTimer!
    
    var movieURLToShare: NSURL!
    
    
    // Set show mask as default
    var maskShowing: Bool  = true
    
    
    
    
    @IBOutlet weak var subtitleView: UIView!
    
    @IBOutlet weak var filterView: UIView!
    
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        println("edit movie:\(toEditMovieURL)")
        
        
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
        movie2.addTarget(self.moviePreview)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        player.play()
        movie2.startProcessing()
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
        }
    }
    
    // Selectors
    
    func onProgress(){
        
        
    }
    
    
    
    // MARK: FilterCollectionViewDelegates
    func filterSelected(filterIndex: Int) {
        
    }
    
    
    
    // MARK: UI actions
    @IBAction func unwindToEditMovie(segue: UIStoryboardSegue) {
        if segue.identifier == "segueDidAddSubtitle" {

            
        }
    }
    
    @IBAction func maskAction(sender: UIButton) {
        
        maskShowing = !maskShowing
        
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