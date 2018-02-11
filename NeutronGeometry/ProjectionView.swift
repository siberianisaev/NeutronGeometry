//
//  ProjectionView.swift
//  NeutronGeometry
//
//  Created by Andrey Isaev on 18/01/2018.
//  Copyright © 2018 Andrey Isaev. All rights reserved.
//

import Cocoa

class ProjectionView: NSView {
    
    var step: Int = 25 {
        didSet {
            if let view = gridView {
                view.step = step
                view.setNeedsDisplay(view.visibleRect)
            }
        }
    }
    fileprivate weak var gridView: GridView?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        addGrid(step)
    }
    
    fileprivate func addGrid(_ step: Int) {
        let view = GridView(frame: NSRect(x: 0, y: 0, width: frame.width, height: frame.height), step: step)
        view.wantsLayer = true
        view.layer?.zPosition = 100
        addSubview(view)
        gridView = view
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        addGrid(10)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        wantsLayer = true
        layer?.borderColor = NSColor.black.cgColor
        layer?.borderWidth = 1
        layer?.backgroundColor = NSColor.white.cgColor
    }
    
}
