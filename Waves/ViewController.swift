//
//  ViewController.swift
//  Waves
//
//  Created by Connor Douglas on 1/13/19.
//  Copyright © 2019 Connor Douglas. All rights reserved.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {

  var renderer: Renderer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let metalView = view as? MTKView else {
      fatalError("Metal View not set up in storyboard")
    }
    
    renderer = Renderer(metalView: metalView)
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }


}

