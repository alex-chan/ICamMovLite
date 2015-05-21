//
//  FilterCollectionViewController.swift
//  ICamMov
//
//  Created by Alex Chan on 15/4/10.
//  Copyright (c) 2015年 sunset. All rights reserved.
//

import Foundation
import UIKit
import GPUImage

struct FilterType {
    var displayName: String
    var filterFileName: String
    var previewImageName: String
    var masks: [String]?
    init(displayName display: String, filterFileName filter: String, previewImageName preview: String, masks: [String]?){
        displayName = display
        filterFileName = filter
        previewImageName = preview
        self.masks = masks
    }
    
    init(displayName display: String, filterFileName filter: String, previewImageName preview: String){
        self.init(displayName: display, filterFileName: filter, previewImageName: preview, masks: nil)
    }
    
}

protocol FilterCollectionViewDelegate {
    func filterSelected(filter:FilterType)
    
    
}




class FilterCollectionViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate{

    var delegate: FilterCollectionViewDelegate?
    
    var filters = [
        FilterType(displayName: "无", filterFileName: kGPUImagePassthroughFragmentShaderString , previewImageName: "filter00"),
        
//        FilterType(displayName: "测试", filterFileName: "test" , previewImageName: "filter01"),
        FilterType(displayName: "普通", filterFileName: "normal" , previewImageName: "filter00"),
        
        
        FilterType(displayName: "Amaro", filterFileName: "amaro" , previewImageName: "filter02", masks: ["blackboard_1024","overlay_map","amaro_map"]),
        
        FilterType(displayName: "xproII", filterFileName: "xproii" , previewImageName: "filter06", masks: ["xpro_map", "vignette_map"]),
        
        FilterType(displayName: "walden", filterFileName: "walden" , previewImageName: "filter06", masks: ["walden_map", "vignette_map"]),
        
        
        FilterType(displayName: "valencia", filterFileName: "valencia" , previewImageName: "filter06", masks: ["valencia_map", "valencia_gradient_map"]),
        
        FilterType(displayName: "toaster", filterFileName: "toaster" , previewImageName: "filter06", masks: ["toaster_metal", "toaster_soft_light","toaster_curves", "toaster_overlay_map_warm", "toaster_color_shift"]),
        
        FilterType(displayName: "sutro", filterFileName: "sutro" , previewImageName: "filter06", masks: ["vignette_map", "sutro_metal","soft_light", "sutro_edge_burn", "sutro_curves"]),
        
        FilterType(displayName: "sierra", filterFileName: "sierra" , previewImageName: "filter06", masks: ["sierra_vignette", "overlay_map","sierra_map"]),

        FilterType(displayName: "rise", filterFileName: "rise" , previewImageName: "filter06", masks: ["blackboard_1024", "overlay_map","rise_map"]),
        
        
        FilterType(displayName: "nashville", filterFileName: "nashville" , previewImageName: "filter08", masks: ["nashville_map"]),
        
        FilterType(displayName: "kelvin", filterFileName: "lordkelvin" , previewImageName: "filter07", masks: ["kelvin_map"]),
        
        FilterType(displayName: "lomofi", filterFileName: "lomofi" , previewImageName: "filter06", masks: ["lomo_map", "vignette_map"]),
        
        FilterType(displayName: "hudson", filterFileName: "hudson" , previewImageName: "filter06", masks: ["hudson_background", "overlay_map","hudson_map"]),
        
        
        FilterType(displayName: "hefe", filterFileName: "hefe" , previewImageName: "filter06", masks: ["edge_burn", "hefe_map","hefe_gradient_map","hefe_soft_light","hefe_metal"]),
        
        FilterType(displayName: "hefe_org", filterFileName: "hefe_original" , previewImageName: "filter06", masks: ["hefe_original"]),
        

        
        FilterType(displayName: "Branner", filterFileName: "branner" , previewImageName: "filter05", masks: ["brannan_process", "brannan_blowout","brannan_contrast","brannan_luma","brannan_screen"]),
        
        FilterType(displayName: "Inkwell", filterFileName: "inkwell" , previewImageName: "filter00", masks: ["inkwell_map"]),
        
        FilterType(displayName: "EarlyBird", filterFileName: "early_bird" , previewImageName: "filter01", masks: ["early_bird_curves","earlybird_overlay_map","vignette_map","earlybird_blowout","earlybird_map"]),
        
        FilterType(displayName: "1977", filterFileName: "1977" , previewImageName: "filter02", masks: ["map_1977","blowout_1977"]),

        
    ]
    
    var curSelectedCellIndex:  NSIndexPath! = NSIndexPath(index: 0) {
        didSet {
            if let del = delegate {
                var name = filters[curSelectedCellIndex.item]
                
                del.filterSelected(name)
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countElements(filters)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterReuseID", forIndexPath: indexPath) as FilterCollectionViewCell
//        cell.backgroundColor = UIColor.appGlobalColor()
        
        
        var imageName = filters[indexPath.item].previewImageName
        var displayName = filters[indexPath.item].displayName
        
        cell.filterImage.image = UIImage(named: imageName)
        cell.filterName.text = displayName
        
        if indexPath == curSelectedCellIndex {
            cell.backgroundColor = UIColor.appGlobalColor()
        }else{
            cell.backgroundColor = UIColor.clearColor()
        }
        
        
        return cell
    }
    
    
    // MARK: UICollectionViewDelegates
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var cell = collectionView.cellForItemAtIndexPath(indexPath)
        if curSelectedCellIndex != nil {
            collectionView.cellForItemAtIndexPath(curSelectedCellIndex)?.backgroundColor = UIColor.clearColor()
        }
        cell?.backgroundColor = UIColor.appGlobalColor()
        curSelectedCellIndex = indexPath
    }
}