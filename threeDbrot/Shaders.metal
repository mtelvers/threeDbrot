//
//  Shaders.metal
//  threeDbrot
//
//  Created by Mark Elvers on 13/08/2020.
//  Copyright © 2020 Mark Elvers. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn{
    float3 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
};

struct VertexOut{
    float4 position [[ position ]];
    float4 color;
    float pointSize [[ point_size ]];
};

struct Constants{
    float animateBy;
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
};

vertex VertexOut basic_vertex_function(const VertexIn vIn [[ stage_in ]],
                                       constant Constants &constants [[buffer(1)]]){
    VertexOut vOut;
    vOut.position = constants.projectionMatrix * constants.modelMatrix * float4(vIn.position, 1);
//    vOut.position.x *= cos(constants.animateBy);
//    vOut.position.y *= cos(constants.animateBy);
//    vOut.position.z *= cos(constants.animateBy);
    vOut.color = vIn.color;
    vOut.pointSize = 1.0;
    return vOut;
}

fragment float4 basic_fragment_function(VertexOut vIn [[ stage_in ]]){
    return vIn.color;
}



kernel void clear_pass_func(device VertexIn* result,
                            uint2 index [[ thread_position_in_grid ]],
                            device atomic_uint &counter [[ buffer(1) ]]) {

    float bufRe[1024];
    float bufIm[1024];

    float Cre = (float(index.x) * 3 / 2048) - 2;
    float Cim = (float(index.y) * 3 / 2048) - 1.5;

    float Zre = 0;
    float Zim = 0;
    
    bufRe[0] = 0;
    bufIm[0] = 0;

    int sequenceStart = 0;
    int iteration;
    
    for (iteration = 1; (iteration < 1023) && (sequenceStart == 0) && ((Zre * Zre + Zim * Zim) <= 4); iteration++) {
        float ZNre = Zre * Zre - Zim * Zim + Cre;
        Zim = 2 * Zre * Zim + Cim;
        Zre = ZNre;
                
        bufRe[iteration] = Zre;
        bufIm[iteration] = Zim;
        
        for (int i = iteration - 1; i; i--) {
            if ((bufRe[iteration] == bufRe[i]) && (bufIm[iteration] == bufIm[i])) {
                sequenceStart = i;
                break;
            }
        }
    }
    
    if (sequenceStart) {
        for (int i = sequenceStart; i < iteration; i++) {
            float red = abs(bufIm[i]) * 5;
            float green = abs(bufRe[i]) / 2;
            float blue = 0.75;
            
            uint value = atomic_fetch_add_explicit(&counter, 1, memory_order_relaxed);
            result[value].position = float3(Cre, Cim, bufRe[i]);
            result[value].color = float4(red, green, blue, 1);
            
        }
    }
}
