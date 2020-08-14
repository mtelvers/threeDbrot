//
//  Computer.swift
//  threeDbrot
//
//  Created by Mark Elvers on 14/08/2020.
//  Copyright © 2020 Mark Elvers. All rights reserved.
//

import MetalKit

class Computer: NSObject {
    
    var commandQueue: MTLCommandQueue!
    var pipeLineState: MTLComputePipelineState!
    var bufferResult: MTLBuffer?
    
    required init(device: MTLDevice){
        super.init()
        
        let commandQueue = device.makeCommandQueue()
        let library = device.makeDefaultLibrary()
        let clearFunc = library?.makeFunction(name: "clear_pass_func")
        
        do {
            pipeLineState = try device.makeComputePipelineState(function: clearFunc!)
        } catch let error as NSError {
            print(error)
        }
                
//        var vertex: [Vertex] = []
//        vertex.append(Vertex(position: float3(0,0,0), color: float4(0,0,0,0)))
        bufferResult = device.makeBuffer(length: MemoryLayout<Vertex>.stride * 65536, options: [])
        
        let commandBuffer = commandQueue!.makeCommandBuffer()

        let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
        computeCommandEncoder?.setComputePipelineState(pipeLineState)
        computeCommandEncoder?.setBuffer(bufferResult, offset: 0, index: 0)
        
        let w = pipeLineState.threadExecutionWidth
        let h = pipeLineState.maxTotalThreadsPerThreadgroup / w
        
        var threadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
        var threadsPerGrid = MTLSize(width: 256, height: 256, depth: 1)
        computeCommandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        
        computeCommandEncoder?.endEncoding()
        
        commandBuffer?.commit()
        
        commandBuffer?.waitUntilCompleted()
        
        for i in 0..<65536 {
            print(bufferResult!.contents().load(fromByteOffset: MemoryLayout<Vertex>.stride * i, as: Vertex.self))
        }
    }
    
}
