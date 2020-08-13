//
//  MetalView.swift
//  threeDbrot
//
//  Created by Mark Elvers on 13/08/2020.
//  Copyright © 2020 Mark Elvers. All rights reserved.
//

import MetalKit

class MetalView: MTKView {

    var renderer: Renderer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.device = MTLCreateSystemDefaultDevice()
        
        self.colorPixelFormat = .bgra8Unorm
        
        self.depthStencilPixelFormat = .depth32Float
        
        self.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        renderer = Renderer(device: device!)
        
        self.delegate = renderer
        
    }
    
    
}
