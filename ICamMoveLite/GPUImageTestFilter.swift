//
//  GPUImageTestFilter.swift
//  ICamMoveLite
//
//  Created by Alex Chan on 15/5/19.
//  Copyright (c) 2015年 Alex Chan. All rights reserved.
//

import Foundation
import GPUImage

class GPUImageTestFilter: GPUImageFilter {
    
    var textureCount: Int = 0
    
   
    convenience init!(fragmentShaderFromFile fragmentShaderFilename: String!, textureCount  count: Int) {
        
        self.init(fragmentShaderFromFile: fragmentShaderFilename)
        self.textureCount = count
    }
    
    
    
}

