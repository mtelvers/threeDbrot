//
//  Renderer.swift
//  threeDbrot
//
//  Created by Mark Elvers on 13/08/2020.
//  Copyright © 2020 Mark Elvers. All rights reserved.
//

import MetalKit

class Renderer: NSObject{
    
    var commandQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    var depthStencilState: MTLDepthStencilState!
    
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    
    var vertices: [Vertex]!
    var indices: [UInt16]!
    
    var constants = Constants()
    
    init(device: MTLDevice){
        super.init()
        buildCommandQueue(device: device)
        buildPipelineState(device: device)
        buildDepthStencilState(device: device)
        buildVertices()
        buildBuffers(device: device)
        constants.projectionMatrix = matrix_float4x4(perspectiveDegreesFov: 45, aspectRatio: 1, nearZ: 0.1, farZ: 100)
        constants.modelMatrix.translate(direction: float3(0,0,-4))
    }
    
    func buildCommandQueue(device: MTLDevice){
        commandQueue = device.makeCommandQueue()
    }
    
    func buildPipelineState(device: MTLDevice){
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "basic_vertex_function")
        let fragmentFunction = library?.makeFunction(name: "basic_fragment_function")
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<float3>.size
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        renderPipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        do{
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        }catch let error as NSError{
            Swift.print("\(error)")
        }
    }
    
    func buildDepthStencilState(device: MTLDevice){
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
    
    func buildVertices(){

        vertices = [
            Vertex(position: float3(-1,  1,  1), color: float4(1,0,0,1)),        //v0
            Vertex(position: float3(-1, -1,  1), color: float4(0,1,0,1)),        //v1
            Vertex(position: float3( 1,  1,  1), color: float4(0,0,1,1)),        //v2
            Vertex(position: float3( 1, -1,  1), color: float4(1,1,0,1)),        //v3
            Vertex(position: float3(-1,  1, -1), color: float4(0,1,1,1)),        //v4
            Vertex(position: float3( 1,  1, -1), color: float4(1,0.5,0.5,1)),    //v5
            Vertex(position: float3(-1, -1, -1), color: float4(0.5,1,0,1)),      //v6
            Vertex(position: float3( 1, -1, -1), color: float4(1,0,0.5,1)),      //v7
        ]
        
        indices = [
            0, 1, 2, 3, 4, 5, 6, 7
        ]
    }
    
    func buildBuffers(device: MTLDevice){
        vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: [])
        indexBuffer = device.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.size * indices.count, options: [])
    }
}

extension Renderer: MTKViewDelegate{
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {  }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer!.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder!.setRenderPipelineState(renderPipelineState)
        commandEncoder!.setDepthStencilState(depthStencilState)
        
        let deltaTime = 1 / Float(view.preferredFramesPerSecond)
        constants.animateBy += deltaTime
//        constants.modelMatrix.rotate(angle: deltaTime, axis: float3(1,0,0))
        constants.modelMatrix.rotate(angle: deltaTime, axis: float3(0,1,0))

        commandEncoder!.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder!.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
        
//        commandEncoder!.drawIndexedPrimitives(type: .point, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
//        commandEncoder!.drawPrimitives(type: .point, indirectBuffer: vertexBuffer, indirectBufferOffset: 0)
        commandEncoder!.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertices.count)
        commandEncoder!.endEncoding()
        commandBuffer!.present(drawable)
        commandBuffer!.commit()
    }
    
}
