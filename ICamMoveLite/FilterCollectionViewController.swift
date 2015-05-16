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
    var mask: String?
    init(displayName display: String, filterFileName filter: String, previewImageName preview: String, mask: String?){
        displayName = display
        filterFileName = filter
        previewImageName = preview
        self.mask = mask
    }
    
    init(displayName display: String, filterFileName filter: String, previewImageName preview: String){
        self.init(displayName: display, filterFileName: filter, previewImageName: preview, mask: nil)
    }
    
}

protocol FilterCollectionViewDelegate {
    func filterSelected(filter:FilterType)
    
    
}





class FilterCollectionViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    
    
    var delegate: FilterCollectionViewDelegate?
    
    var filters = [
        FilterType(displayName: "无", filterFileName: kGPUImagePassthroughFragmentShaderString , previewImageName: "filter00"),
        FilterType(displayName: "测试", filterFileName: "test" , previewImageName: "filter01"),
        FilterType(displayName: "Hefe", filterFileName: "hefe" , previewImageName: "filter01", mask:"hefe"),
        FilterType(displayName: "Amaro", filterFileName: "amaro" , previewImageName: "filter02"),
        FilterType(displayName: "AmaroTwoInput", filterFileName: "amaro_twoinput" , previewImageName: "filter03", mask:"mask0"),
        FilterType(displayName: "AmaroTwoInputR", filterFileName: "amaro_twoinput_reverse" , previewImageName: "filter04", mask:"mask0"),
        FilterType(displayName: "血色黑白", filterFileName: "grayscale_bloodred" , previewImageName: "filter05")
        
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