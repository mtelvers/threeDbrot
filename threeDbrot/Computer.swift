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
    var bufferCounter: MTLBuffer?
    
    required init(device: MTLDevice){
        super.init()
        var counter: UInt = 10
        
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
        bufferResult = device.makeBuffer(length: MemoryLayout<Vertex>.stride * 2048 * 2048, options: [])
        bufferCounter = device.makeBuffer(length: MemoryLayout<UInt>.size, options: [])
        
        let commandBuffer = commandQueue!.makeCommandBuffer()

        let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
        computeCommandEncoder?.setComputePipelineState(pipeLineState)
        computeCommandEncoder?.setBuffer(bufferResult, offset: 0, index: 0)
        computeCommandEncoder?.setBuffer(bufferCounter, offset: 0, index: 1)
        
        let w = pipeLineState.threadExecutionWidth
        let h = pipeLineState.maxTotalThreadsPerThreadgroup / w
        
        let threadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
        let threadsPerGrid = MTLSize(width: 2048, height: 2048, depth: 1)
        computeCommandEncoder?.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        
        computeCommandEncoder?.endEncoding()
        
        commandBuffer?.commit()
        
        commandBuffer?.waitUntilCompleted()
                
        counter = bufferCounter!.contents().load(fromByteOffset: 0, as: UInt.self)
        print(counter)
        
        vertices = []
        for i in 0..<Int(counter) {
            let v = bufferResult!.contents().load(fromByteOffset: MemoryLayout<Vertex>.stride * i, as: Vertex.self)
            if v.position != float3(0,0,0) {
                vertices.append(v)
            }
        }
    }
    
}
