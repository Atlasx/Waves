//
//  Primitive.swift
//  Waves
//
//  Created by Connor Douglas on 1/13/19.
//  Copyright © 2019 Connor Douglas. All rights reserved.
//

import MetalKit

class Primitive {
  class func makeCube(device: MTLDevice, size: Float) -> MDLMesh {
    let allocator = MTKMeshBufferAllocator(device: device)
    let mesh = MDLMesh(boxWithExtent: [size, size, size], segments: [1,1,1], inwardNormals: false, geometryType: .triangles, allocator: allocator)
    return mesh
  }
}
