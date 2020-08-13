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
    vOut.pointSize = 20.0;
    return vOut;
}

fragment float4 basic_fragment_function(VertexOut vIn [[ stage_in ]]){
    return vIn.color;
}

