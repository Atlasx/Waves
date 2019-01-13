//
//  Renderer.swift
//  Waves
//
//  Created by Connor Douglas on 1/13/19.
//  Copyright © 2019 Connor Douglas. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  var mesh: MTKMesh!
  var vertexBuffer: MTLBuffer!
  var pipelineState: MTLRenderPipelineState!
  
  var timer: Float = 0
  
  init(metalView: MTKView) {
    //Init GPU
    guard let device = MTLCreateSystemDefaultDevice() else {
      fatalError("GPU not available")
    }
    metalView.device = device
    Renderer.commandQueue = device.makeCommandQueue()!
    
    //Get our cube primitive
    let mdlMesh = Primitive.makeCube(device: device, size: 1)
    do {
      mesh = try MTKMesh(mesh: mdlMesh, device: device)
    } catch let error {
      print(error.localizedDescription)
    }
    
    vertexBuffer = mesh.vertexBuffers[0].buffer
    
    //Setup shaders
    let library = device.makeDefaultLibrary()
    let vertexFunction = library?.makeFunction(name: "vertex_main")
    let fragmentFunction = library?.makeFunction(name: "fragment_main")

    //Add our shaders to the pipeline
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)
    pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
    do {
      pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    
    
    super.init()
    
    metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
    metalView.delegate = self
  }
}

extension Renderer: MTKViewDelegate {
  //Called when size changes
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
  }
  
  //Called every frame
  func draw(in view: MTKView) {
    guard let descriptor = view.currentRenderPassDescriptor,
      let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
        return
    }
    
    timer += 0.05
    var currentTime = sin(timer)
    renderEncoder.setVertexBytes(&currentTime, length: MemoryLayout<Float>.stride, index: 1)
    
    //Set our pipeline to render
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    for submesh in mesh.submeshes {
      renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
    }
    
    //Render it
    renderEncoder.endEncoding()
    guard let drawable = view.currentDrawable else {
      return
    }
    commandBuffer.present(drawable)
    commandBuffer.commit()
    
  }
}
