//
//  Types.swift
//  threeDbrot
//
//  Created by Mark Elvers on 13/08/2020.
//  Copyright © 2020 Mark Elvers. All rights reserved.
//

import MetalKit

struct Vertex{
    var position: float3
    var color: float4
}

struct Constants{
    var animateBy: Float = 1
    var modelMatrix: float4x4 = matrix_identity_float4x4
    var projectionMatrix: float4x4 = matrix_identity_float4x4
}
